OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil nilai log_error
LOG_ERROR=$(mariadb -N -B -e "SHOW VARIABLES LIKE 'log_error';" 2>/dev/null | awk '{print $2}')

# Tentukan PASS/FAIL
if [[ -z "$LOG_ERROR" || "$LOG_ERROR" == "./stderr.err" ]]; then
    STATUS="FAIL"
    DETAILS="log_error tidak dikonfigurasi dengan benar. Nilai saat ini: ${LOG_ERROR:-'(kosong)'}"
else
    DETAILS="log_error dikonfigurasi ke file: $LOG_ERROR"
fi

{
    echo "Judul Audit : 6.1 Ensure 'log_error' is configured correctly"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo ""
    echo "Nilai CIS : Pastikan 'log_error' diarahkan ke file dan bukan './stderr.err'."
    echo "Deskripsi : Error log harus diaktifkan dan tidak diarahkan ke stderr untuk memastikan keamanan dan kemudahan audit."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
