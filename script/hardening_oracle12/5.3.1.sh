OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa role 'DELETE_CATALOG_ROLE' untuk grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE = 'DELETE_CATALOG_ROLE'
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
  VALUE="Tidak ditemukan GRANTEE tidak sah dengan role DELETE_CATALOG_ROLE"
else
  STATUS="Fail"
  VALUE="Ditemukan GRANTEE tidak sah dengan role DELETE_CATALOG_ROLE: $RESULT"
fi
 
{
  echo "Judul Audit : 5.3.1 Ensure 'DELETE_CATALOG_ROLE' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (Role ini tidak boleh diberikan kecuali sangat dibutuhkan secara resmi dan terbatas)"
  echo "Deskripsi : Role DELETE_CATALOG_ROLE memberikan hak untuk menghapus isi tabel audit (AUD$). Karena perannya sangat sensitif dan telah deprecated sejak Oracle 12c, maka role ini seharusnya tidak digunakan oleh pengguna yang tidak sah. Penghapusan log audit dapat menyembunyikan aktivitas berbahaya di sistem."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"