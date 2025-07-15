OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'ALTER SYSTEM'..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'ALTER SYSTEM';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit ALTER SYSTEM belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit ALTER SYSTEM telah diaktifkan dengan konfigurasi yang benar"
fi
 
{
  echo "Judul Audit : 6.1.16 Ensure the 'ALTER SYSTEM' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa setiap upaya untuk mengubah konfigurasi sistem database dicatat, baik yang berhasil maupun yang gagal. ALTER SYSTEM dapat digunakan untuk mengubah parameter penting yang berdampak langsung terhadap keamanan, performa, dan integritas sistem."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"