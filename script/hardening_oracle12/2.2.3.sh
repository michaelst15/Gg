OUTPUT_FILE="audit_results.txt"
echo "🔍 Memeriksa parameter 'GLOBAL_NAMES'..." | tee -a "$OUTPUT_FILE"

# Cek apakah database multitenant (CDB) atau bukan
IS_CDB=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT CDB FROM V\$DATABASE;
EXIT;
EOF
)
IS_CDB=$(echo "$IS_CDB" | tr -d '[:space:]')

# Siapkan query tergantung apakah CDB atau non-CDB
if [ "$IS_CDB" = "YES" ]; then
QUERY="
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 100
SELECT DISTINCT UPPER(V.VALUE) || ' | ' ||
  DECODE(V.CON_ID,
         0, (SELECT NAME FROM V\$DATABASE),
         1, (SELECT NAME FROM V\$DATABASE),
         (SELECT NAME FROM V\$PDBS B WHERE V.CON_ID = B.CON_ID))
FROM V\$SYSTEM_PARAMETER V
WHERE UPPER(V.NAME) = 'GLOBAL_NAMES';
EXIT;"
else
QUERY="
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT UPPER(VALUE) FROM V\$SYSTEM_PARAMETER WHERE UPPER(NAME) = 'GLOBAL_NAMES';
EXIT;"
fi

# Eksekusi query
GLOBAL_RESULT=$(sqlplus -s / as sysdba <<EOF
$QUERY
EOF
)

# Proses hasil
STATUS="Pass"
CONFIG_SUMMARY=""

echo "$GLOBAL_RESULT" | while IFS= read -r line; do
  RESULT=$(echo "$line" | tr -d '\r' | xargs)
  VALUE=$(echo "$RESULT" | cut -d'|' -f1 | tr -d '[:space:]')
  PDB=$(echo "$RESULT" | cut -d'|' -f2- | xargs)

  if [ "$VALUE" != "TRUE" ]; then
    STATUS="Fail"
  fi

  if [ -n "$PDB" ]; then
    CONFIG_SUMMARY="$CONFIG_SUMMARY PDB/DB: $PDB = $VALUE |"
  else
    CONFIG_SUMMARY="$CONFIG_SUMMARY GLOBAL_NAMES = $VALUE |"
  fi
done

# Hapus pemisah terakhir
CONFIG_SUMMARY=$(echo "$CONFIG_SUMMARY" | sed 's/ |$//')

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.3 Ensure 'GLOBAL_NAMES' Is Set to 'TRUE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $CONFIG_SUMMARY"
  echo "Nilai CIS         : TRUE"
  echo "Deskripsi         : GLOBAL_NAMES memastikan bahwa nama database link sesuai dengan nama database target, menghindari koneksi dari domain yang tidak sah."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
