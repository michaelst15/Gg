OUTPUT_FILE="audit_results.txt"

# Query MariaDB untuk cek status binlog
LOG_BIN=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW VARIABLES LIKE 'log_bin';" 2>/dev/null | awk '{print $2}')
EXPIRE_LOGS=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW VARIABLES LIKE 'binlog_expire_logs_seconds';" 2>/dev/null | awk '{print $2}')

# Kalau kosong, set jadi "Empty"
if [[ -z "$LOG_BIN" ]]; then
    LOG_BIN="Empty"
fi
if [[ -z "$EXPIRE_LOGS" ]]; then
    EXPIRE_LOGS="Empty"
fi

# Default status
STATUS="Fail"
VALUE="Binary logs not enabled or no expiration configured"

if [[ "$LOG_BIN" == "ON" && "$EXPIRE_LOGS" != "Empty" && "$EXPIRE_LOGS" -ne 0 ]]; then
    STATUS="Pass"
    VALUE="Binary logs enabled with expiration set ($EXPIRE_LOGS seconds)"
elif [[ "$LOG_BIN" == "ON" && ( "$EXPIRE_LOGS" == "Empty" || "$EXPIRE_LOGS" -eq 0 ) ]]; then
    STATUS="Fail"
    VALUE="Binary logs enabled but no expiration set (binlog_expire_logs_seconds = $EXPIRE_LOGS)"
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
