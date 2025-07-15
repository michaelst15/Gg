OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa parameter 'AUDIT_SYS_OPERATIONS'..."

# Jalankan query melalui sqlplus dalam mode silent
AUDIT_RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SET TRIMSPOOL ON
SELECT UPPER(VALUE) FROM V\$PARAMETER WHERE UPPER(NAME) = 'AUDIT_SYS_OPERATIONS';
EXIT;
EOF
)

# Bersihkan hasil output dari karakter tambahan
AUDIT_RESULT=$(echo "$AUDIT_RESULT" | tr -d '\r' | xargs)

# Evaluasi nilai parameter
if [[ "$AUDIT_RESULT" == "TRUE" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.1 Ensure 'AUDIT_SYS_OPERATIONS' Is Set to 'TRUE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $AUDIT_RESULT"
  echo "Nilai CIS         : TRUE"
  echo "Deskripsi         : AUDIT_SYS_OPERATIONS memastikan audit dilakukan terhadap semua aktivitas pengguna SYSOPER dan SYSDBA."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
