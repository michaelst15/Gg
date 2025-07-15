OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa apakah opsi audit terhadap 'SYNONYM' telah diaktifkan..." | tee -a "$OUTPUT_FILE"
 
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
AND AUDIT_OPTION = 'SYNONYM';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit terhadap SYNONYM belum diaktifkan"
else
  STATUS="Pass"
  VALUE="Audit terhadap SYNONYM telah diaktifkan (BY ACCESS)"
fi
 
{
  echo "Judul Audit : 6.1.8 Ensure the 'SYNONYM' Audit Option Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa aktivitas pembuatan atau penghapusan SYNONYM dicatat. Karena synonym dapat merujuk ke berbagai objek penting dalam database, pengawasan terhadap aktivitas ini penting untuk mendeteksi aktivitas mencurigakan atau tidak sah."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"