OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah opsi audit terhadap perintah 'PROFILE' telah diaktifkan..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'PROFILE';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit terhadap perintah PROFILE belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit terhadap perintah PROFILE telah diaktifkan (BY ACCESS)"
fi
 
{
  echo "Judul Audit : 6.1.4 Ensure the 'PROFILE' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini bertujuan mencatat semua aktivitas CREATE, ALTER, atau DROP PROFILE yang berhasil maupun gagal. Ini penting untuk menjaga integritas pengaturan pembatasan resource pengguna dan mencegah penyalahgunaan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
 