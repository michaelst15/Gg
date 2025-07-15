OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'ALTER SYSTEM' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'ALTER SYSTEM'
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
  VALUE="Tidak ditemukan grantee tidak sah dengan privilege 'ALTER SYSTEM'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan privilege 'ALTER SYSTEM': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.11 Ensure 'ALTER SYSTEM' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 'ALTER SYSTEM' hanya boleh diberikan kepada akun administratif yang sah"
  echo "Deskripsi : Privilege ALTER SYSTEM memungkinkan perubahan langsung terhadap parameter instansi database. Jika disalahgunakan, bisa menyebabkan kerusakan sistem, seperti menghentikan redo log atau mematikan sesi penting."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"