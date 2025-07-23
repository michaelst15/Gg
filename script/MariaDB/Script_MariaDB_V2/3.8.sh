OUTPUT_FILE="audit_results.txt"

# Ambil nilai plugin_dir dari MariaDB
PLUGIN_DIR=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW VARIABLES WHERE Variable_name='plugin_dir';" | awk '{print $2}')

STATUS="Pass"
DETAILS=""

if [[ -z "$PLUGIN_DIR" ]]; then
    STATUS="Fail"
    DETAILS="plugin_dir tidak ditemukan dari konfigurasi MariaDB."
else
    if [[ -d "$PLUGIN_DIR" ]]; then
        COMPLIANT=$(ls -ld "$PLUGIN_DIR" 2>/dev/null | egrep "dr-xr-x---|dr-xr-xr--")
        if [[ -z "$COMPLIANT" ]]; then
            STATUS="Fail"
            DETAILS="Direktori plugin $PLUGIN_DIR tidak memiliki permission 550 atau 554 sesuai standar."
        else
            DETAILS="Direktori plugin $PLUGIN_DIR memiliki permission sesuai (550/554)."
        fi
    else
        STATUS="Fail"
        DETAILS="Direktori plugin $PLUGIN_DIR tidak ada di sistem."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.8 Ensure Plugin Directory Has Appropriate Permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Direktori plugin MariaDB harus memiliki permission 550 atau 554, dimiliki oleh user dan group 'mysql'."
    echo "Deskripsi : Memastikan direktori plugin MariaDB tidak dapat dimodifikasi oleh user yang tidak berwenang, mencegah eksekusi kode berbahaya saat MariaDB dijalankan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
