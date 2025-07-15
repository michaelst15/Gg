OUTPUT_FILE="audit_results.txt"

# Tulis header jika belum ada
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "===== ORACLE DATABASE CIS AUDIT RESULTS =====" > "$OUTPUT_FILE"
  echo "Generated on: $(date)" >> "$OUTPUT_FILE"
  echo "=============================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

echo "🔍 Memeriksa parameter 'SEC_PROTOCOL_ERROR_FURTHER_ACTION'..." | tee -a "$OUTPUT_FILE"

# Jalankan query SQL
VALUE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT UPPER(VALUE) FROM V\$PARAMETER WHERE UPPER(NAME) = 'SEC_PROTOCOL_ERROR_FURTHER_ACTION';
EXIT;
EOF
)

# Bersihkan output
VALUE=$(echo "$VALUE" | xargs)

# Evaluasi hasil: Harus persis "DROP,3"
if [[ "$VALUE" == "DROP,3" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.13 Ensure 'SEC_PROTOCOL_ERROR_FURTHER_ACTION' Is Set to 'DROP,3'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : ${VALUE:-null}"
  echo "Nilai CIS         : DROP,3"
  echo "Deskripsi         : Parameter ini menentukan tindakan server saat menerima paket klien yang rusak. Nilai DROP,3 akan memutus koneksi setelah 3 kesalahan, untuk mencegah potensi serangan berbasis jaringan seperti TCP SYN Flood atau Smurf."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
