OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'TRIGGER'..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'TRIGGER';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit TRIGGER belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit TRIGGER telah diaktifkan dengan konfigurasi yang benar"
fi
 
{
  echo "Judul Audit : 6.1.17 Ensure the 'TRIGGER' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan setiap upaya untuk membuat, menghapus, mengaktifkan, atau menonaktifkan trigger di semua skema tercatat. Ini penting untuk mendeteksi perubahan yang dapat berdampak pada keamanan, integritas data, atau potensi eskalasi hak istimewa."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"