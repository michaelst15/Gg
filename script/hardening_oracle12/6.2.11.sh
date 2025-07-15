OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'DROP PROFILE' (Unified Auditing)..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT AUD.POLICY_NAME, AUD.AUDIT_OPTION, AUD.AUDIT_OPTION_TYPE
FROM AUDIT_UNIFIED_POLICIES AUD, AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
WHERE AUD.POLICY_NAME = ENABLED.POLICY_NAME
AND AUD.AUDIT_OPTION = 'DROP PROFILE'
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
  VALUE="Audit DROP PROFILE belum diaktifkan dalam kebijakan Unified Auditing"
else
  STATUS="Pass"
  VALUE="Audit DROP PROFILE telah diaktifkan dalam kebijakan Unified Auditing"
fi
 
{
  echo "Judul Audit : 6.2.11 Ensure the 'DROP PROFILE' Action Audit Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa seluruh perintah DROP PROFILE tercatat, baik yang berhasil maupun gagal. Ini penting karena DROP PROFILE dapat menghapus kebijakan penting terkait keamanan dan penggunaan sumber daya pengguna database."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"