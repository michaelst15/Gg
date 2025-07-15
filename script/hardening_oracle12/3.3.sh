SQLPLUS="sqlplus -s / as sysdba"
OUTPUT_FILE="audit_results.txt"
 
# --- Informasi Audit ---
AUDIT_ID="3.3 Ensure 'PASSWORD_LIFE_TIME' Is Less than or Equal to '90'"
PARAMETER="PASSWORD_LIFE_TIME"
 
echo "Memeriksa parameter '$PARAMETER'..." | tee -a "$OUTPUT_FILE"
 
# --- Eksekusi Query Audit ---
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
        WHERE PROFILE = 'DEFAULT' AND RESOURCE_NAME = 'PASSWORD_LIFE_TIME'
      ),
      'UNLIMITED', '9999',
      LIMIT
    )
  ) AS RESULT
FROM DBA_PROFILES
WHERE RESOURCE_NAME = 'PASSWORD_LIFE_TIME'
AND TO_NUMBER(
  DECODE(
    LIMIT,
    'DEFAULT', (
      SELECT DECODE(LIMIT,'UNLIMITED', 9999, LIMIT)
      FROM DBA_PROFILES
      WHERE PROFILE = 'DEFAULT' AND RESOURCE_NAME = 'PASSWORD_LIFE_TIME'
    ),
    'UNLIMITED', '9999',
    LIMIT
  )
) > 90
AND EXISTS (
  SELECT 1 FROM DBA_USERS U WHERE U.PROFILE = DBA_PROFILES.PROFILE
);
EXIT;
EOF
)
 
# Bersihkan hasil
QUERY_RESULT=$(echo "$QUERY_RESULT" | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$QUERY_RESULT" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi
 
# Tulis hasil ke file
{
  echo "Judul Audit : $AUDIT_ID"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi (PROFILE:RESOURCE_NAME:LIMIT:VALUE_EFEKTIF):"
  echo "${QUERY_RESULT:-Tidak ada}"
  echo ""
  echo "Nilai CIS :"
  echo "- APPSPROFILE = UNLIMITED"
  echo "- DEFAULT = UNLIMITED"
  echo "- GSM_PROF = DEFAULT"
  echo ""
  echo "Deskripsi :"
  echo "PASSWORD_LIFE_TIME menentukan masa berlaku kata sandi sebelum harus diganti."
  echo "Password yang berlaku terlalu lama dapat meningkatkan risiko brute-force."
  echo "Nilai efektif 'UNLIMITED' dianggap sebagai 9999 untuk evaluasi."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"