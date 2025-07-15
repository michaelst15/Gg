OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah OUTLN memiliki privilege 'EXECUTE ANY PROCEDURE'..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE || ':' || PRIVILEGE FROM DBA_SYS_PRIVS
WHERE PRIVILEGE = 'EXECUTE ANY PROCEDURE'
AND GRANTEE = 'OUTLN';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="OUTLN tidak memiliki privilege 'EXECUTE ANY PROCEDURE'"
else
  STATUS="Fail"
  VALUE="OUTLN memiliki privilege: $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.3 Ensure 'EXECUTE ANY PROCEDURE' Is Revoked from 'OUTLN'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : OUTLN tidak boleh memiliki 'EXECUTE ANY PROCEDURE'"
  echo "Deskripsi : OUTLN seharusnya hanya digunakan untuk penyimpanan outline dan tidak memerlukan hak istimewa untuk mengeksekusi prosedur apa pun. Hak ini harus dicabut jika tidak diperlukan untuk meminimalkan permukaan serangan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"