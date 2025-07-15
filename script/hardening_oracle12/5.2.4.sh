OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah DBSNMP memiliki privilege 'EXECUTE ANY PROCEDURE'..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE || ':' || PRIVILEGE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'EXECUTE ANY PROCEDURE'
AND GRANTEE = 'DBSNMP';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="DBSNMP tidak memiliki privilege 'EXECUTE ANY PROCEDURE'"
else
  STATUS="Fail"
  VALUE="DBSNMP memiliki privilege: $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.4 Ensure 'EXECUTE ANY PROCEDURE' Is Revoked from 'DBSNMP'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : DBSNMP tidak boleh memiliki 'EXECUTE ANY PROCEDURE'"
  echo "Deskripsi : Pengguna DBSNMP (biasanya digunakan oleh Oracle Enterprise Manager) tidak seharusnya memiliki hak untuk menjalankan prosedur apa pun secara global di database. Hak ini meningkatkan risiko penyalahgunaan dan harus dicabut kecuali benar-benar diperlukan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"