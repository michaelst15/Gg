OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil nilai log_warnings
LOG_WARNINGS=$(mariadb -N -B -e "SHOW GLOBAL VARIABLES LIKE 'log_warnings';" 2>/dev/null | awk '{print $2}')

# Tentukan PASS/FAIL
if [[ -z "$LOG_WARNINGS" ]]; then
    STATUS="FAIL"
    DETAILS="log_warnings tidak dikonfigurasi atau tidak ditemukan."
elif [[ "$LOG_WARNINGS" -ne 2 ]]; then
    STATUS="FAIL"
    DETAILS="log_warnings bernilai $LOG_WARNINGS, seharusnya 2."
else
    DETAILS="log_warnings dikonfigurasi dengan benar: $LOG_WARNINGS"
fi

{
    echo "Judul Audit : 6.3 Ensure 'log_warnings' is Set to '2'"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo ""
    echo "Nilai CIS : log_warnings harus diset ke 2 untuk mencatat error dan warning."
    echo "Deskripsi : log_warnings mengontrol tingkat verbositas log error MariaDB, membantu mendeteksi perilaku berbahaya dengan mencatat error dan koneksi yang gagal."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
