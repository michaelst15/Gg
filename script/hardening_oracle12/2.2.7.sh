#!/bin/bash

OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa parameter 'REMOTE_LOGIN_PASSWORDFILE' pada database Oracle..." | tee -a "$OUTPUT_FILE"

# Jalankan SQL langsung melalui here-document
RAW_RESULT=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET LINESIZE 1000

SELECT UPPER(VALUE)
FROM V\$SYSTEM_PARAMETER
WHERE UPPER(NAME) = 'REMOTE_LOGIN_PASSWORDFILE';

EXIT;
EOF
)

# Bersihkan hasil dari karakter \r, spasi berlebih, dan baris kosong
PARAM_RESULT=$(echo "$RAW_RESULT" | tr -d '\r' | xargs)

# Evaluasi status
STATUS="Fail"
if [ "$PARAM_RESULT" = "EXCLUSIVE" ]; then
    STATUS="Pass"
fi

# Simpan hasil audit
{
    echo "Judul Audit       : 2.2.7 Ensure 'REMOTE_LOGIN_PASSWORDFILE' Is Set to 'EXCLUSIVE'"
    echo "Status            : $STATUS"
    echo "Nilai Konfigurasi : $PARAM_RESULT"
    echo "Nilai CIS         : EXCLUSIVE"
    echo "Deskripsi         : Parameter ini mengatur penggunaan password file untuk koneksi jarak jauh ke database. Untuk keamanan, nilai harus disetel ke 'EXCLUSIVE'."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
