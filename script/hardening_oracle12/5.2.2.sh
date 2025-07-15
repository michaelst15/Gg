OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.2.2 - Memeriksa GRANTEE tidak sah dengan ADMIN_OPTION = 'YES'" | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT GRANTEE || ':' || PRIVILEGE FROM DBA_SYS_PRIVS
WHERE ADMIN_OPTION = 'YES'
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
  VALUE="Tidak ditemukan GRANTEE tidak sah dengan ADMIN_OPTION = 'YES'"
else
  STATUS="Fail"
  VALUE="Ditemukan GRANTEE tidak sah:\n$RESULT"
fi
 
{
  echo "Judul Audit : 5.2.2 Ensure 'DBA_SYS_PRIVS.%' Is Revoked from Unauthorized 'GRANTEE' with 'ADMIN_OPTION' Set to 'YES'"
  echo "Status : $STATUS"
  echo -e "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : GRANTEE tidak boleh memiliki ADMIN_OPTION tanpa otorisasi"
  echo "Deskripsi : ADMIN_OPTION memungkinkan pengguna memberikan privilege tertentu kepada pengguna lain. Jika diberikan kepada pengguna tidak sah, ini dapat menyebabkan pelanggaran kontrol akses dan eskalasi hak istimewa."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"