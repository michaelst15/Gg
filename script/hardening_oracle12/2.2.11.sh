OUTPUT_FILE="audit_results.txt"

# Tulis header jika belum ada
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "===== ORACLE DATABASE CIS AUDIT RESULTS =====" > "$OUTPUT_FILE"
  echo "Generated on: $(date)" >> "$OUTPUT_FILE"
  echo "=============================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

echo "🔍 Memeriksa parameter 'SEC_CASE_SENSITIVE_LOGON'..."

# Eksekusi query untuk mengambil nilai parameter
VALUE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT UPPER(VALUE) FROM V\$PARAMETER WHERE UPPER(NAME) = 'SEC_CASE_SENSITIVE_LOGON';
EXIT;
EOF
)

# Bersihkan hasil dari spasi dan newline
VALUE=$(echo "$VALUE" | xargs)

# Evaluasi hasil
if [[ "$VALUE" == "TRUE" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.11 Ensure 'SEC_CASE_SENSITIVE_LOGON' Is Set to 'TRUE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS         : TRUE"
  echo "Deskripsi         : Parameter ini harus diaktifkan (TRUE) agar login memperhatikan huruf besar/kecil pada password, meningkatkan keamanan terhadap serangan brute-force."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
