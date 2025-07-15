SQLPLUS="sqlplus -s / as sysdba"
OUTPUT_FILE="audit_results.txt"

# --- Audit Informasi ---
AUDIT_ID="3.7 Ensure 'PASSWORD_VERIFY_FUNCTION' Is Set for All Profiles"
PARAMETER="PASSWORD_VERIFY_FUNCTION"

echo "Memeriksa parameter '$PARAMETER'..." | tee -a "$OUTPUT_FILE"

# --- Ambil data PASSWORD_VERIFY_FUNCTION ---
QUERY_RESULT=$($SQLPLUS <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SET LINESIZE 1000

SELECT PROFILE || ':' || LIMIT FROM DBA_PROFILES
WHERE RESOURCE_NAME = 'PASSWORD_VERIFY_FUNCTION';
EXIT;
EOF
)

QUERY_RESULT=$(echo "$QUERY_RESULT" | tr -d '\r' | sed '/^$/d')

STATUS="Pass"
DETAILS=""

echo "$QUERY_RESULT" | while IFS= read -r line; do
  PROFILE=$(echo "$line" | cut -d':' -f1 | xargs)
  LIMIT_RAW=$(echo "$line" | cut -d':' -f2 | xargs)
  LIMIT=$(echo "$LIMIT_RAW" | tr '[:lower:]' '[:upper:]')

  if [ "$LIMIT" = "NULL" ]; then
    STATUS="Fail"
    DETAILS="$DETAILS
- PROFILE '$PROFILE' tidak memiliki PASSWORD_VERIFY_FUNCTION yang ditentukan."
  elif [ "$LIMIT" = "DEFAULT" ]; then
    DEFAULT_LIMIT=$($SQLPLUS <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT LIMIT FROM DBA_PROFILES
WHERE PROFILE = 'DEFAULT' AND RESOURCE_NAME = 'PASSWORD_VERIFY_FUNCTION';
EXIT;
EOF
)
    DEFAULT_LIMIT=$(echo "$DEFAULT_LIMIT" | tr -d '\r' | sed '/^$/d' | tr '[:lower:]' '[:upper:]' | xargs)
    if [ "$DEFAULT_LIMIT" = "NULL" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- PROFILE '$PROFILE' menunjuk ke DEFAULT, namun DEFAULT bernilai NULL."
    fi
  fi
done

# --- Tulis ke File ---
{
  echo "Judul Audit : $AUDIT_ID"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi :"
  echo "$QUERY_RESULT"
  echo "Nilai CIS : Semua profil harus memiliki fungsi verifikasi password yang ditentukan (tidak NULL atau hanya DEFAULT yang NULL)"
  echo "Deskripsi : PASSWORD_VERIFY_FUNCTION menentukan aturan kompleksitas password. Harus diatur untuk mencegah penggunaan password lemah."
  echo "$DETAILS"
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
