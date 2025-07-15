TXT_FILE="audit_results.txt"

# Buat file jika belum ada
if [ ! -f "$TXT_FILE" ]; then
  echo "===== ORACLE DATABASE CIS AUDIT RESULTS =====" > "$TXT_FILE"
  echo "Generated on: $(date)" >> "$TXT_FILE"
  echo "=============================================" >> "$TXT_FILE"
  echo "" >> "$TXT_FILE"
fi

# === CIS 3.8 - Ensure SESSIONS_PER_USER sesuai kebijakan organisasi ===
echo "CIS 3.8 - Ensure 'SESSIONS_PER_USER' Is Set as per Organizational Policy" | tee -a "$TXT_FILE"

# Jalankan SQL dan ambil hasil
RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET ECHO OFF
SELECT PROFILE || ':' || LIMIT
FROM DBA_PROFILES
WHERE RESOURCE_NAME = 'SESSIONS_PER_USER'
AND PROFILE IN ('DEFAULT', 'GSM_PROF', 'APPSPROFILE');
EXIT;
EOF
)

# Bersihkan hasil query
RESULT=$(echo "$RESULT" | tr -d '\r' | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//')

STATUS="Pass"
DETAILS=""

echo "$RESULT" | while IFS= read -r line; do
  PROFILE=$(echo "$line" | cut -d':' -f1 | xargs)
  VALUE=$(echo "$line" | cut -d':' -f2 | xargs)

  if [ "$PROFILE" = "DEFAULT" ]; then
    if [ "$VALUE" != "UNLIMITED" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- Profile DEFAULT seharusnya UNLIMITED, ditemukan: $VALUE"
    fi
  elif [ "$PROFILE" = "GSM_PROF" ] || [ "$PROFILE" = "APPSPROFILE" ]; then
    if [ "$VALUE" != "DEFAULT" ]; then
      STATUS="Fail"
      DETAILS="$DETAILS
- Profile $PROFILE seharusnya DEFAULT, ditemukan: $VALUE"
    fi
  fi
done

# Simpan hasil audit
{
  echo "Judul Audit : 3.8 Ensure 'SESSIONS_PER_USER' Is Set as per Organizational Policy"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi :"
  echo "$RESULT"
  echo "Nilai CIS :"
  echo "- DEFAULT = UNLIMITED"
  echo "- GSM_PROF = DEFAULT"
  echo "- APPSPROFILE = DEFAULT"
  echo "Deskripsi : Pastikan parameter SESSIONS_PER_USER diatur sesuai kebijakan organisasi untuk membatasi jumlah sesi aktif per user."
  echo "$DETAILS"
  echo "-------------------------------------------------------------"
  echo ""
} >> "$TXT_FILE"
