OUTPUT_FILE="audit_results.txt"

# Direktori backup umum MariaDB (sesuaikan sesuai environment Anda)
BACKUP_DIRS=(
    "/var/backups/mariadb"
    "/backups/mariadb"
    "/srv/backups"
)

INSECURE_BACKUPS=""

for dir in "${BACKUP_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        # Cek permission direktori
        DIR_PERM=$(stat -c "%a" "$dir")
        DIR_OWNER=$(stat -c "%U:%G" "$dir")
        if [[ "$DIR_PERM" -gt 750 ]]; then
            INSECURE_BACKUPS+="Directory $dir has insecure permissions ($DIR_PERM, owner: $DIR_OWNER); "
        fi
        
        # Cek file di dalamnya
        while IFS= read -r file; do
            PERM=$(stat -c "%a" "$file")
            OWNER=$(stat -c "%U:%G" "$file")
            if [[ "$PERM" -gt 640 ]]; then
                INSECURE_BACKUPS+="File $file has insecure permissions ($PERM, owner: $OWNER); "
            fi
        done < <(find "$dir" -type f)
    fi
done

if [[ -n "$INSECURE_BACKUPS" ]]; then
    STATUS="Fail"
    VALUE="
Insecure backup files or directories found: 
$INSECURE_BACKUPS"
else
    STATUS="Pass"
    VALUE="All backup files and directories have secure permissions (≤750 for directories, ≤640 for files)"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.1.4 The Backups Should be Properly Secured"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Backup MariaDB harus dilindungi dengan permission aman (filesystem & enkripsi)"
    echo "Deskripsi : Verifikasi bahwa backup MariaDB dilindungi oleh hak akses dan/atau enkripsi untuk mencegah akses tidak sah."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
