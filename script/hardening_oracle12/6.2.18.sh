OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa audit untuk 'SELECT ANY DICTIONARY' (Unified Auditing)..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT AUD.POLICY_NAME, AUD.AUDIT_OPTION, AUD.AUDIT_OPTION_TYPE
FROM AUDIT_UNIFIED_POLICIES AUD, AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
WHERE AUD.POLICY_NAME = ENABLED.POLICY_NAME
AND AUD.AUDIT_OPTION = 'SELECT ANY DICTIONARY'
AND AUD.AUDIT_OPTION_TYPE = 'SYSTEM PRIVILEGE'
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
  VALUE="Audit SELECT ANY DICTIONARY belum diaktifkan dalam kebijakan Unified Auditing"
else
  STATUS="Pass"
  VALUE="Audit SELECT ANY DICTIONARY telah diaktifkan dalam kebijakan Unified Auditing"
fi
 
{
  echo "Judul Audit : 6.2.18 Ensure the 'SELECT ANY DICTIONARY' Privilege Audit Is Enabled"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (enable)"
  echo "Deskripsi : Audit ini memastikan bahwa seluruh aktivitas yang menggunakan privilege SELECT ANY DICTIONARY tercatat. Privilege ini memungkinkan akses terhadap objek skema dan tampilan penting dalam database seperti DBA_, V\$, X\$ serta tabel di bawah schema SYS. Penggunaan privilege ini harus diaudit untuk mengidentifikasi akses mencurigakan terhadap metadata sistem."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"