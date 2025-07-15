OUTPUT_FILE="audit_results.txt"

# === CIS 4.5 - Ensure 'SYS.USER$MIG' Has Been Dropped ===
echo "🔍 CIS 4.5 - Ensure 'SYS.USER\$MIG' Has Been Dropped" | tee -a "$OUTPUT_FILE"
 
# SQL Audit Query
AUDIT_QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET VERIFY OFF
SELECT OWNER || '.' || TABLE_NAME FROM DBA_TABLES WHERE OWNER='SYS' AND TABLE_NAME='USER\$MIG';
EXIT;
EOF
)
 
# Eksekusi query
AUDIT_RESULT=$(echo "$AUDIT_QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil audit
if [[ -z "$AUDIT_RESULT" ]]; then
  STATUS="Pass"
  CURRENT_VALUE="Tabel SYS.USER\$MIG tidak ditemukan"
else
  STATUS="Fail"
  CURRENT_VALUE="Tabel ditemukan: $AUDIT_RESULT"
fi
 
# Simpan hasil audit ke file
{
  echo "Judul Audit : 4.5 Ensure 'SYS.USER\$MIG' Has Been Dropped"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $CURRENT_VALUE"
  echo "Nilai CIS : SYS.USER\$MIG tidak boleh ada di database setelah proses migrasi"
  echo "Deskripsi : Tabel ini menyimpan hash password Oracle sebelum migrasi, dan harus dihapus agar tidak bisa dimanfaatkan oleh penyerang."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"