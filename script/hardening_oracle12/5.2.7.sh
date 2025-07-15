OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa privilege 'AUDIT SYSTEM' pada grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'AUDIT SYSTEM'
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
  VALUE="Tidak ditemukan grantee tidak sah dengan privilege 'AUDIT SYSTEM'"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah dengan privilege 'AUDIT SYSTEM': $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.7 Ensure 'AUDIT SYSTEM' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 'AUDIT SYSTEM' hanya boleh diberikan kepada akun sistem yang sah"
  echo "Deskripsi : Privilege AUDIT SYSTEM memungkinkan pengguna untuk mengubah konfigurasi audit sistem. Akses ini harus dibatasi untuk mencegah penyembunyian aktivitas mencurigakan atau penghentian audit oleh pihak tidak berwenang."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"