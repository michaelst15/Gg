OUTPUT_FILE="audit_results.txt"

# Ambil nilai relay_log_basename dari MariaDB
RELAY_LOG_BASENAME=$(mysql -N -B -e "SHOW VARIABLES LIKE 'relay_log_basename';" | awk '{print $2}')

if [[ -n "$RELAY_LOG_BASENAME" ]]; then
    # Cari file relay log yang terkait
    RELAY_LOG_FILES=$(ls ${RELAY_LOG_BASENAME}* 2>/dev/null)

    if [[ -n "$RELAY_LOG_FILES" ]]; then
        # Cek apakah semua file sesuai permission -rw------- mysql mysql
        NON_COMPLIANT=$(ls -l $RELAY_LOG_FILES 2>/dev/null | grep -v '^-rw-------.*mysql.*mysql.*$')

        if [[ -z "$NON_COMPLIANT" ]]; then
            STATUS="Pass"
            VALUE="Semua file relay log memiliki permission yang sesuai (-rw------- mysql mysql)."
        else
            STATUS="Fail"
            VALUE="Ditemukan file relay log dengan permission tidak sesuai:\n$NON_COMPLIANT"
        fi
    else
        STATUS="Fail"
        VALUE="Tidak ditemukan file relay log dengan pola: ${RELAY_LOG_BASENAME}*"
    fi
else
    STATUS="Fail"
    VALUE="relay_log_basename tidak dikonfigurasi atau tidak ditemukan."
fi

# Tulis hasil audit ke file
{
    echo "Judul Audit : 3.5 Ensure 'relay_log_basename' Files Have Appropriate Permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : File relay log harus memiliki permission '-rw-------' dan dimiliki oleh 'mysql:mysql'."
    echo "Deskripsi : Memastikan file relay log memiliki hak akses terbatas untuk menjaga kerahasiaan, integritas, dan ketersediaan data MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
