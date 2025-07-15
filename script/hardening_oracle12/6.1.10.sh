OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah audit terhadap 'SELECT ANY DICTIONARY' telah diaktifkan untuk pengguna yang relevan..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT USER_NAME, AUDIT_OPTION, SUCCESS, FAILURE
FROM DBA_STMT_AUDIT_OPTS
WHERE AUDIT_OPTION = 'SELECT ANY DICTIONARY'
AND USER_NAME IN ('DBADMIN', 'DSDXXX', 'OWNDSD', 'OWNIDN')
AND SUCCESS = 'BY ACCESS'
AND FAILURE = 'BY ACCESS';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit SELECT ANY DICTIONARY belum diaktifkan untuk pengguna DBADMIN, DSDXXX, OWNDSD, OWNIDN"
else
  STATUS="Pass"
  VALUE="Audit SELECT ANY DICTIONARY telah diaktifkan untuk pengguna yang ditentukan"
fi
 
{
  echo "Judul Audit : 6.1.10 Ensure the 'SELECT ANY DICTIONARY' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa aktivitas akses terhadap semua definisi objek skema di database oleh pengguna tertentu dicatat. SELECT ANY DICTIONARY adalah hak istimewa kritis yang memungkinkan akses luas terhadap metadata sistem dan pengguna."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"