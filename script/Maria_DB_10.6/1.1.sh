#!/bin/bash

OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa lokasi database MariaDB (CIS 1.1)..." | tee -a "$OUTPUT_FILE"

# Mendapatkan daftar direktori dan file penting dari MariaDB
QUERY="SELECT VARIABLE_NAME, VARIABLE_VALUE
FROM information_schema.global_variables
WHERE (VARIABLE_NAME LIKE '%dir' OR VARIABLE_NAME LIKE '%file')
  AND VARIABLE_NAME NOT LIKE '%core%'
  AND VARIABLE_NAME <> 'local_infile'
  AND VARIABLE_NAME <> 'relay_log_info_file'
ORDER BY VARIABLE_NAME;"

# Eksekusi query dan simpan hasilnya ke variabel
MYSQL_RESULT=$(mysql -N -B -e "$QUERY")

STATUS="Pass"
DETAIL=""

# Mengecek setiap direktori/file yang dikembalikan
while IFS=$'\t' read -r VARIABLE_NAME VARIABLE_VALUE; do
  if [ -d "$VARIABLE_VALUE" ] || [ -f "$VARIABLE_VALUE" ]; then
    MOUNT_POINT=$(df --output=target "$VARIABLE_VALUE" | tail -1)
    if [[ "$MOUNT_POINT" == "/" || "$MOUNT_POINT" == "/var" || "$MOUNT_POINT" == "/usr" ]]; then
      STATUS="Fail"
      DETAIL+="✗ $VARIABLE_NAME berada di partisi sistem: $MOUNT_POINT -> $VARIABLE_VALUE\n"
    else
      DETAIL+="✓ $VARIABLE_NAME berada di partisi non-sistem: $MOUNT_POINT -> $VARIABLE_VALUE\n"
    fi
  else
    DETAIL+="⚠️ $VARIABLE_NAME tidak ditemukan di sistem: $VARIABLE_VALUE\n"
  fi
done <<< "$MYSQL_RESULT"

{
  echo "Judul Audit : 1.1 Place Databases on Non-System Partitions"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi :\n$DETAIL"
  echo "Nilai CIS : echo "Nilai CIS : Datadir dan file database harus berada di partisi non-sistem (bukan /, /var,/usr)""
  echo "Deskripsi : Pastikan database MariaDB berada di partisi non-sistem untuk mencegah kemungkinan gangguan layanan akibat penuh-nya disk sistem."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
