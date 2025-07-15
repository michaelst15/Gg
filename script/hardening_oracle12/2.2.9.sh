#!/bin/bash

OUTPUT_FILE="audit_results.txt"

# Buat header audit jika file belum ada
if [ ! -f "$OUTPUT_FILE" ]; then
  {
    echo "===== ORACLE DATABASE CIS AUDIT RESULTS ====="
    echo "Generated on: $(date)"
    echo "============================================="
    echo ""
  } > "$OUTPUT_FILE"
fi

echo "🔍 Memeriksa parameter 'REMOTE_OS_ROLES'..." | tee -a "$OUTPUT_FILE"

# Jalankan SQL langsung tanpa file SQL
RAW_RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET LINESIZE 1000

SELECT UPPER(VALUE)
FROM V\$PARAMETER
WHERE UPPER(NAME) = 'REMOTE_OS_ROLES';

EXIT;
EOF
)

# Bersihkan hasil output
VALUE=$(echo "$RAW_RESULT" | tr -d '\r' | xargs)

# Evaluasi hasil
STATUS="Fail"
if [ "$VALUE" = "FALSE" ]; then
  STATUS="Pass"
fi

# Tulis hasil audit ke file
{
  echo "Judul Audit       : 2.2.9 Ensure 'REMOTE_OS_ROLES' Is Set to 'FALSE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS         : FALSE"
  echo "Deskripsi         : Parameter ini harus disetel ke FALSE untuk mencegah penerapan peran OS dari klien remote yang dapat melemahkan kontrol hak akses."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
