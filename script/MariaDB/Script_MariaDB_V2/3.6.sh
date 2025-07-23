OUTPUT_FILE="audit_results.txt"

# Ambil status general_log dan lokasi general_log_file dari MariaDB
read GENERAL_LOG_STATUS GENERAL_LOG_FILE < <(mysql -u root -p'bangtob150420' -N -B -e "SELECT @@general_log, @@general_log_file;")

if [[ "$GENERAL_LOG_STATUS" == "OFF" || "$GENERAL_LOG_STATUS" == "0" ]]; then
    # Jika general log dimatikan, pastikan file lama dihapus
    if [[ -n "$GENERAL_LOG_FILE" && -f "$GENERAL_LOG_FILE" ]]; then
        STATUS="Fail"
        VALUE="General log dimatikan, tetapi file lama ($GENERAL_LOG_FILE) masih ada. Disarankan untuk menghapusnya."
    else
        STATUS="Pass"
        VALUE="General log dimatikan dan tidak ada file lama."
    fi
else
    # Jika general log aktif, cek permission file
    if [[ -n "$GENERAL_LOG_FILE" && -f "$GENERAL_LOG_FILE" ]]; then
        COMPLIANT=$(ls -l "$GENERAL_LOG_FILE" 2>/dev/null | grep '^-rw-------.*mysql.*mysql.*$')
        if [[ -n "$COMPLIANT" ]]; then
            STATUS="Pass"
            VALUE="General log aktif dan file ($GENERAL_LOG_FILE) memiliki permission sesuai (-rw------- mysql mysql)."
        else
            STATUS="Fail"
            VALUE="General log aktif, tetapi file ($GENERAL_LOG_FILE) tidak memiliki permission '-rw-------' dengan user dan group mysql."
        fi
    else
        STATUS="Fail"
        VALUE="General log aktif, tetapi file general_log_file tidak ditemukan."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.6 Ensure 'general_log_file' Has Appropriate Permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : General log harus dinonaktifkan, atau jika aktif, file harus memiliki permission '-rw-------' dan dimiliki oleh user dan group 'mysql'."
    echo "Deskripsi : Memastikan bahwa general log MariaDB dilindungi dengan permission yang ketat atau dinonaktifkan jika tidak digunakan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
