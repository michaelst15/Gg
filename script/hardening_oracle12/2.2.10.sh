OUTPUT_FILE="audit_results.txt"

# Tulis header jika belum ada
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "===== ORACLE DATABASE CIS AUDIT RESULTS =====" > "$OUTPUT_FILE"
  echo "Generated on: $(date)" >> "$OUTPUT_FILE"
  echo "=============================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

echo "🔍 Memeriksa parameter 'UTL_FILE_DIR'..."

# Jalankan SQL secara silent
VALUE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SET TRIMSPOOL ON
SELECT VALUE FROM V\$PARAMETER WHERE UPPER(NAME) = 'UTL_FILE_DIR';
EXIT;
EOF
)

# Bersihkan hasil
VALUE=$(echo "$VALUE" | tr -d '\r' | xargs)

# Evaluasi hasil
if [[ -z "$VALUE" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.10 Ensure 'UTL_FILE_DIR' Is Empty"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : ${VALUE:-''} (kosong jika Pass)"
  echo "Nilai CIS         : 0"
  echo "Deskripsi         : Parameter ini harus dikosongkan untuk mencegah akses tidak aman ke file sistem menggunakan package UTL_FILE."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
