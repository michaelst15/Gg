OUTPUT_FILE="audit_results.txt"

# === CIS 4.6 - Ensure No Public Database Links Exist ===
echo "🔍 CIS 4.6 - Ensure No Public Database Links Exist" | tee -a "$OUTPUT_FILE"
 
# SQL Audit Query
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT DB_LINK || ' -> ' || HOST FROM DBA_DB_LINKS WHERE OWNER = 'PUBLIC';
EXIT;
EOF
)
 
# Eksekusi query
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Tidak ada public database link yang terdeteksi"
else
  STATUS="Fail"
  VALUE="Ditemukan public database link: $RESULT"
fi
 
# Simpan hasil audit ke file
{
  echo "Judul Audit : 4.6 Ensure No Public Database Links Exist"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : Tidak boleh ada database link yang dimiliki oleh PUBLIC"
  echo "Deskripsi : Public DB link memberikan akses ke remote database bagi siapa saja yang terhubung ke database lokal, yang dapat membuka celah keamanan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"