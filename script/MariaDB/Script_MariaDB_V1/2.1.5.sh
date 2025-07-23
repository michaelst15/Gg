OUTPUT_FILE="audit_results.txt"

# Query MariaDB untuk cek status binlog dan expire time
BINLOG_INFO=$(mysql -N -B -e "
SELECT VARIABLE_NAME, VARIABLE_VALUE
FROM information_schema.global_variables
WHERE VARIABLE_NAME IN ('log_bin','binlog_expire_logs_seconds');
")

LOG_BIN=$(echo "$BINLOG_INFO" | awk '/log_bin/ {print $2}')
EXPIRE_LOGS=$(echo "$BINLOG_INFO" | awk '/binlog_expire_logs_seconds/ {print $2}')

# Default status
STATUS="Fail"
VALUE="Binary logs not enabled or no expiration configured"

if [[ "$LOG_BIN" == "ON" && -n "$EXPIRE_LOGS" && "$EXPIRE_LOGS" -ne 0 ]]; then
    STATUS="Pass"
    VALUE="Binary logs enabled with expiration set ($EXPIRE_LOGS seconds)"
elif [[ "$LOG_BIN" == "ON" && ( -z "$EXPIRE_LOGS" || "$EXPIRE_LOGS" -eq 0 ) ]]; then
    STATUS="Fail"
    VALUE="Binary logs enabled but no expiration set (binlog_expire_logs_seconds is 0)"
else
    STATUS="Fail"
    VALUE="Binary logs not enabled (log_bin=$LOG_BIN)"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.1.5 Point-in-Time Recovery"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Binary logs harus diaktifkan dan memiliki expire time (>0) untuk mendukung Point-in-Time Recovery"
    echo "Deskripsi : Verifikasi bahwa binary logs MariaDB diaktifkan, memiliki pengaturan expire, dan dapat digunakan untuk Point-in-Time Recovery."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
