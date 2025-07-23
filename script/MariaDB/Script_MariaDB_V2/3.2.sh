OUTPUT_FILE="audit_results.txt"

# Ambil nilai log_bin_basename dari MariaDB
LOG_BIN_BASENAME=$(mysql -u root -p'bangtob150420' -N -B -e "
SHOW VARIABLES LIKE 'log_bin_basename';
" | awk '{print $2}')

# Cek apakah log_bin_basename ditemukan
if [[ -z "$LOG_BIN_BASENAME" ]]; then
    STATUS="Fail"
    VALUE="Tidak dapat menentukan log_bin_basename dari MariaDB (mungkin binary logging tidak aktif)."
else
    # Cek permission file binary log
    NON_COMPLIANT=$(ls -l ${LOG_BIN_BASENAME}* 2>/dev/null | \
    egrep -v '^-rw-rw----.*mysql\s*mysql')

    if [[ -n "$NON_COMPLIANT" ]]; then
        STATUS="Fail"
        VALUE="
Terdapat file binary log dengan permission tidak sesuai:
$NON_COMPLIANT"
    else
        STATUS="Pass"
        VALUE="Semua file binary log (${LOG_BIN_BASENAME}*) memiliki permission yang sesuai (-rw-rw---- mysql mysql)."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.2 Ensure 'log_bin_basename' Files Have Appropriate Permissions"
    echo "Status : $STATUS"
    echo -e "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Semua file binary log harus memiliki permission '-rw-rw----' dan dimiliki oleh user dan group 'mysql'."
    echo "Deskripsi : Memastikan bahwa semua file binary log MariaDB memiliki hak akses yang benar untuk melindungi kerahasiaan, integritas, dan ketersediaan log biner."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
