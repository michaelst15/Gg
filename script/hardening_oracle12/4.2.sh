TXT_FILE="audit_results.txt"

# === CIS 4.2 - Ensure All Sample Data And Users Have Been Removed ===
echo "🔍 CIS 4.2 - Ensure All Sample Data And Users Have Been Removed" | tee -a "$TXT_FILE"
 
# SQL untuk mengecek keberadaan user sample
CHECK_SAMPLE_USERS_QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET ECHO OFF
SELECT USERNAME FROM DBA_USERS WHERE USERNAME IN ('BI','HR','IX','OE','PM','SCOTT','SH');
EXIT;
EOF
)
 
SAMPLE_USERS_FOUND=$(echo "$CHECK_SAMPLE_USERS_QUERY" | sqlplus -s / as sysdba | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//')
 
# Evaluasi hasil
if [[ -n "$SAMPLE_USERS_FOUND" ]]; then
  STATUS="Fail"
  CURRENT_VALUE=$(echo "$SAMPLE_USERS_FOUND" | tr '\n' ',' | sed 's/,$//')
  NOTES=$(echo "$SAMPLE_USERS_FOUND" | sed 's/^/- /')
else
  STATUS="Pass"
  CURRENT_VALUE="No sample users found"
  NOTES="None"
fi
 
# Tulis hasil audit ke file
{
  echo "Judul Audit : 4.2 Ensure All Sample Data And Users Have Been Removed"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $CURRENT_VALUE"
  echo "Nilai CIS : Tidak ada user BI, HR, IX, OE, PM, SCOTT, atau SH di sistem"
  echo "Deskripsi : User default/sampel tidak boleh berada dalam sistem produksi karena memiliki kerentanan password default dan akses ke skema contoh."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$TXT_FILE"