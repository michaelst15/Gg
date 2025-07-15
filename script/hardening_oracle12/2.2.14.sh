OUTPUT_FILE="audit_results.txt"

# Tulis header jika belum ada
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "===== ORACLE DATABASE CIS AUDIT RESULTS =====" > "$OUTPUT_FILE"
  echo "Generated on: $(date)" >> "$OUTPUT_FILE"
  echo "=============================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

echo "🔍 Memeriksa parameter 'SEC_PROTOCOL_ERROR_TRACE_ACTION'..." | tee -a "$OUTPUT_FILE"

# Jalankan query SQL untuk mendapatkan nilai parameter
VALUE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SELECT UPPER(VALUE) FROM V\$PARAMETER WHERE UPPER(NAME) = 'SEC_PROTOCOL_ERROR_TRACE_ACTION';
EXIT;
EOF
)

# Bersihkan hasil (hapus whitespace dan ubah ke huruf besar)
VALUE=$(echo "$VALUE" | xargs)

# Evaluasi hasil: Harus "LOG"
if [[ "$VALUE" == "LOG" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.14 Ensure 'SEC_PROTOCOL_ERROR_TRACE_ACTION' Is Set to 'LOG'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : ${VALUE:-null}"
  echo "Nilai CIS         : LOG"
  echo "Deskripsi         : Parameter ini mengatur level logging untuk paket protokol rusak dari klien. Nilai LOG disarankan agar aktivitas mencurigakan dicatat tanpa membanjiri log."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
