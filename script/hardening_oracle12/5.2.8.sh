OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'EXEMPT ACCESS POLICY' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'EXEMPT ACCESS POLICY'
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
  VALUE="Tidak ditemukan grantee tidak sah dengan privilege 'EXEMPT ACCESS POLICY'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan privilege 'EXEMPT ACCESS POLICY': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.8 Ensure 'EXEMPT ACCESS POLICY' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 'EXEMPT ACCESS POLICY' hanya boleh diberikan ke akun yang berwenang"
  echo "Deskripsi : Privilege ini memungkinkan pengguna melewati kebijakan kontrol akses baris (RLS/VPD). Hak istimewa ini harus sangat dibatasi karena memungkinkan pengaksesan semua baris tabel tanpa pembatasan keamanan data baris."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"