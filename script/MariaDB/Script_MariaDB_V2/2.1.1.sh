OUTPUT_FILE="audit_results.txt"

# Cek apakah ada jadwal backup MariaDB di crontab root dan mysql
ROOT_CRON=$(crontab -l 2>/dev/null | grep -E "mysqldump|mariabackup")
MYSQL_CRON=$(sudo -u mysql crontab -l 2>/dev/null | grep -E "mysqldump|mariabackup")

if [[ -n "$ROOT_CRON" || -n "$MYSQL_CRON" ]]; then
    STATUS="Pass"
    VALUE="
Backup schedule found in crontab
$ROOT_CRON"
else
    STATUS="Fail"
    VALUE="
No backup schedule found in crontab
$ROOT_CRON"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.1.1 Backup Policy in Place"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Backup policy harus ada untuk MariaDB, termasuk mysql"
    echo "Deskripsi : Verifikasi bahwa terdapat kebijakan backup untuk MariaDB (misalnya mysqldump atau mariabackup) yang terjadwal di crontab."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
