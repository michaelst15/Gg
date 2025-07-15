SQLPLUS="sqlplus -s / as sysdba"
OUTPUT_FILE="audit_results.txt"
 
# --- Informasi Audit ---
AUDIT_ID="3.4 Ensure 'PASSWORD_REUSE_MAX' Is Greater than or Equal to '5'"
PARAMETER="PASSWORD_REUSE_MAX"
EXPECTED_LIMIT=5
 
echo "Memeriksa parameter '$PARAMETER'..." | tee -a "$OUTPUT_FILE"
 
# --- Eksekusi Query Audit ---
QUERY_RESULT=$($SQLPLUS <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 1000

SELECT PROFILE || ':' || LIMIT FROM DBA_PROFILES 
WHERE RESOURCE_NAME = 'PASSWORD_REUSE_MAX' 
AND PROFILE IN ('APPSPROFILE', 'USERPROFILE');
EXIT;
EOF
)
 
# Bersihkan hasil
QUERY_RESULT=$(echo "$QUERY_RESULT" | tr -d '\r' | sed '/^$/d')

STATUS="Pass"
DETAILS=""

echo "$QUERY_RESULT" | while IFS= read -r line; do
  PROFILE=$(echo "$line" | cut -d':' -f1 | xargs)
  LIMIT_RAW=$(echo "$line" | cut -d':' -f2 | xargs)
  LIMIT_UPPER=$(echo "$LIMIT_RAW" | tr '[:lower:]' '[:upper:]')

  if [ "$LIMIT_UPPER" = "UNLIMITED" ]; then
    STATUS="Fail"
    DETAILS="$DETAILS
- PROFILE $PROFILE seharusnya >= $EXPECTED_LIMIT, tetapi nilainya: UNLIMITED"
  else
    IS_NUMBER=$(echo "$LIMIT_RAW" | grep -E '^[0-9]+$')
    if [ -n "$IS_NUMBER" ] && [ "$LIMIT_RAW" -lt "$EXPECTED_LIMIT" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- PROFILE $PROFILE seharusnya >= $EXPECTED_LIMIT, tetapi nilainya: $LIMIT_RAW"
    fi
  fi
done

# --- Output Hasil Audit ke File ---
{
  echo "Judul Audit : $AUDIT_ID"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi :"
  echo "$QUERY_RESULT"
  echo "Nilai CIS :"
  echo "- APPSPROFILE = 5"
  echo "- USERPROFILE = 5"
  echo "Deskripsi : Menentukan jumlah kata sandi berbeda yang harus digunakan sebelum pengguna dapat menggunakan kembali kata sandi sebelumnya."
  echo "$DETAILS"
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
