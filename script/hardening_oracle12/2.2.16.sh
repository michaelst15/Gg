OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa parameter 'SQL92_SECURITY'..." | tee -a "$OUTPUT_FILE"

# Eksekusi SQL untuk membaca nilai parameter SQL92_SECURITY
VALUE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SELECT VALUE FROM V\$PARAMETER WHERE UPPER(NAME) = 'SQL92_SECURITY';
EXIT;
EOF
)

# Bersihkan output
VALUE=$(echo "$VALUE" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')

# Evaluasi hasil
if [[ "$VALUE" == "TRUE" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi

# Simpan hasil audit ke file output
{
  echo "Judul Audit       : 2.2.16 Ensure 'SQL92_SECURITY' Is Set to 'TRUE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : ${VALUE:-null}"
  echo "Nilai CIS         : TRUE"
  echo "Deskripsi         : Parameter ini mewajibkan pengguna memiliki hak SELECT sebelum dapat menggunakan kolom dalam klausa WHERE/SET pada UPDATE atau DELETE, guna mencegah pengungkapan informasi tidak sah melalui inferensi query."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
