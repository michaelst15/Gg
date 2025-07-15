OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah opsi audit terhadap 'PUBLIC SYNONYM' telah diaktifkan..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT AUDIT_OPTION, SUCCESS, FAILURE
FROM DBA_STMT_AUDIT_OPTS
WHERE USER_NAME IS NULL
AND PROXY_NAME IS NULL
AND SUCCESS = 'BY ACCESS'
AND FAILURE = 'BY ACCESS'
AND AUDIT_OPTION = 'PUBLIC SYNONYM';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit terhadap PUBLIC SYNONYM belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit terhadap PUBLIC SYNONYM telah diaktifkan (BY ACCESS)"
fi
 
{
  echo "Judul Audit : 6.1.7 Ensure the 'PUBLIC SYNONYM' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa aktivitas pembuatan atau penghapusan PUBLIC SYNONYM dicatat. Karena public synonym dapat digunakan oleh seluruh user dengan hak akses ke objek di baliknya, maka aktivitas ini perlu diawasi."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"