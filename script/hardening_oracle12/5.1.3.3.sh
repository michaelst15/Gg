OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.1.3.3 - Memeriksa GRANTEE tidak sah pada tabel sensitif SYS" | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT GRANTEE || ':' || PRIVILEGE || ':' || TABLE_NAME FROM DBA_TAB_PRIVS
WHERE TABLE_NAME IN (
  'DEFAULT_PWD$', 'ENC$', 'LINK$', 'USER$', 'USER_HISTORY$', 'XS$VERIFIERS'
)
AND OWNER = 'SYS'
AND GRANTEE NOT IN (
  SELECT USERNAME FROM DBA_USERS WHERE ORACLE_MAINTAINED = 'Y'
)
AND GRANTEE NOT IN (
  SELECT ROLE FROM DBA_ROLES WHERE ORACLE_MAINTAINED = 'Y'
)
AND GRANTEE != 'RDSD';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Tidak ada GRANTEE tidak sah yang memiliki akses ke tabel sensitif"
else
  STATUS="Fail"
  VALUE="Ditemukan GRANTEE tidak sah:\n$RESULT"
fi
 
{
echo "Judul Audit : 5.1.3.3 Ensure 'ALL' Is Revoked on 'Sensitive' Tables"
  echo "Status : $STATUS"
  echo -e "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : SELECT privileges granted to RDSD role on the following tables: DEFAULT_PWD$, ENC$, LINK$, USER$, USER_HISTORY$, XS$VERIFIERS"
  echo "Deskripsi : Tabel-tabel ini menyimpan informasi sensitif seperti hash password, credential terenkripsi, atau informasi autentikasi. Hanya role resmi seperti RDSD yang boleh memiliki hak akses ke tabel ini."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"