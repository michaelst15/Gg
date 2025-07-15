OUTPUT_FILE="audit_results.txt"
echo "🔍 Memeriksa parameter 'REMOTE_LISTENER'..." | tee -a "$OUTPUT_FILE"

# Deteksi apakah environment menggunakan multitenant (CDB)
IS_CDB=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT CDB FROM V\$DATABASE;
EXIT;
EOF
)
IS_CDB=$(echo "$IS_CDB" | tr -d '[:space:]')

# Siapkan query SQL sesuai environment
if [ "$IS_CDB" = "YES" ]; then
QUERY="
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 100
SELECT DISTINCT NVL(UPPER(V.VALUE), '[EMPTY]') || ' | ' ||
  DECODE(V.CON_ID,
         0, (SELECT NAME FROM V\$DATABASE),
         1, (SELECT NAME FROM V\$DATABASE),
         (SELECT NAME FROM V\$PDBS B WHERE V.CON_ID = B.CON_ID))
FROM V\$SYSTEM_PARAMETER V
WHERE UPPER(V.NAME) = 'REMOTE_LISTENER';
EXIT;"
else
QUERY="
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT NVL(UPPER(VALUE), '[EMPTY]') FROM V\$SYSTEM_PARAMETER WHERE UPPER(NAME) = 'REMOTE_LISTENER';
EXIT;"
fi

# Eksekusi query
RESULT=$(sqlplus -s / as sysdba <<EOF
$QUERY
EOF
)

# Evaluasi hasil
STATUS="Pass"
CONFIG_SUMMARY=""

echo "$RESULT" | while IFS= read -r line; do
  CLEAN_LINE=$(echo "$line" | tr -d '\r' | xargs)
  VALUE=$(echo "$CLEAN_LINE" | cut -d'|' -f1 | xargs)
  DBNAME=$(echo "$CLEAN_LINE" | cut -d'|' -f2- | xargs)

  if [ "$VALUE" != "[EMPTY]" ] && [ -n "$VALUE" ]; then
    STATUS="Fail"
  fi

  if [ -n "$DBNAME" ]; then
    CONFIG_SUMMARY="$CONFIG_SUMMARY PDB/DB: $DBNAME = $VALUE |"
  else
    CONFIG_SUMMARY="$CONFIG_SUMMARY REMOTE_LISTENER = $VALUE |"
  fi
done

# Hapus pemisah akhir "|"
CONFIG_SUMMARY=$(echo "$CONFIG_SUMMARY" | sed 's/ |$//')

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.6 Ensure 'REMOTE_LISTENER' Is Empty"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $CONFIG_SUMMARY"
  echo "Nilai CIS         : 0"
  echo "Deskripsi         : Parameter REMOTE_LISTENER harus dikosongkan untuk mencegah koneksi listener jarak jauh yang bisa disalahgunakan untuk spoofing atau serangan koneksi tidak sah."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
