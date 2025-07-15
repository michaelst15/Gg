TXT_FILE="audit_results.txt"

# === CIS 4.4 - Ensure No Users Are Assigned the 'DEFAULT' Profile (with exceptions) ===
echo "🔍 CIS 4.4 - Ensure No Users Are Assigned the 'DEFAULT' Profile (with exceptions)" | tee -a "$TXT_FILE"

# Jalankan SQL langsung
USERS_WITH_DEFAULT_PROFILE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET ECHO OFF
SELECT USERNAME FROM DBA_USERS WHERE PROFILE = 'DEFAULT' AND ACCOUNT_STATUS = 'OPEN' AND ORACLE_MAINTAINED = 'N';
EXIT;
EOF
)

USERS_WITH_DEFAULT_PROFILE=$(echo "$USERS_WITH_DEFAULT_PROFILE" | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//')

# Daftar user yang diperbolehkan (dalam string, bukan array)
ALLOWED_USERS="ORACLE ORACLEP OWNIAC OPSPWDID OWNDSD OWNDBCM"

STATUS="Pass"
CURRENT_VALUE=""
DETAILS=""

# Evaluasi user yang pakai profil DEFAULT
echo "$USERS_WITH_DEFAULT_PROFILE" | while IFS= read -r USERNAME; do
  UPPER_USER=$(echo "$USERNAME" | tr '[:lower:]' '[:upper:]')
  FOUND=0

  for ALLOWED in $ALLOWED_USERS; do
    if [ "$UPPER_USER" = "$ALLOWED" ]; then
      FOUND=1
      break
    fi
  done

  if [ "$FOUND" -ne 1 ]; then
    STATUS="Fail"
    DETAILS="${DETAILS}- $USERNAME menggunakan profil DEFAULT dan tidak dikecualikan\n"
  fi

  CURRENT_VALUE="${CURRENT_VALUE}${USERNAME},"
done

# Hapus koma terakhir
CURRENT_VALUE=$(echo "$CURRENT_VALUE" | sed 's/,$//')

# Tulis hasil audit ke file
{
  echo "Judul Audit : 4.4 Ensure No Users Are Assigned the 'DEFAULT' Profile"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : ${CURRENT_VALUE:-Tidak ditemukan user yang tidak sesuai}"
  echo "Nilai CIS : Hanya user berikut yang boleh menggunakan profil DEFAULT: ORACLE, ORACLEP, OWNIAC, OPSPWDID, OWNDSD, OWNDBCM"
  echo "Deskripsi : User sebaiknya tidak menggunakan profil DEFAULT karena setting-nya bersifat tidak terbatas dan bisa berubah oleh patch Oracle."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$TXT_FILE"
