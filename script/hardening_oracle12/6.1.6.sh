OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah opsi audit terhadap 'PUBLIC DATABASE LINK' telah diaktifkan..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'PUBLIC DATABASE LINK';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit terhadap PUBLIC DATABASE LINK belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit terhadap PUBLIC DATABASE LINK telah diaktifkan (BY ACCESS)"
fi
 
{
  echo "Judul Audit : 6.1.6 Ensure the 'PUBLIC DATABASE LINK' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa aktivitas pembuatan, pengubahan, atau penghapusan PUBLIC DATABASE LINK dicatat. Karena link ini bersifat publik dan dapat digunakan lintas aplikasi, maka sangat penting untuk memantau aktivitas ini."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"