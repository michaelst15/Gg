OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.1.1.6 - Memeriksa akses 'EXECUTE' oleh PUBLIC pada paket SQL Injection Helper (DBMS_SQL, DBMS_XMLGEN)..." | tee -a "$OUTPUT_FILE"
 
# SQL query untuk DBMS_SQL dan DBMS_XMLGEN
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT TABLE_NAME FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME IN ('DBMS_SQL','DBMS_XMLGEN');
EXIT;
EOF
)
 
# Jalankan query
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="PUBLIC tidak memiliki akses EXECUTE pada DBMS_SQL dan DBMS_XMLGEN"
else
  STATUS="Fail"
  VALUE="PUBLIC memiliki akses EXECUTE pada: $RESULT"
fi
 
# Simpan hasil audit
{
echo "Judul Audit : 5.1.1.6 Ensure 'EXECUTE' is revoked from 'PUBLIC' on SQL Injection Helper Packages"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : EXECUTE on DBMS_SQL to PUBLIC, EXECUTE on DBMS_XMLGEN to PUBLIC"
  echo "Deskripsi : Paket DBMS_SQL dan DBMS_XMLGEN dapat digunakan untuk menyusun perintah SQL atau menghasilkan konten XML berbasis query. Akses oleh PUBLIC berisiko digunakan dalam eksploitasi injeksi SQL atau exfiltrasi data."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"