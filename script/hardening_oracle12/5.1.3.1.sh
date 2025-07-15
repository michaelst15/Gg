OUTPUT_FILE="audit_results.txt"

echo "🔍 CIS 5.1.3.1 - Memeriksa GRANTEE tidak sah pada tabel SYS.AUD$..." | tee -a "$OUTPUT_FILE"

# Jalankan SQL query
RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT GRANTEE || ':' || PRIVILEGE FROM DBA_TAB_PRIVS
WHERE TABLE_NAME='AUD$' AND OWNER='SYS';
EXIT;
EOF
)

# Bersihkan hasil
RESULT=$(echo "$RESULT" | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//')

# GRANTEE yang sah (dalam string biasa, bukan array bash)
AUTHORIZED_GRANTEES="DELETE_CATALOG_ROLE:DELETE RDSDAUD:SELECT"

STATUS="Pass"
DETAILS=""

# Evaluasi hasil query
echo "$RESULT" | while IFS= read -r LINE; do
  IS_AUTHORIZED=0
  for VALID in $AUTHORIZED_GRANTEES; do
    if [ "$LINE" = "$VALID" ]; then
      IS_AUTHORIZED=1
      break
    fi
  done

  if [ "$IS_AUTHORIZED" -ne 1 ]; then
    STATUS="Fail"
    DETAILS="${DETAILS}$LINE\n"
  fi
done

# Format hasil akhir
if [ "$STATUS" = "Pass" ]; then
  VALUE="Tidak ada GRANTEE tidak sah pada SYS.AUD\$"
else
  VALUE="Ditemukan GRANTEE tidak sah:\n$DETAILS"
fi

# Simpan ke file hasil audit
{
  echo "Judul Audit : 5.1.3.1 Ensure 'ALL' Is Revoked from Unauthorized 'GRANTEE' on 'AUD\$'"
  echo "Status : $STATUS"
  printf "Nilai Konfigurasi : $VALUE\n"
  echo "Nilai CIS : Tidak boleh ada GRANTEE selain DELETE_CATALOG_ROLE (DELETE) dan RDSDAUD (SELECT)"
  echo "Deskripsi : Tabel SYS.AUD\$ menyimpan semua catatan audit. Hanya role khusus yang seharusnya memiliki akses untuk memastikan integritas dan keaslian data audit."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
