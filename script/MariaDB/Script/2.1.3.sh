OUTPUT_FILE="audit_results.txt"

# Daftar file kredensial backup yang umum digunakan (sesuaikan sesuai environment Anda)
CREDENTIAL_FILES=(
    "/etc/mysql/backup.cnf"
    "/root/.my.cnf"
    "/etc/mysql/ssl/client-key.pem"
)

INSECURE_FILES=""

for file in "${CREDENTIAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        PERMS=$(stat -c "%a" "$file")
        OWNER=$(stat -c "%U" "$file")
        if [[ "$PERMS" -gt 600 || "$OWNER" != "root" ]]; then
            INSECURE_FILES+="$file (perm: $PERMS, owner: $OWNER); "
        fi
    fi
done

if [[ -n "$INSECURE_FILES" ]]; then
    STATUS="Fail"
    VALUE="Insecure backup credential files found: $INSECURE_FILES"
else
    STATUS="Pass"
    VALUE="All backup credential files are properly secured (600 or stricter, owned by root)"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.1.3 Secure Backup Credentials"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : File kredensial backup harus dilindungi (izin <= 600 dan dimiliki root)"
    echo "Deskripsi : Verifikasi bahwa file password, sertifikat, dan kredensial backup MariaDB terlindungi dengan hak akses minimal."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
