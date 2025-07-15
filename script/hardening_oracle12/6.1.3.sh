OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah opsi audit terhadap perintah 'SYSTEM GRANT' telah diaktifkan..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'SYSTEM GRANT';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit terhadap perintah SYSTEM GRANT belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit terhadap perintah SYSTEM GRANT telah diaktifkan (BY ACCESS)"
fi
 
{
  echo "Judul Audit : 6.1.3 Ensure the 'SYSTEM GRANT' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa setiap aktivitas GRANT dan REVOKE terhadap sistem privilege atau role, baik berhasil maupun gagal, dicatat. Hal ini penting untuk keperluan forensik dan deteksi penyalahgunaan otorisasi."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"