OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'CREATE PROCEDURE/FUNCTION/PACKAGE/PACKAGE BODY' (Unified Auditing)..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT ENABLED.POLICY_NAME
FROM AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
WHERE ENABLED.SUCCESS = 'YES'
AND ENABLED.FAILURE = 'YES'
AND ENABLED.ENABLED_OPT = 'BY'
AND ENABLED.USER_NAME = 'ALL USERS'
AND (
  SELECT COUNT(*)
  FROM AUDIT_UNIFIED_POLICIES AUD
  WHERE AUD.POLICY_NAME = ENABLED.POLICY_NAME
  AND AUD.AUDIT_OPTION IN ('CREATE PROCEDURE', 'CREATE FUNCTION', 'CREATE PACKAGE', 'CREATE PACKAGE BODY')
  AND AUD.AUDIT_OPTION_TYPE = 'STANDARD ACTION'
) = 4;
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit CREATE PROCEDURE/FUNCTION/PACKAGE/BODY belum diaktifkan dalam kebijakan Unified Auditing"
else
  STATUS="Pass"
  VALUE="Audit CREATE PROCEDURE/FUNCTION/PACKAGE/BODY telah diaktifkan dalam kebijakan Unified Auditing"
fi
 
{
  echo "Judul Audit : 6.2.20 Ensure the 'CREATE PROCEDURE/FUNCTION/PACKAGE/PACKAGE BODY' Action Audit Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan seluruh pembuatan prosedur, fungsi, paket, dan paket body di database tercatat, baik yang berhasil maupun gagal. Hal ini penting untuk mendeteksi aktivitas mencurigakan atau tidak sah yang dapat membahayakan integritas dan keamanan sistem."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"