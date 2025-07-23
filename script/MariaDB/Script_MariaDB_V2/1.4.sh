OUTPUT_FILE="audit_results.txt"

# Cari apakah ada proses yang memiliki MYSQL_PWD di environment
MYSQL_PWD_USAGE=$(grep -z MYSQL_PWD /proc/*/environ 2>/dev/null)

if [[ -n "$MYSQL_PWD_USAGE" ]]; then
    STATUS="Fail"
    VALUE="MYSQL_PWD environment variable found in one or more running processes"
else
    STATUS="Pass"
    VALUE="No MYSQL_PWD environment variable found in running processes"
fi

# Tulis hasil ke file audit
{
    echo "Judul Audit : 1.4 Verify That the MYSQL_PWD Environment Variable is Not in Use"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : MYSQL_PWD environment variable tidak boleh digunakan"
    echo "Deskripsi : Pastikan tidak ada proses yang memiliki MYSQL_PWD di environment untuk menjaga kerahasiaan kredensial MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
