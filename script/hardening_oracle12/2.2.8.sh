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

echo "🔍 Memeriksa parameter 'REMOTE_OS_AUTHENT'..." | tee -a "$OUTPUT_FILE"

# Jalankan SQL langsung tanpa file sementara
RAW_RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET LINESIZE 1000

SELECT UPPER(VALUE)
FROM V\$PARAMETER
WHERE UPPER(NAME) = 'REMOTE_OS_AUTHENT';

EXIT;
EOF
)

# Bersihkan hasil output
RESULT=$(echo "$RAW_RESULT" | tr -d '\r' | xargs)

# Evaluasi hasil
STATUS="Fail"
if [ "$RESULT" = "FALSE" ]; then
  STATUS="Pass"
fi

# Simpan hasil audit ke file
{
  echo "Judul Audit       : 2.2.8 Ensure 'REMOTE_OS_AUTHENT' Is Set to 'FALSE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $RESULT"
  echo "Nilai CIS         : FALSE"
  echo "Deskripsi         : Parameter ini harus disetel ke FALSE untuk mencegah autentikasi sistem operasi dari klien jarak jauh yang dapat menyebabkan spoofing atau penyalahgunaan hak akses."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
