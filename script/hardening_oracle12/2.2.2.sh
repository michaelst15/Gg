#!/bin/bash

OUTPUT_FILE="audit_results.txt"

# Tampilkan proses
echo "🔍 Memeriksa parameter 'AUDIT_TRAIL'..." | tee -a "$OUTPUT_FILE"

# Jalankan SQL langsung ke sqlplus (tanpa file SQL)
RAW_RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SET TRIMSPOOL ON
SET LINESIZE 1000

SELECT UPPER(VALUE) FROM V\$SYSTEM_PARAMETER WHERE UPPER(NAME)='AUDIT_TRAIL';
EXIT;
EOF
)

# Bersihkan hasil output
AUDIT_RESULT=$(echo "$RAW_RESULT" | tr -d '\r' | xargs)

# Evaluasi nilai parameter
STATUS="Fail"
case "$AUDIT_RESULT" in
  "OS"|"DB"|"DB,EXTENDED"|"XML"|"XML,EXTENDED")
    STATUS="Pass"
    ;;
esac

# Simpan hasil ke file audit
{
  echo "Judul Audit       : 2.2.2 Ensure 'AUDIT_TRAIL' Is Set to 'DB', 'XML', 'OS', 'DB,EXTENDED', or 'XML,EXTENDED'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : $AUDIT_RESULT"
  echo "Nilai CIS         : OS, DB, DB,EXTENDED, XML, atau XML,EXTENDED"
  echo "Deskripsi         : AUDIT_TRAIL mengatur apakah fitur audit dasar Oracle diaktifkan dan ke mana hasil audit disimpan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
