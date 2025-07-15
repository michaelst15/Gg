OUTPUT_FILE="audit_results.txt"

# Tulis header jika belum ada
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "===== ORACLE DATABASE CIS AUDIT RESULTS =====" > "$OUTPUT_FILE"
  echo "Generated on: $(date)" >> "$OUTPUT_FILE"
  echo "=============================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

echo "🔍 Memeriksa parameter 'SEC_RETURN_SERVER_RELEASE_BANNER'..." | tee -a "$OUTPUT_FILE"

# Jalankan SQL untuk mengambil nilai parameter
VALUE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SELECT UPPER(VALUE) FROM V\$PARAMETER WHERE UPPER(NAME) = 'SEC_RETURN_SERVER_RELEASE_BANNER';
EXIT;
EOF
)

# Bersihkan hasil dari whitespace
VALUE=$(echo "$VALUE" | xargs)

# Evaluasi hasil audit
if [[ "$VALUE" == "FALSE" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi

# Simpan hasil ke file audit
{
  echo "Judul Audit       : 2.2.15 Ensure 'SEC_RETURN_SERVER_RELEASE_BANNER' Is Set to 'FALSE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : ${VALUE:-null}"
  echo "Nilai CIS         : FALSE"
  echo "Deskripsi         : Menyembunyikan informasi patch/release Oracle saat koneksi client untuk menghindari pengungkapan versi ke pihak tak sah yang bisa mengeksploitasi celah tertentu."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
