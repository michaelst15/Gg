OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'PROCEDURE'..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'PROCEDURE';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit PROCEDURE belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit PROCEDURE telah diaktifkan dengan konfigurasi yang benar"
fi
 
{
  echo "Judul Audit : 6.1.15 Ensure the 'PROCEDURE' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan setiap upaya untuk membuat atau menghapus prosedur, fungsi, paket, atau library dicatat. Perubahan tidak sah pada objek-objek tersebut dapat berdampak besar terhadap perilaku aplikasi dan keamanan sistem secara keseluruhan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"