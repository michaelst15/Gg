OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.2.1 - Memeriksa GRANTEE tidak sah yang memiliki privilege '%ANY%'" | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT GRANTEE || ':' || PRIVILEGE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE LIKE '%ANY%'
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
  VALUE="Tidak ada GRANTEE tidak sah yang memiliki privilege '%ANY%'"
else
  STATUS="Fail"
  VALUE="Ditemukan GRANTEE tidak sah:\n$RESULT"
fi
 
{
  echo "Judul Audit : 5.2.1 Ensure '%ANY%' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo -e "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : Grantee: DBADMIN, EMSMONDB, OWNIAC | Privilege: SELECT ANY DICTIONARY"
  echo "Deskripsi : Privilege '%ANY%' memberikan akses luas pada objek database. Hanya role/oracle user internal yang boleh memilikinya. Jika tidak, data sensitif dan struktur database bisa terancam oleh pengguna tidak sah."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"