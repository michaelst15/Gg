TXT_FILE="audit_results.txt"

# === CIS 4.1 - Ensure All Default Passwords Are Changed ===
echo "🔍 CIS 4.1 - Ensure All Default Passwords Are Changed" | tee -a "$TXT_FILE"
 
# SQL untuk mengecek user dengan default password (non CDB mode)
CHECK_DEFPWD_QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET ECHO OFF
SELECT DISTINCT A.USERNAME
FROM DBA_USERS_WITH_DEFPWD A, DBA_USERS B
WHERE A.USERNAME = B.USERNAME AND B.ACCOUNT_STATUS = 'OPEN';
EXIT;
EOF
)
 
DEFPWD_USERS=$(echo "$CHECK_DEFPWD_QUERY" | sqlplus -s / as sysdba | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//')
 
# Evaluasi hasil
if [[ -n "$DEFPWD_USERS" ]]; then
  STATUS="Fail"
  CURRENT_VALUE=$(echo "$DEFPWD_USERS" | tr '\n' ',' | sed 's/,$//')
  NOTES=$(echo "$DEFPWD_USERS" | sed 's/^/- /')
else
  STATUS="Pass"
  CURRENT_VALUE="No users with default passwords"
  NOTES="None"
fi
 
# Tulis hasil ke file audit
{
  echo "Judul Audit : 4.1 Ensure All Default Passwords Are Changed"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $CURRENT_VALUE"
  echo "Nilai CIS : Tidak ada user dengan default password dan status OPEN"
  echo "Deskripsi : Default password bersifat publik dan berisiko. Pastikan semua password default telah diganti."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$TXT_FILE"