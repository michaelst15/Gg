OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa role 'SELECT_CATALOG_ROLE' untuk grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE = 'SELECT_CATALOG_ROLE'
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
 
AUTHORIZED_GRANTEE="RPERF_DIAG"
 
# Mengecek jika hasil ditemukan dan bukan grantee yang sah
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Tidak ditemukan GRANTEE tidak sah dengan role SELECT_CATALOG_ROLE"
elif [[ "$RESULT" == "$AUTHORIZED_GRANTEE" ]]; then
  STATUS="Pass"
  VALUE="SELECT_CATALOG_ROLE hanya diberikan kepada grantee yang sah: $AUTHORIZED_GRANTEE"
else
  STATUS="Fail"
  VALUE="Ditemukan GRANTEE tidak sah dengan role SELECT_CATALOG_ROLE: $RESULT"
fi
 
{
  echo "Judul Audit : 5.3.2 Ensure 'SELECT_CATALOG_ROLE' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (Role hanya boleh diberikan kepada user yang secara resmi disetujui)"
  echo "Deskripsi : Role SELECT_CATALOG_ROLE memberikan akses SELECT ke seluruh data dictionary views dalam schema SYS. Pengguna tidak sah seharusnya tidak memiliki akses ini karena bisa mengungkapkan metadata penting dan konfigurasi internal database."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"