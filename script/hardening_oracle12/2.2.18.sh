#!/bin/bash

OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa parameter 'RESOURCE_LIMIT'..." | tee -a "$OUTPUT_FILE"

# Jalankan SQL langsung melalui here-document
RAW_VALUE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET LINESIZE 1000

SELECT VALUE FROM V\$PARAMETER WHERE UPPER(NAME) = 'RESOURCE_LIMIT';

EXIT;
EOF
)

# Bersihkan hasil (hapus spasi dan kapitalisasi)
VALUE=$(echo "$RAW_VALUE" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')

# Evaluasi hasil
STATUS="Fail"
if [[ "$VALUE" == "TRUE" ]]; then
  STATUS="Pass"
fi

# Simpan hasil audit ke file output
{
  echo "Judul Audit       : 2.2.18 Ensure 'RESOURCE_LIMIT' Is Set to 'TRUE'"
  echo "Status            : $STATUS"
  echo "Nilai Konfigurasi : ${VALUE:-null}"
  echo "Nilai CIS         : TRUE"
  echo "Deskripsi         : Parameter ini memastikan bahwa batasan penggunaan sumber daya yang ditetapkan pada profil database diberlakukan. Harus disetel ke TRUE untuk mencegah penyalahgunaan sumber daya."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
