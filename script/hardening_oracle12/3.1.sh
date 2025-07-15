SQLPLUS="sqlplus -s / as sysdba"
OUTPUT_FILE="audit_results.txt"
 
echo "Memeriksa parameter 'FAILED_LOGIN_ATTEMPTS'..." | tee -a "$OUTPUT_FILE"
 
# Ambil hasil audit: profil yang memiliki nilai efektif FAILED_LOGIN_ATTEMPTS > 5
QUERY_RESULT=$($SQLPLUS <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 1000
 
SELECT
  PROFILE || ':' || RESOURCE_NAME || ':' || LIMIT || ':' ||
  TO_NUMBER(
    DECODE(
      LIMIT,
      'DEFAULT', (
        SELECT DECODE(LIMIT, 'UNLIMITED', 9999, LIMIT)
        FROM DBA_PROFILES
        WHERE PROFILE = 'DEFAULT' AND RESOURCE_NAME = 'FAILED_LOGIN_ATTEMPTS'
      ),
      'UNLIMITED', '9999',
      LIMIT
    )
  ) AS RESULT
FROM DBA_PROFILES
WHERE RESOURCE_NAME = 'FAILED_LOGIN_ATTEMPTS'
AND TO_NUMBER(
    DECODE(
      LIMIT,
      'DEFAULT', (
        SELECT DECODE(LIMIT, 'UNLIMITED', 9999, LIMIT)
        FROM DBA_PROFILES
        WHERE PROFILE = 'DEFAULT' AND RESOURCE_NAME = 'FAILED_LOGIN_ATTEMPTS'
      ),
      'UNLIMITED', '9999',
      LIMIT
    )
) > 5
AND EXISTS (
  SELECT 1 FROM DBA_USERS U WHERE U.PROFILE = DBA_PROFILES.PROFILE
);
 
EXIT;
EOF
)
 
# Bersihkan baris kosong
QUERY_RESULT=$(echo "$QUERY_RESULT" | sed '/^$/d')
 
# Tentukan status audit
if [[ -z "$QUERY_RESULT" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi
 
# Tulis hasil ke file output
{
  echo "Judul Audit : 3.1 Ensure 'FAILED_LOGIN_ATTEMPTS' Is Less than or Equal to '5'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi :"
  echo "${QUERY_RESULT:-Tidak ada}"
  echo ""
  echo "Nilai CIS :"
  echo "APPSPROFILE = DEFAULT"
  echo "DEFAULT = UNLIMITED"
  echo "GSM_PROF = 10000000"
  echo ""
  echo "Deskripsi :"
  echo "Parameter ini menentukan jumlah maksimum percobaan login gagal sebelum akun dikunci."
  echo "Nilai 'DEFAULT' akan mengacu pada profil DEFAULT, dan 'UNLIMITED' dianggap sebagai 9999."
  echo "Nilai FAILED_LOGIN_ATTEMPTS disarankan ≤ 5 untuk mencegah brute-force login attack."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"