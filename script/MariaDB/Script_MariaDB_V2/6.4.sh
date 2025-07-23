OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil semua variabel audit
AUDIT_VARS=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW VARIABLES LIKE '%audit%';" 2>/dev/null)

# Tentukan PASS/FAIL
if [[ -z "$AUDIT_VARS" ]]; then
    STATUS="FAIL"
    DETAILS="Audit plugin tidak terinstal atau tidak aktif."
elif ! echo "$AUDIT_VARS" | grep -q "ON"; then
    STATUS="FAIL"
    DETAILS="Audit plugin ditemukan tetapi tidak aktif atau tidak mengaudit connect events."
else
    DETAILS="Audit plugin aktif dengan konfigurasi berikut:\n$AUDIT_VARS"
fi

{
    echo "Judul Audit : 6.4 Ensure Audit Logging Is Enabled"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo "Nilai CIS : Audit logging harus diaktifkan untuk mencatat connect events dan (opsional) query/table events."
    echo "Deskripsi : Audit logging membantu mengidentifikasi siapa yang mengubah apa dan kapan, serta membantu investigasi keamanan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
