OUTPUT_FILE="audit_results.txt"

STATUS="Pass"
DETAILS=""

# Ambil versi MariaDB yang sedang berjalan
DB_VERSION=$(mysql -N -B -e "SHOW VARIABLES WHERE Variable_name LIKE 'version';" 2>/dev/null | awk '{print $2}')

if [[ -z "$DB_VERSION" ]]; then
    STATUS="Fail"
    DETAILS="Tidak dapat mengambil versi MariaDB. Pastikan MariaDB berjalan dan user memiliki akses."
else
    DETAILS="Versi MariaDB yang berjalan: $DB_VERSION.\nPeriksa apakah ini versi terbaru dengan membandingkan ke security announcement resmi MariaDB atau update OS."
fi

# Tulis hasil audit
{
    echo "Judul Audit : 4.1 Ensure the Latest Security Patches are Applied"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Pastikan MariaDB diperbarui dengan security patch terbaru untuk mengurangi risiko kerentanan."
    echo "Deskripsi : MariaDB harus selalu menggunakan versi terbaru yang telah di-patch untuk menghindari eksploitasi kerentanan yang sudah diketahui."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
