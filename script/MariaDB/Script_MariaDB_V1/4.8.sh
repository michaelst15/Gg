OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="sql_mode sudah mengandung STRICT_ALL_TABLES."

# Periksa nilai sql_mode di MariaDB
SQL_MODE=$(mariadb -N -B -e "SHOW VARIABLES LIKE 'sql_mode';" 2>/dev/null | awk '{print $2}')

if [[ -z "$SQL_MODE" ]]; then
    STATUS="Fail"
    DETAILS="sql_mode kosong. STRICT_ALL_TABLES tidak ditemukan."
elif [[ "$SQL_MODE" != *"STRICT_ALL_TABLES"* ]]; then
    STATUS="Fail"
    DETAILS="STRICT_ALL_TABLES tidak ditemukan pada sql_mode. Nilai saat ini: $SQL_MODE"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 4.8 Ensure 'sql_mode' Contains 'STRICT_ALL_TABLES'"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : sql_mode harus mencakup STRICT_ALL_TABLES untuk mencegah MariaDB menyesuaikan data secara diam-diam."
    echo "Deskripsi : STRICT_ALL_TABLES memastikan MariaDB menolak data yang tidak valid atau tidak sesuai, daripada memodifikasi atau memangkas data secara otomatis."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
