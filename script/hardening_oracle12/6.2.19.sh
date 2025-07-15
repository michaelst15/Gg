OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk akses ke 'AUDSYS.AUD\$UNIFIED' (Unified Auditing)..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT AUD.POLICY_NAME, AUD.AUDIT_OPTION, AUD.AUDIT_OPTION_TYPE
FROM AUDIT_UNIFIED_POLICIES AUD, AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
WHERE AUD.POLICY_NAME = ENABLED.POLICY_NAME
AND AUD.AUDIT_OPTION = 'ALL'
AND AUD.AUDIT_OPTION_TYPE = 'OBJECT ACTION'
AND (AUD.OBJECT_SCHEMA = 'SYS' OR AUD.OBJECT_SCHEMA = 'AUDSYS')
AND AUD.OBJECT_NAME = 'AUD\$UNIFIED'
AND ENABLED.SUCCESS = 'YES'
AND ENABLED.FAILURE = 'YES'
AND ENABLED.ENABLED_OPT = 'BY'
AND ENABLED.USER_NAME = 'ALL USERS';
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit akses ke AUDSYS.AUD\$UNIFIED belum diaktifkan dalam kebijakan Unified Auditing"
else
  STATUS="Pass"
  VALUE="Audit akses ke AUDSYS.AUD\$UNIFIED telah diaktifkan dalam kebijakan Unified Auditing"
fi
 
{
  echo "Judul Audit : 6.2.19 Ensure the 'AUDSYS.AUD\$UNIFIED' Access Audit Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa seluruh upaya akses terhadap tabel AUDSYS.AUD\$UNIFIED, yang menyimpan jejak audit database, tercatat. Akses terhadap tabel ini bisa mengindikasikan upaya untuk memodifikasi atau melihat data audit dan karenanya wajib diawasi secara ketat demi integritas sistem."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"