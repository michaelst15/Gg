OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'SELECT ANY TABLE' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'SELECT ANY TABLE'
AND GRANTEE NOT IN (
  SELECT USERNAME FROM DBA_USERS WHERE ORACLE_MAINTAINED = 'Y'
)
AND GRANTEE NOT IN (
  SELECT ROLE FROM DBA_ROLES WHERE ORACLE_MAINTAINED = 'Y'
);
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Tidak ditemukan grantee tidak sah dengan 'SELECT ANY TABLE'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan 'SELECT ANY TABLE': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.6 Ensure 'SELECT ANY TABLE' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : SELECT ANY TABLE hanya boleh diberikan kepada entitas sah Oracle"
  echo "Deskripsi : SELECT ANY TABLE memberikan hak untuk membaca seluruh tabel di luar skema SYS. Ini memungkinkan pengambilan data sensitif dan seharusnya dibatasi hanya pada akun yang sah dan diperlukan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"