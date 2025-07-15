OUTPUT_FILE="audit_results.txt"
echo "🔍 Memeriksa parameter 'O7_DICTIONARY_ACCESSIBILITY'..." | tee -a "$OUTPUT_FILE"

# Deteksi apakah database adalah CDB (multitenant) atau tidak
IS_CDB=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT CDB FROM V\$DATABASE;
EXIT;
EOF
)
IS_CDB=$(echo "$IS_CDB" | tr -d '[:space:]')

# Siapkan query tergantung dari apakah CDB atau bukan
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
WHERE UPPER(NAME) = 'O7_DICTIONARY_ACCESSIBILITY';
EXIT;"
else
QUERY="
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT UPPER(VALUE) FROM V\$SYSTEM_PARAMETER WHERE UPPER(NAME) = 'O7_DICTIONARY_ACCESSIBILITY';
EXIT;"
fi

# Jalankan query
RESULT=$(sqlplus -s / as sysdba <<EOF
$QUERY
EOF
)

# Evaluasi hasil
STATUS="Pass"
CONFIG_SUMMARY=""

echo "$RESULT" | while IFS= read -r line; do
  RESULT_CLEAN=$(echo "$line" | tr -d '\r' | xargs)
  VALUE=$(echo "$RESULT_CLEAN" | cut -d'|' -f1 | tr -d '[:space:]')
  DBNAME=$(echo "$RESULT_CLEAN" | cut -d'|' -f2- | xargs)

  if [ "$VALUE" != "FALSE" ]; then
    STATUS="Fail"
  fi

  if [ -n "$DBNAME" ]; then
    CONFIG_SUMMARY="$CONFIG_SUMMARY PDB/DB: $DBNAME = $VALUE |"
  else
    CONFIG_SUMMARY="$CONFIG_SUMMARY O7_DICTIONARY_ACCESSIBILITY = $VALUE |"
  fi
done

# Hapus separator terakhir
CONFIG_SUMMARY=$(echo "$CONFIG_SUMMARY" | sed 's/ |$//')

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.4 Ensure 'O7_DICTIONARY_ACCESSIBILITY' Is Set to 'FALSE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $CONFIG_SUMMARY"
  echo "Nilai CIS         : FALSE"
  echo "Deskripsi         : Parameter ini mencegah akses ke objek SYS oleh pengguna dengan hak ANY (misalnya SELECT ANY TABLE) dan seharusnya disetel ke FALSE. Parameter ini sudah deprecated di Oracle 12.2+."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
