OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'GRANT ANY PRIVILEGE'..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'GRANT ANY PRIVILEGE';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit GRANT ANY PRIVILEGE belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit GRANT ANY PRIVILEGE telah diaktifkan dengan konfigurasi yang benar"
fi
 
{
  echo "Judul Audit : 6.1.12 Ensure the 'GRANT ANY PRIVILEGE' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan semua aktivitas GRANT terhadap system privilege dicatat. Hal ini penting untuk mendeteksi potensi penyalahgunaan wewenang administratif, serta membantu analisis forensik dan kontrol keamanan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"