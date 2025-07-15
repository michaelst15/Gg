#!/bin/bash

OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa parameter '_trace_files_public'..." | tee -a "$OUTPUT_FILE"

# Cek apakah database sudah OPEN
DB_STATUS=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SELECT open_mode FROM v\$database;

EXIT;
EOF
)
DB_STATUS=$(echo "$DB_STATUS" | xargs)

if [[ "$DB_STATUS" != "READ WRITE" ]]; then
  echo "❌ Database belum dalam status OPEN. Status saat ini: $DB_STATUS" | tee -a "$OUTPUT_FILE"
  exit 1
fi

# Jalankan SQL langsung untuk ambil nilai _trace_files_public
RAW_RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET LINESIZE 1000

SELECT B.KSPPSTVL
FROM SYS.X_\$KSPPI A, SYS.X_\$KSPPCV B
WHERE A.INDX = B.INDX
AND A.KSPPINM LIKE '\\_trace_files_public' ESCAPE '\\';

EXIT;
EOF
)

# Bersihkan hasil dari whitespace
VALUE=$(echo "$RAW_RESULT" | tr -d '[:space:]')

# Evaluasi hasil (FALSE atau tidak ada hasil = PASS)
if [[ -z "$VALUE" || "$VALUE" == "FALSE" ]]; then
  STATUS="Pass"
else
  STATUS="Fail"
fi

# Simpan hasil ke file audit
{
  echo "Judul Audit      : 2.2.17 Ensure '_trace_files_public' Is Set to 'FALSE'"
  echo "Status           : $STATUS"
  echo "Nilai Konfigurasi: ${VALUE:-not set}"
  echo "Nilai CIS        : FALSE"
  echo "Deskripsi        : Parameter ini menentukan apakah file trace Oracle dapat diakses publik. Harus disetel ke FALSE untuk mencegah pengungkapan informasi sensitif."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
