OUTPUT_FILE="audit_results.txt"
echo "🔍 Memeriksa parameter 'OS_ROLES'..." | tee -a "$OUTPUT_FILE"

# Deteksi apakah menggunakan multitenant (CDB)
IS_CDB=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT CDB FROM V\$DATABASE;
EXIT;
EOF
)
IS_CDB=$(echo "$IS_CDB" | tr -d '[:space:]')

# Siapkan query SQL berdasarkan apakah CDB atau bukan
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
WHERE UPPER(V.NAME) = 'OS_ROLES';
EXIT;"
else
QUERY="
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT UPPER(VALUE) FROM V\$SYSTEM_PARAMETER WHERE UPPER(NAME) = 'OS_ROLES';
EXIT;"
fi

# Jalankan query melalui sqlplus
RESULT=$(sqlplus -s / as sysdba <<EOF
$QUERY
EOF
)

# Evaluasi hasil
STATUS="Pass"
CONFIG_SUMMARY=""

echo "$RESULT" | while IFS= read -r line; do
  CLEAN=$(echo "$line" | tr -d '\r' | xargs)
  VALUE=$(echo "$CLEAN" | cut -d'|' -f1 | tr -d '[:space:]')
  DBNAME=$(echo "$CLEAN" | cut -d'|' -f2- | xargs)

  if [ "$VALUE" != "FALSE" ]; then
    STATUS="Fail"
  fi

  if [ -n "$DBNAME" ]; then
    CONFIG_SUMMARY="$CONFIG_SUMMARY PDB/DB: $DBNAME = $VALUE |"
  else
    CONFIG_SUMMARY="$CONFIG_SUMMARY OS_ROLES = $VALUE |"
  fi
done

# Hapus pemisah terakhir
CONFIG_SUMMARY=$(echo "$CONFIG_SUMMARY" | sed 's/ |$//')

# Simpan hasil ke file audit
{
  echo "Judul Audit       : 2.2.5 Ensure 'OS_ROLES' Is Set to 'FALSE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $CONFIG_SUMMARY"
  echo "Nilai CIS         : FALSE"
  echo "Deskripsi         : Parameter OS_ROLES harus disetel ke FALSE untuk mencegah pemetaan grup sistem operasi secara langsung ke peran database, yang dapat menimbulkan celah hak akses."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
