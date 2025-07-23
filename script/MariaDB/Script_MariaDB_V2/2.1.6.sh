OUTPUT_FILE="audit_results.txt"

# Lokasi default untuk dokumen DR Plan (ubah sesuai environment Anda)
DR_PLAN_FILES=(
    "/etc/mysql/DR_Plan.md"
    "/etc/mysql/DR_Plan.pdf"
    "/var/backups/mariadb/DR_Plan.txt"
)

FOUND_PLAN=""

for file in "${DR_PLAN_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        FOUND_PLAN+="$file "
    fi
done

if [[ -n "$FOUND_PLAN" ]]; then
    STATUS="Pass"
    VALUE="
Disaster Recovery Plan found: 
$FOUND_PLAN"
else
    STATUS="Fail"
    VALUE="No documented Disaster Recovery Plan found"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.1.6 Disaster Recovery (DR) Plan"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : DR Plan harus ada untuk MariaDB (meliputi RTO, kapasitas recovery site, dan offsite backup/replication)"
    echo "Deskripsi : Verifikasi bahwa DR Plan terdokumentasi dengan baik, mencakup strategi pemulihan, RTO, enkripsi, dan replika offsite untuk MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
