OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'DROP TRIGGER' (Unified Auditing)..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT AUD.POLICY_NAME
FROM AUDIT_UNIFIED_POLICIES AUD,
     AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
WHERE AUD.POLICY_NAME = ENABLED.POLICY_NAME
  AND AUD.AUDIT_OPTION = 'DROP TRIGGER'
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
  VALUE="Audit DROP TRIGGER belum diaktifkan untuk semua pengguna"
else
  STATUS="Pass"
  VALUE="Audit DROP TRIGGER telah diaktifkan untuk semua pengguna"
fi
 
{
  echo "Judul Audit : 6.2.26 Ensure the 'DROP TRIGGER' Action Audit Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan semua eksekusi DROP TRIGGER tercatat, baik yang berhasil maupun gagal, untuk mendeteksi atau menyelidiki aktivitas mencurigakan yang dapat memengaruhi integritas atau keamanan database."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"