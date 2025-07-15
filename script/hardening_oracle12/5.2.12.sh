OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'CREATE ANY LIBRARY' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'CREATE ANY LIBRARY'
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
  VALUE="Tidak ditemukan grantee tidak sah dengan privilege 'CREATE ANY LIBRARY'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan privilege 'CREATE ANY LIBRARY': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.12 Ensure 'CREATE ANY LIBRARY' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 'CREATE ANY LIBRARY' hanya boleh diberikan kepada akun administratif yang sah"
  echo "Deskripsi : Privilege ini memungkinkan pengguna membuat objek yang terkait dengan shared library. Jika diberikan ke pihak tidak sah, bisa dimanfaatkan untuk menjalankan kode sistem atau korupsi library internal."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"