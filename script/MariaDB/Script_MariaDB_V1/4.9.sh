OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Data-at-rest encryption aktif di MariaDB."

# Periksa variabel terkait enkripsi
ENCRYPT_VARS=$(mariadb -N -B -e "SELECT VARIABLE_NAME, VARIABLE_VALUE FROM information_schema.global_variables WHERE VARIABLE_NAME LIKE '%ENCRYPT%';" 2>/dev/null)

# Deteksi apakah semua nilai OFF
if echo "$ENCRYPT_VARS" | grep -q "OFF"; then
    STATUS="Fail"
    DETAILS="Beberapa variabel enkripsi at-rest masih OFF:\n$ENCRYPT_VARS"
fi

# Periksa apakah tablespace dienkripsi
TABLESPACE_ENCRYPT=$(mariadb -N -B -e "SELECT SPACE, NAME FROM INFORMATION_SCHEMA.INNODB_TABLESPACES_ENCRYPTION;" 2>/dev/null)

if [[ -z "$TABLESPACE_ENCRYPT" ]]; then
    STATUS="Fail"
    DETAILS="Tidak ada tablespace yang dienkripsi di MariaDB."
fi

# Cek apakah backup menggunakan enkripsi (hanya pengecekan pola sederhana)
BACKUP_CMD=$(grep -R "mariabackup" /etc/cron* 2>/dev/null | grep "openssl enc")
if [[ -z "$BACKUP_CMD" ]]; then
    STATUS="Fail"
    DETAILS="$DETAILS\nBackup tidak ditemukan menggunakan enkripsi."
fi

# Simpan hasil audit
{
    echo "Judul Audit : 4.9 Enable data-at-rest encryption in MariaDB"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : MariaDB harus menggunakan enkripsi data-at-rest untuk semua tablespace dan backup."
    echo "Deskripsi : Enkripsi data-at-rest melindungi data dari akses fisik yang tidak sah dan membantu memenuhi persyaratan kepatuhan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
