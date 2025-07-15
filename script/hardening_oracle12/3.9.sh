TXT_FILE="audit_results.txt"

# Header jika file belum ada
if [ ! -f "$TXT_FILE" ]; then
  echo "===== ORACLE DATABASE CIS AUDIT RESULTS =====" > "$TXT_FILE"
  echo "Generated on: $(date)" >> "$TXT_FILE"
  echo "=============================================" >> "$TXT_FILE"
  echo "" >> "$TXT_FILE"
fi

# === CIS 3.9 ===
echo "CIS 3.9 - Ensure 'INACTIVE_ACCOUNT_TIME' Is Less Than or Equal to 120" | tee -a "$TXT_FILE"

# Jalankan query langsung dengan heredoc
RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET ECHO OFF
SELECT PROFILE || ':' || LIMIT
FROM DBA_PROFILES
WHERE RESOURCE_NAME = 'INACTIVE_ACCOUNT_TIME'
AND PROFILE IN ('DEFAULT', 'GSM_PROF', 'APPSPROFILE');
EXIT;
EOF
)

# Bersihkan hasil
RESULT=$(echo "$RESULT" | tr -d '\r' | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//')

STATUS="Pass"
DETAILS=""

echo "$RESULT" | while IFS= read -r line; do
  PROFILE=$(echo "$line" | cut -d':' -f1 | xargs)
  LIMIT=$(echo "$line" | cut -d':' -f2 | xargs | tr '[:lower:]' '[:upper:]')

  if [ "$PROFILE" = "DEFAULT" ]; then
    if [ "$LIMIT" != "UNLIMITED" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- DEFAULT seharusnya UNLIMITED, ditemukan: $LIMIT"
    fi
  elif [ "$PROFILE" = "GSM_PROF" ] || [ "$PROFILE" = "APPSPROFILE" ]; then
    if [ "$LIMIT" != "DEFAULT" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- $PROFILE seharusnya DEFAULT, ditemukan: $LIMIT"
    fi
  fi
done

# Buat output nilai konfigurasi sebagai string ringkas
CURRENT_VALUE=$(echo "$RESULT" | tr '\n' ',' | sed 's/,$//')

# Tulis ke file hasil audit
{
  echo "Judul Audit : 3.9 Ensure 'INACTIVE_ACCOUNT_TIME' Is Less Than or Equal to 120"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $CURRENT_VALUE"
  echo "Nilai CIS :"
  echo "- DEFAULT = UNLIMITED"
  echo "- GSM_PROF = DEFAULT"
  echo "- APPSPROFILE = DEFAULT"
  echo "Deskripsi : Pastikan akun nonaktif dikunci setelah 120 hari atau kurang, kecuali nilai profil sesuai kebijakan organisasi."
  echo "$DETAILS"
  echo "-------------------------------------------------------------"
  echo ""
} >> "$TXT_FILE"
