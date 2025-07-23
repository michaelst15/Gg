OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Cari file konfigurasi mariadb.cnf (umumnya di /etc/mysql/mariadb.cnf atau /etc/my.cnf)
CONFIG_FILE="/etc/mysql/mariadb.cnf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    CONFIG_FILE="/etc/my.cnf"
fi

DETAILS=""
if [[ -f "$CONFIG_FILE" ]]; then
    # Cek apakah ada password di section [client]
    if grep -A3 "^\[client\]" "$CONFIG_FILE" | grep -iq "password"; then
        STATUS="FAIL"
        DETAILS="Ditemukan parameter 'password' di section [client] pada $CONFIG_FILE."
    else
        DETAILS="Tidak ditemukan parameter 'password' di section [client] pada $CONFIG_FILE."
    fi
else
    STATUS="MANUAL REVIEW"
    DETAILS="File konfigurasi MariaDB tidak ditemukan. Periksa lokasi file konfigurasi secara manual."
fi

{
    echo "Judul Audit : 7.2 Ensure Passwords are Not Stored in the Global Configuration"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "File Konfigurasi $CONFIG_FILE"
    echo "$DETAILS"
    echo "Nilai CIS : Pastikan tidak ada parameter 'password' di section [client] pada file mariadb.cnf."
    echo "Deskripsi : Menyimpan password di file konfigurasi global dapat mengakibatkan kebocoran kredensial karena file ini biasanya dapat diakses oleh semua pengguna."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
