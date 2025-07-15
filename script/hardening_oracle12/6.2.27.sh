OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk aksi 'LOGON' dan 'LOGOFF' (Unified Auditing)..." | tee -a "$OUTPUT_FILE"
 
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
      AND AUD.AUDIT_OPTION IN ('LOGON', 'LOGOFF')
      AND AUD.AUDIT_OPTION_TYPE = 'STANDARD ACTION'
  ) = 2;
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
if [[ -z "$RESULT" ]]; then
  STATUS="Fail"
  VALUE="Audit LOGON dan LOGOFF belum diaktifkan untuk semua pengguna"
else
  STATUS="Pass"
  VALUE="Audit LOGON dan LOGOFF telah diaktifkan untuk semua pengguna"
fi
 
{
  echo "Judul Audit : 6.2.27 Ensure the 'LOGON' AND 'LOGOFF' Actions Audit Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini mencatat semua aktivitas login dan logout pengguna, termasuk SYSDBA dan SYSOPER. Penting untuk mendeteksi upaya login yang mencurigakan atau tidak sah dan sebagai bukti forensik dalam audit keamanan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"