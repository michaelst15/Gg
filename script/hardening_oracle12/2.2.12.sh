OUTPUT_FILE="audit_results.txt"

# Tulis header jika belum ada
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "===== ORACLE DATABASE CIS AUDIT RESULTS =====" > "$OUTPUT_FILE"
  echo "Generated on: $(date)" >> "$OUTPUT_FILE"
  echo "=============================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

echo "🔍 Memeriksa parameter 'SEC_MAX_FAILED_LOGIN_ATTEMPTS'..."

# Eksekusi SQL untuk mendapatkan nilai parameter
VALUE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT VALUE FROM V\\$PARAMETER WHERE UPPER(NAME) = 'SEC_MAX_FAILED_LOGIN_ATTEMPTS';
EXIT;
EOF
)

# Hapus karakter aneh & spasi
VALUE=$(echo "$VALUE" | tr -d '\r' | xargs)

# Evaluasi hasil
STATUS="Fail"
# Periksa apakah VALUE adalah angka dan <= 3
if echo "$VALUE" | grep -Eq '^[0-9]+$'; then
  if [ "$VALUE" -le 3 ]; then
    STATUS="Pass"
  fi
fi

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.12 Ensure 'SEC_MAX_FAILED_LOGIN_ATTEMPTS' Is '3' or Less"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS         : 3 atau kurang"
  echo "Deskripsi         : Parameter ini menentukan berapa kali login gagal yang diizinkan sebelum koneksi ditutup. Disarankan maksimal 3 untuk mencegah brute-force atau denial-of-service."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
