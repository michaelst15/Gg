OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.1.1.3 - Memeriksa akses 'EXECUTE' oleh PUBLIC pada paket enkripsi (DBMS_CRYPTO, DBMS_OBFUSCATION_TOOLKIT, DBMS_RANDOM)..." | tee -a "$OUTPUT_FILE"
 
# SQL Query untuk audit
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT TABLE_NAME FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME IN ('DBMS_CRYPTO','DBMS_OBFUSCATION_TOOLKIT','DBMS_RANDOM');
EXIT;
EOF
)
 
# Eksekusi query
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="PUBLIC tidak memiliki akses EXECUTE pada paket enkripsi"
else
  STATUS="Fail"
  VALUE="PUBLIC memiliki akses EXECUTE pada: $RESULT"
fi
 
# Simpan hasil audit
{
echo "Judul Audit : 5.1.1.3 Ensure 'EXECUTE' is revoked from 'PUBLIC' on Encryption Packages"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : EXECUTE ON DBMS_CRYPTO / DBMS_OBFUSCATION_TOOLKIT / DBMS_RANDOM to PUBLIC"
  echo "Deskripsi : Paket enkripsi seperti DBMS_CRYPTO, DBMS_OBFUSCATION_TOOLKIT, dan DBMS_RANDOM dapat digunakan untuk manipulasi data terenkripsi atau menghasilkan nilai acak. Jika PUBLIC memiliki akses, maka bisa disalahgunakan oleh pengguna tak berwenang."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"