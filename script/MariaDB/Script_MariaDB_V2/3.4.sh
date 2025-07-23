OUTPUT_FILE="audit_results.txt"

# Ambil status slow_query_log dari MariaDB
SLOW_QUERY_LOG_STATUS=$(mysql -u root -p'bangtob150420' -N -B -e "
SHOW VARIABLES LIKE 'slow_query_log';
" | awk '{print $2}')

# Ambil lokasi slow_query_log_file dari MariaDB
SLOW_QUERY_LOG_FILE=$(mysql -u root -p'bangtob150420' -N -B -e "
SHOW VARIABLES LIKE 'slow_query_log_file';
" | awk '{print $2}')

if [[ "$SLOW_QUERY_LOG_STATUS" == "OFF" ]]; then
    # Jika slow query log dimatikan, pastikan file lama dihapus
    if [[ -n "$SLOW_QUERY_LOG_FILE" && -f "$SLOW_QUERY_LOG_FILE" ]]; then
        STATUS="Fail"
        VALUE="Slow query log dimatikan, tetapi file lama ($SLOW_QUERY_LOG_FILE) masih ada. Disarankan untuk menghapusnya."
    else
        STATUS="Pass"
        VALUE="Slow query log dimatikan dan tidak ada file lama."
    fi
else
    # Jika slow query log aktif, cek permission file
    if [[ -n "$SLOW_QUERY_LOG_FILE" && -f "$SLOW_QUERY_LOG_FILE" ]]; then
        COMPLIANT=$(ls -l "$SLOW_QUERY_LOG_FILE" 2>/dev/null | grep '^-rw-------.*mysql.*mysql.*$')
        if [[ -n "$COMPLIANT" ]]; then
            STATUS="Pass"
            VALUE="Slow query log aktif dan file ($SLOW_QUERY_LOG_FILE) memiliki permission sesuai (-rw------- mysql mysql)."
        else
            STATUS="Fail"
            VALUE="Slow query log aktif, tetapi file ($SLOW_QUERY_LOG_FILE) tidak memiliki permission '-rw-------' dengan user dan group mysql."
        fi
    else
        STATUS="Fail"
        VALUE="Slow query log aktif, tetapi file slow_query_log_file tidak ditemukan."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.4 Ensure 'slow_query_log' Has Appropriate Permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Slow query log harus dinonaktifkan, atau jika aktif, file harus memiliki permission '-rw-------' dan dimiliki oleh user dan group 'mysql'."
    echo "Deskripsi : Memastikan bahwa slow query log MariaDB dilindungi dengan permission yang ketat atau dinonaktifkan jika tidak digunakan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
