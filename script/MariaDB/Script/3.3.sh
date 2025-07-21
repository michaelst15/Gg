OUTPUT_FILE="audit_results.txt"

# Ambil nilai log_error dari MariaDB
LOG_ERROR=$(mysql -N -B -e "
SHOW VARIABLES LIKE 'log_error';
" | awk '{print $2}')

# Cek apakah log_error ditemukan
if [[ -z "$LOG_ERROR" ]]; then
    STATUS="Fail"
    VALUE="Tidak dapat menentukan log_error dari MariaDB (mungkin error logging tidak aktif)."
else
    # Cek permission file log error
    COMPLIANT=$(ls -l "$LOG_ERROR" 2>/dev/null | grep '^-rw-------.*mysql.*mysql.*$')

    if [[ -n "$COMPLIANT" ]]; then
        STATUS="Pass"
        VALUE="File log error ($LOG_ERROR) memiliki permission yang sesuai (-rw------- mysql mysql)."
    else
        STATUS="Fail"
        VALUE="File log error ($LOG_ERROR) tidak memiliki permission '-rw-------' dengan user dan group mysql."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.3 Ensure 'log_error' Has Appropriate Permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : File error log MariaDB harus memiliki permission '-rw-------' dan dimiliki oleh user dan group 'mysql'."
    echo "Deskripsi : Memastikan bahwa file error log MariaDB hanya dapat diakses oleh user dan group MariaDB, untuk melindungi kerahasiaan, integritas, dan ketersediaan log error."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
