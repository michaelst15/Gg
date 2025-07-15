TXT_FILE="audit_results.txt"

# === CIS 4.3 ===
echo "🔍 CIS 4.3 - Ensure 'AUTHENTICATION_TYPE' Is Not Set to 'EXTERNAL' (with exceptions)" | tee -a "$TXT_FILE"

# Jalankan SQL query langsung
EXTERNAL_USERS_RAW=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET ECHO OFF
SELECT USERNAME FROM DBA_USERS WHERE AUTHENTICATION_TYPE = 'EXTERNAL';
EXIT;
EOF
)

EXTERNAL_USERS_RAW=$(echo "$EXTERNAL_USERS_RAW" | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//')

# Daftar user yang diperbolehkan pakai AUTHENTICATION_TYPE=EXTERNAL
ALLOWED_USERS="ORACLE ORACLEP OWNIAC OPSPWDID OWNDSD OWNDBCM"

STATUS="Pass"
CURRENT_VALUE=""
DETAILS=""

# Loop setiap user
echo "$EXTERNAL_USERS_RAW" | while IFS= read -r USERNAME; do
  UPPER_USER=$(echo "$USERNAME" | tr '[:lower:]' '[:upper:]')
  FOUND=0

  for ALLOWED in $ALLOWED_USERS; do
    if [ "$UPPER_USER" = "$ALLOWED" ]; then
      FOUND=1
      break
    fi
  done

  if [ "$FOUND" -ne 1 ]; then
    STATUS="Fail"
    DETAILS="${DETAILS}- $USERNAME (tidak diperbolehkan)\n"
  fi

  CURRENT_VALUE="${CURRENT_VALUE}${USERNAME},"
done

# Hapus koma di akhir
CURRENT_VALUE=$(echo "$CURRENT_VALUE" | sed 's/,$//')

# Simpan hasil audit ke file
{
  echo "Judul Audit : 4.3 Ensure 'AUTHENTICATION_TYPE' Is Not Set to 'EXTERNAL'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : ${CURRENT_VALUE:-Tidak ditemukan user dengan EXTERNAL AUTH}"
  echo "Nilai CIS : Hanya user berikut yang boleh menggunakan EXTERNAL authentication: ORACLE, ORACLEP, OWNIAC, OPSPWDID, OWNDSD, OWNDBCM"
  echo "Deskripsi : User dengan metode otentikasi EXTERNAL sangat berisiko, hanya software owner tertentu yang boleh menggunakannya. Semua user lainnya harus diubah."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$TXT_FILE"
