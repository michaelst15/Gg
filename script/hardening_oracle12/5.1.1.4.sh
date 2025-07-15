OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.1.1.4 - Memeriksa akses 'EXECUTE' oleh PUBLIC pada paket Java (DBMS_JAVA, DBMS_JAVA_TEST)..." | tee -a "$OUTPUT_FILE"
 
# SQL query
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT TABLE_NAME FROM DBA_TAB_PRIVS 
WHERE GRANTEE='PUBLIC' 
AND PRIVILEGE='EXECUTE' 
AND TABLE_NAME IN ('DBMS_JAVA','DBMS_JAVA_TEST');
EXIT;
EOF
)
 
# Jalankan query
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="PUBLIC tidak memiliki akses EXECUTE pada paket Java"
else
  STATUS="Fail"
  VALUE="PUBLIC memiliki akses EXECUTE pada: $RESULT"
fi
 
# Simpan hasil audit
{
  echo "Judul Audit : 5.1.1.4 Ensure 'EXECUTE' is revoked from 'PUBLIC' on Java Packages"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : EXECUTE ON DBMS_JAVA / DBMS_JAVA_TEST to PUBLIC"
  echo "Deskripsi : Paket DBMS_JAVA dan DBMS_JAVA_TEST memungkinkan pengguna menjalankan perintah OS atau memberikan hak Java. Grant ke PUBLIC berisiko dieksploitasi untuk menjalankan perintah tidak sah."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
 