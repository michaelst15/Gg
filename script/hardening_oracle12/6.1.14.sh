OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit ALL pada objek 'SYS.AUD$'..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT OBJECT_NAME
FROM CDB_OBJ_AUDIT_OPTS
WHERE OBJECT_NAME='AUD$'
AND ALT='A/A'
AND AUD='A/A'
AND COM='A/A'
AND DEL='A/A'
AND GRA='A/A'
AND IND='A/A'
AND INS='A/A'
AND LOC='A/A'
AND REN='A/A'
AND SEL='A/A'
AND UPD='A/A'
AND FBK='A/A';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit ALL pada objek SYS.AUD$ belum diaktifkan secara lengkap"
else
  STATUS="Pass"
  VALUE="Audit ALL pada objek SYS.AUD$ telah diaktifkan"
fi
 
{
  echo "Judul Audit : 6.1.14 Ensure the 'ALL' Audit Option on 'SYS.AUD$' Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan seluruh aktivitas terhadap tabel audit internal (SYS.AUD$) dicatat. Hal ini penting untuk mendeteksi percobaan penghapusan, pembacaan, atau manipulasi terhadap data audit yang bersifat sensitif."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"