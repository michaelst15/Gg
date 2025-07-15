OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah role 'RDSD' hanya diberikan kepada DSDxxx..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE = 'RDSD'
AND GRANTEE NOT LIKE 'DSD%';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Role RDSD hanya diberikan kepada user DSDxxx"
else
  STATUS="Fail"
  VALUE="Ditemukan grantee tidak sah memiliki role RDSD: $RESULT"
fi
 
{
  echo "Judul Audit : 5.2.15 Ensure 'GRANT ANY ROLE' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : Hanya user DSDxxx (Administrator Keamanan TI) yang boleh memiliki role RDSD"
  echo "Deskripsi : Role RDSD memberikan hak istimewa administratif tingkat tinggi dan harus dibatasi secara ketat. Pengguna yang bukan bagian dari grup DSD tidak boleh memiliki role ini."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"