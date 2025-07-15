OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'REVOKE' (Unified Auditing)..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT AUD.POLICY_NAME, AUD.AUDIT_OPTION, AUD.AUDIT_OPTION_TYPE
FROM AUDIT_UNIFIED_POLICIES AUD, AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
WHERE AUD.POLICY_NAME = ENABLED.POLICY_NAME
AND AUD.AUDIT_OPTION = 'REVOKE'
AND AUD.AUDIT_OPTION_TYPE = 'STANDARD ACTION'
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
  VALUE="Audit REVOKE belum diaktifkan dalam kebijakan Unified Auditing"
else
  STATUS="Pass"
  VALUE="Audit REVOKE telah diaktifkan dalam kebijakan Unified Auditing"
fi
 
{
  echo "Judul Audit : 6.2.8 Ensure the 'REVOKE' Action Audit Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa seluruh perintah REVOKE tercatat, baik berhasil maupun gagal. Hal ini penting untuk mendeteksi aktivitas pencabutan hak istimewa yang tidak sah dan mendukung forensik serta kepatuhan terhadap regulasi keamanan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"