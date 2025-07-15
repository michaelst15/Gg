OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'CREATE PROCEDURE' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'CREATE PROCEDURE'
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
  VALUE="Tidak ditemukan grantee tidak sah dengan privilege 'CREATE PROCEDURE'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan privilege 'CREATE PROCEDURE': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.10 Ensure 'CREATE PROCEDURE' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 'CREATE PROCEDURE' hanya boleh diberikan kepada akun schema yang sah seperti EMSMONDB XXX"
  echo "Deskripsi : Privilege ini memungkinkan pengguna membuat prosedur tersimpan, yang jika tidak diawasi bisa digunakan untuk menjalankan kode berbahaya, pencurian data, atau merusak data."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"