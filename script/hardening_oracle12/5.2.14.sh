OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'GRANT ANY OBJECT PRIVILEGE' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'GRANT ANY OBJECT PRIVILEGE'
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
  VALUE="Tidak ditemukan grantee tidak sah dengan privilege 'GRANT ANY OBJECT PRIVILEGE'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan privilege 'GRANT ANY OBJECT PRIVILEGE': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.14 Ensure 'GRANT ANY OBJECT PRIVILEGE' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 'GRANT ANY OBJECT PRIVILEGE' hanya boleh diberikan kepada akun administratif yang sah"
  echo "Deskripsi : Privilege ini memungkinkan pengguna memberikan akses ke objek apa pun di dalam katalog database. Jika diberikan ke pengguna yang tidak sah, maka dapat menimbulkan risiko serius seperti akses tidak sah ke data sensitif atau kerusakan terhadap struktur objek database."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"