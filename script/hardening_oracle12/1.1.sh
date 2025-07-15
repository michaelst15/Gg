#!/bin/bash

OUTPUT_FILE="audit_results.txt"

# Jalankan sqlplus langsung dengan SQL di dalam here-document
VERSION_RESULT=$(sqlplus -S / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET LINESIZE 200
SET TRIMSPOOL ON

SELECT PRODUCT || ' - ' || VERSION
FROM PRODUCT_COMPONENT_VERSION
WHERE UPPER(PRODUCT) LIKE '%DATABASE%'
AND VERSION LIKE '12.2.0.1%';

EXIT;
EOF
)

# Bersihkan output: hapus baris kosong dan spasi berlebih
VERSION_RESULT=$(echo "$VERSION_RESULT" | sed '/^$/d' | xargs)

# Evaluasi status
if [[ -n "$VERSION_RESULT" ]]; then
    STATUS="Pass"
    VALUE="$VERSION_RESULT"
else
    STATUS="Fail"
    VALUE="Version not found or not 12.2.0.1"
fi

# Tulis hasil ke file audit
{
    echo "Judul Audit : 1.1 Oracle Database Version"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : 12.2.0.1.x"
    echo "Deskripsi : Verifikasi bahwa versi Oracle Database adalah 12.2.0.1"
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
