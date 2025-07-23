OUTPUT_FILE="audit_results.txt"

# Audit: cek apakah MariaDB berjalan dengan user mysql
PROCESS_INFO=$(ps -eo user,pid,cmd | grep -E 'mysqld' | grep -v grep)

if [[ -n "$PROCESS_INFO" ]]; then
    # Ambil user yang menjalankan mysqld
    RUN_USER=$(echo "$PROCESS_INFO" | awk '{print $1}' | sort -u)

    if [[ "$RUN_USER" == "mysql" ]]; then
        STATUS="Pass"
        VALUE="MariaDB is running under dedicated user: $RUN_USER"
    else
        STATUS="Fail"
        VALUE="MariaDB is running under non-dedicated user: $RUN_USER"
    fi
else
    STATUS="Fail"
    VALUE="MariaDB service not running or no mysqld process found"
fi

# Tulis hasil ke file audit
{
    echo "Judul Audit : 1.2 Use Dedicated Least Privileged Account for MariaDB Daemon/Service"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : MariaDB harus berjalan dengan dedicated least privileged user (mysql)"
    echo "Deskripsi : Verifikasi bahwa service MariaDB dijalankan dengan akun mysql untuk membatasi akses."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
