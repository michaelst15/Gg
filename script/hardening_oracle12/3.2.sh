SQLPLUS="sqlplus -s / as sysdba"
OUTPUT_FILE="audit_results.txt"
 
# --- Informasi Audit ---
AUDIT_ID="3.2 Ensure 'PASSWORD_LOCK_TIME' Is Greater than or Equal to '1'"
PARAMETER="PASSWORD_LOCK_TIME"
 
echo "Memeriksa parameter '$PARAMETER'..." | tee -a "$OUTPUT_FILE"
 
# --- Eksekusi Query Audit: nilai efektif < 1 dianggap tidak sesuai ---
QUERY_RESULT=$($SQLPLUS <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 1000
 
SELECT PROFILE || ':' || RESOURCE_NAME || ':' || LIMIT || ':' ||
  TO_NUMBER(
    DECODE(
      LIMIT,
      'DEFAULT', (
        SELECT DECODE(LIMIT,'UNLIMITED', 9999, LIMIT)
        FROM DBA_PROFILES
        WHERE PROFILE = 'DEFAULT' AND RESOURCE_NAME = 'PASSWORD_LOCK_TIME'
      ),
      'UNLIMITED', '9999',
      LIMIT
    )
  )
FROM DBA_PROFILES
WHERE RESOURCE_NAME = 'PASSWORD_LOCK_TIME'
AND TO_NUMBER(
  DECODE(
    LIMIT,
    'DEFAULT', (
      SELECT DECODE(LIMIT,'UNLIMITED', 9999, LIMIT)
      FROM DBA_PROFILES
      WHERE PROFILE = 'DEFAULT' AND RESOURCE_NAME = 'PASSWORD_LOCK_TIME'
    ),
    'UNLIMITED', '9999',
    LIMIT
  )
) < 1
AND EXISTS (
  SELECT 1 FROM DBA_USERS U WHERE U.PROFILE = DBA_PROFILES.PROFILE
);
 
EXIT;
EOF
)
 
# Bersihkan hasil
QUERY_RESULT=$(echo "$QUERY_RESULT" | sed '/^$/d')
 
# Tentukan status
if [[ -z "$QUERY_RESULT" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi
 
# --- Output Hasil Audit ke File ---
{
  echo "Judul Audit : $AUDIT_ID"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi :"
  echo "${QUERY_RESULT:-Tidak ada}"
  echo ""
  echo "Nilai CIS :"
  echo "DEFAULT = UNLIMITED"
  echo "USERPROFILE = UNLIMITED"
  echo ""
  echo "Deskripsi :"
  echo "Parameter ini menentukan durasi akun terkunci setelah sejumlah kegagalan login terjadi."
  echo "Direkomendasikan disetel ≥ 1 (dalam satuan hari) untuk menghindari serangan brute-force."
  echo "Nilai DEFAULT/UNLIMITED diturunkan ke nilai efektif: UNLIMITED dianggap sebagai 9999."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"