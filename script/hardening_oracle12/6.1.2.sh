OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah opsi audit terhadap perintah 'ROLE' telah diaktifkan..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'ROLE';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit terhadap perintah ROLE belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit terhadap perintah ROLE telah diaktifkan (BY ACCESS)"
fi
 
{
  echo "Judul Audit : 6.1.2 Ensure the 'ROLE' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo -e "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa semua aktivitas terhadap role database seperti CREATE, DROP, ALTER, dan SET ROLE diaudit. Hal ini penting untuk mendeteksi perubahan otorisasi yang tidak sah."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"