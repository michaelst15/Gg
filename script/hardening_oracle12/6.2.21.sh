OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'ALTER PROCEDURE/FUNCTION/PACKAGE/PACKAGE BODY' (Unified Auditing)..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT ENABLED.POLICY_NAME
FROM AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
WHERE ENABLED.SUCCESS = 'YES'
AND ENABLED.FAILURE = 'YES'
AND ENABLED.ENABLED_OPT = 'BY USER'
AND ENABLED.USER_NAME = 'ALL USERS'
AND (
  SELECT COUNT(*)
  FROM AUDIT_UNIFIED_POLICIES AUD
  WHERE AUD.POLICY_NAME = ENABLED.POLICY_NAME
  AND AUD.AUDIT_OPTION IN ('ALTER PROCEDURE', 'ALTER FUNCTION', 'ALTER PACKAGE', 'ALTER PACKAGE BODY')
  AND AUD.AUDIT_OPTION_TYPE = 'STANDARD ACTION'
) = 4;
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit ALTER PROCEDURE/FUNCTION/PACKAGE/BODY belum diaktifkan dalam kebijakan Unified Auditing"
else
  STATUS="Pass"
  VALUE="Audit ALTER PROCEDURE/FUNCTION/PACKAGE/BODY telah diaktifkan dalam kebijakan Unified Auditing"
fi
 
{
  echo "Judul Audit : 6.2.21 Ensure the 'ALTER PROCEDURE/FUNCTION/PACKAGE/PACKAGE BODY' Action Audit Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan seluruh modifikasi prosedur, fungsi, paket, dan paket body dicatat. Hal ini penting untuk mengidentifikasi perubahan tidak sah yang dapat mengganggu fungsi bisnis atau merusak integritas database."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"