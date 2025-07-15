OUTPUT_FILE="audit_results.txt"

# === CIS 5.1.1.1 - Ensure 'EXECUTE' is revoked from 'PUBLIC' on Network Packages ===
echo "🔍 CIS 5.1.1.1 - Memeriksa 'EXECUTE' oleh PUBLIC pada paket jaringan Oracle" | tee -a "$OUTPUT_FILE"
 
# SQL Audit Query
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT TABLE_NAME FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME IN (
  'DBMS_LDAP','UTL_INADDR','UTL_TCP','UTL_MAIL',
  'UTL_SMTP','UTL_DBWS','UTL_ORAMTS','UTL_HTTP','HTTPURITYPE');
EXIT;
EOF
)
 
# Eksekusi dan ambil hasil
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Tidak ada paket jaringan dengan EXECUTE oleh PUBLIC"
else
  STATUS="Fail"
  VALUE="Ditemukan akses EXECUTE oleh PUBLIC pada paket: $RESULT"
fi
 
# Simpan hasil audit ke file
{
echo "Judul Audit : 5.1.1.1 Ensure 'EXECUTE' is revoked from 'PUBLIC' on Network Packages"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : EXECUTE privilege must be revoked from PUBLIC on packages: DBMS_LDAP, UTL_INADDR, UTL_TCP, UTL_MAIL, UTL_SMTP, UTL_DBWS, UTL_ORAMTS, UTL_HTTP, HTTPURITYPE"
  echo "Deskripsi : Paket jaringan Oracle memungkinkan koneksi keluar. Jika EXECUTE diberikan ke PUBLIC, pengguna tidak sah dapat mengeksfiltrasi data atau menyambung keluar dari basis data, yang berisiko tinggi."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"