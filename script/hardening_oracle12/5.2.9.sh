OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'BECOME USER' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'BECOME USER'
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
  VALUE="Tidak ditemukan grantee tidak sah dengan privilege 'BECOME USER'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan privilege 'BECOME USER': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.9 Ensure 'BECOME USER' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 'BECOME USER' hanya boleh diberikan ke akun yang sah seperti SYS atau DBA otorisasi"
  echo "Deskripsi : Privilege ini memungkinkan pengguna menjalankan sesi sebagai pengguna lain, memungkinkan akses yang tidak sah terhadap objek dan data jika tidak dibatasi dengan benar."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"