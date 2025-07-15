OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah opsi audit terhadap 'DIRECTORY' telah diaktifkan..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'DIRECTORY';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit terhadap DIRECTORY belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit terhadap DIRECTORY telah diaktifkan (BY ACCESS)"
fi
 
{
  echo "Judul Audit : 6.1.9 Ensure the 'DIRECTORY' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa aktivitas pembuatan atau penghapusan DIRECTORY dicatat. Karena DIRECTORY digunakan sebagai alias untuk folder di sistem file server, pemantauan terhadap perintah ini penting untuk mencegah akses tidak sah ke file eksternal yang terhubung dengan database."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"