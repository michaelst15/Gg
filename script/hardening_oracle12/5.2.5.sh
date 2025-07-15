OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'SELECT ANY DICTIONARY' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'SELECT ANY DICTIONARY'
AND GRANTEE IN ('DBADMIN', 'EMSMONDB', 'OWNIAC', 'RDSD');
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Tidak ditemukan grantee tidak sah dengan 'SELECT ANY DICTIONARY'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan 'SELECT ANY DICTIONARY': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.5 Ensure 'SELECT ANY DICTIONARY' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : SELECT ANY DICTIONARY hanya boleh diberikan kepada grantee sah dan diperlukan"
  echo "Deskripsi : SELECT ANY DICTIONARY adalah privilege kuat yang memberikan akses ke metadata seluruh database, dan seharusnya tidak diberikan ke grantee tidak sah seperti DBADMIN, EMSMONDB, OWNIAC, atau RDSD."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"