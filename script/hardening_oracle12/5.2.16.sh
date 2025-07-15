OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'GRANT ANY PRIVILEGE' untuk grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'GRANT ANY PRIVILEGE'
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
  VALUE="Tidak ditemukan GRANTEE tidak sah dengan privilege GRANT ANY PRIVILEGE"
else
  STATUS="Fail"
  VALUE="Ditemukan GRANTEE tidak sah dengan privilege GRANT ANY PRIVILEGE: $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.16 Ensure 'GRANT ANY PRIVILEGE' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (Privilege ini hanya boleh dimiliki jika benar-benar dibutuhkan secara fungsional oleh user resmi)"
  echo "Deskripsi : Privilege GRANT ANY PRIVILEGE memungkinkan pemberian hak istimewa secara luas ke objek di seluruh database. Privilege ini harus dibatasi hanya untuk user yang sah dan sangat terpercaya, karena bisa menyebabkan potensi eskalasi hak akses dan kebocoran data."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"