OUTPUT_FILE="audit_results.txt"

# Daftar file dan direktori penting untuk MariaDB yang seharusnya di-backup
CONFIG_FILES=(
    "/etc/mysql/my.cnf"
    "/etc/mysql/mariadb.cnf"
    "/etc/mysql/conf.d/"
    "/var/lib/mysql-keyring/"
    "/var/log/mysql/"
    "/etc/mysql/ssl/"
    "/usr/lib/mysql/plugin/" # untuk UDF (User Defined Functions)
    "/opt/mariadb/custom/"   # direktori khusus untuk custom code (ubah sesuai environment)
)

MISSING_FILES=""

for item in "${CONFIG_FILES[@]}"; do
    if [[ -e "$item" ]]; then
        BACKUP_IN_LIST=$(grep -F "$item" /var/backups/backup_file_list.txt 2>/dev/null)
        if [[ -z "$BACKUP_IN_LIST" ]]; then
            MISSING_FILES+="$item "
        fi
    fi
done

if [[ -n "$MISSING_FILES" ]]; then
    STATUS="Fail"
    VALUE="These critical MariaDB files are not confirmed in backup: $MISSING_FILES"
else
    STATUS="Pass"
    VALUE="All critical MariaDB configuration, key, and log files are included in backup"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.1.7 Backup of Configuration and Related Files"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Semua file konfigurasi, log, key, sertifikat, UDF, dan custom code MariaDB harus termasuk dalam backup"
    echo "Deskripsi : Verifikasi bahwa semua file konfigurasi penting, key management, audit log, SSL, dan custom code MariaDB sudah termasuk dalam backup."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
