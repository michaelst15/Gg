OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.1.3.2 - Memeriksa GRANTEE tidak sah pada view SYS.DBA_%" | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT GRANTEE || ':' || TABLE_NAME FROM DBA_TAB_PRIVS
WHERE TABLE_NAME LIKE 'DBA_%'
AND OWNER = 'SYS'
AND GRANTEE NOT IN (
  SELECT USERNAME FROM DBA_USERS WHERE ORACLE_MAINTAINED = 'Y'
)
AND GRANTEE NOT IN (
  SELECT ROLE FROM DBA_ROLES WHERE ORACLE_MAINTAINED = 'Y'
)
AND (GRANTEE != 'RDSDAUD' OR TABLE_NAME NOT IN ('DBA_AUDIT_TRAIL', 'DBA_COMMON_AUDIT_TRAIL'));
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Tidak ada GRANTEE tidak sah pada view DBA_%"
else
  STATUS="Fail"
  VALUE="Ditemukan GRANTEE tidak sah:\n$RESULT"
fi
 
# Simpan hasil audit ke file
{
echo "Judul Audit : 5.1.3.2 Ensure 'ALL' Is Revoked from Unauthorized 'GRANTEE' on 'DBA_%'"
  echo "Status : $STATUS"
  echo -e "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : SELECT privileges granted to: RDSDAUD.DBA_AUDIT_TRAIL, RDSDAUD.DBA_COMMON_AUDIT_TRAIL"
  echo "Deskripsi : View DBA_% menampilkan informasi administratif sensitif. Hanya role internal atau sistem audit resmi yang boleh mengaksesnya untuk mencegah kebocoran data administratif."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"