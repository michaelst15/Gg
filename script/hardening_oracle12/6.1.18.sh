OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'CREATE SESSION'..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'CREATE SESSION';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit CREATE SESSION belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit CREATE SESSION telah diaktifkan dengan konfigurasi yang benar"
fi
 
{
  echo "Judul Audit : 6.1.18 Ensure the 'CREATE SESSION' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa semua upaya untuk login ke database dicatat, baik yang berhasil maupun yang gagal. Audit ini penting untuk mendeteksi percobaan intrusi, aktivitas login mencurigakan, dan merupakan bagian penting dari jejak forensik sesi database."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"