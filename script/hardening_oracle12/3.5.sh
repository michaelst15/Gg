SQLPLUS="sqlplus -s / as sysdba"
OUTPUT_FILE="audit_results.txt"
 
# --- Informasi Audit ---
AUDIT_ID="3.5 Ensure 'PASSWORD_REUSE_TIME' Is Greater than or Equal to '90'"
PARAMETER="PASSWORD_REUSE_TIME"
EXPECTED_LIMIT=90
 
echo "Memeriksa parameter '$PARAMETER'..." | tee -a "$OUTPUT_FILE"
 
# --- Eksekusi Query Audit ---
QUERY_RESULT=$($SQLPLUS <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 1000

SELECT PROFILE || ':' || LIMIT FROM DBA_PROFILES 
WHERE RESOURCE_NAME = 'PASSWORD_REUSE_TIME' 
AND PROFILE IN ('APPSPROFILE', 'USERPROFILE');
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
  LIMIT_UPPER=$(echo "$LIMIT_RAW" | tr '[:lower:]' '[:upper:]')

  if [ "$LIMIT_UPPER" = "UNLIMITED" ]; then
    STATUS="Fail"
    DETAILS="$DETAILS
- PROFILE $PROFILE seharusnya >= $EXPECTED_LIMIT hari, tetapi nilainya: UNLIMITED"
  else
    IS_NUMBER=$(echo "$LIMIT_RAW" | grep -E '^[0-9]+$')
    if [ -z "$IS_NUMBER" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- PROFILE $PROFILE memiliki nilai tidak valid: $LIMIT_RAW"
    elif [ "$LIMIT_RAW" -lt "$EXPECTED_LIMIT" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- PROFILE $PROFILE seharusnya >= $EXPECTED_LIMIT hari, tetapi nilainya: $LIMIT_RAW"
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
  echo "- APPSPROFILE - 90"
  echo "- USERPROFILE - 90"
  echo "Deskripsi : Menentukan jumlah hari yang harus berlalu sebelum password lama bisa digunakan kembali."
  echo "$DETAILS"
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
