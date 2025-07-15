SQLPLUS="sqlplus -s / as sysdba"
OUTPUT_FILE="audit_results.txt"
 
# --- Informasi Audit ---
PARAMETER="PASSWORD_GRACE_TIME"
 
echo "Memeriksa parameter '$PARAMETER'..." | tee -a "$OUTPUT_FILE"
 
# --- Ambil data untuk profil yang relevan ---
QUERY_RESULT=$($SQLPLUS <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SET LINESIZE 1000

SELECT PROFILE || ':' || LIMIT FROM DBA_PROFILES
WHERE RESOURCE_NAME = 'PASSWORD_GRACE_TIME'
AND PROFILE IN ('DEFAULT', 'GSM_PROF');
EXIT;
EOF
)
 
# Bersihkan hasil query
QUERY_RESULT=$(echo "$QUERY_RESULT" | tr -d '\r' | sed '/^$/d')

STATUS="Pass"
DETAILS=""

echo "$QUERY_RESULT" | while IFS= read -r line; do
  PROFILE=$(echo "$line" | cut -d':' -f1 | xargs)
  LIMIT_RAW=$(echo "$line" | cut -d':' -f2 | xargs)
  LIMIT=$(echo "$LIMIT_RAW" | tr '[:lower:]' '[:upper:]')

  if [ "$PROFILE" = "DEFAULT" ] && [ "$LIMIT" != "UNLIMITED" ]; then
    STATUS="Fail"
    DETAILS="$DETAILS
- PROFILE DEFAULT seharusnya UNLIMITED, tetapi nilainya: $LIMIT_RAW"
  elif [ "$PROFILE" = "GSM_PROF" ]; then
    if [ "$LIMIT" != "DEFAULT" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- PROFILE GSM_PROF seharusnya DEFAULT, tetapi nilainya: $LIMIT_RAW"
    fi
  fi
done

# --- Output ke file ---
{
  echo "Judul Audit : 3.6 Ensure 'PASSWORD_GRACE_TIME' is Compliant with CIS"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi :"
  echo "$QUERY_RESULT"
  echo "Nilai CIS :"
  echo "- DEFAULT = UNLIMITED"
  echo "- GSM_PROF = DEFAULT"
  echo "Deskripsi : Menentukan berapa lama (dalam hari) pengguna dapat login setelah password kedaluwarsa sebelum akun dikunci otomatis."
  echo "$DETAILS"
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
