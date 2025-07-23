OUTPUT_FILE="audit_results.txt"

# Lokasi default untuk log verifikasi backup (ubah sesuai kebijakan backup di sistem Anda)
BACKUP_VALIDATION_LOG="/var/log/mariadb_backup_validation.log"

if [[ -f "$BACKUP_VALIDATION_LOG" ]]; then
    LAST_CHECK=$(tail -n 5 "$BACKUP_VALIDATION_LOG" | grep -i "success\|verified")
    if [[ -n "$LAST_CHECK" ]]; then
        STATUS="Pass"
        VALUE="Backup validation reports found and indicate success"
    else
        STATUS="Fail"
        VALUE="Backup validation log exists but no recent successful validation found"
    fi
else
    STATUS="Fail"
    VALUE="No backup validation reports found"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.1.2 Verify Backups are Good"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Backup harus divalidasi secara berkala untuk memastikan integritas data"
    echo "Deskripsi : Verifikasi bahwa backup MariaDB telah diuji dan laporan validasi tersedia untuk memastikan pemulihan data yang andal."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
