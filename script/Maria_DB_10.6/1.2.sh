#!/bin/bash

OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa apakah MariaDB berjalan dengan user terbatas (CIS 1.2)..." | tee -a "$OUTPUT_FILE"

# Nama user yang seharusnya digunakan oleh MariaDB
EXPECTED_USER="mysql"

# Periksa proses MariaDB yang berjalan dengan user yang benar
PROCESS_OUTPUT=$(ps -ef | grep -E "mysqld" | grep -v grep | awk '{print $1}')

if [[ "$PROCESS_OUTPUT" == "$EXPECTED_USER" ]]; then
  STATUS="Pass"
  VALUE="MariaDB dijalankan dengan user terbatas: $EXPECTED_USER"
else
  if [[ -z "$PROCESS_OUTPUT" ]]; then
    STATUS="Fail"
    VALUE="MariaDB tidak berjalan atau tidak ditemukan proses mysqld : $PROCESS_OUTPUT"
  else
    STATUS="Fail"
    VALUE="MariaDB dijalankan dengan user yang tidak tepat: $PROCESS_OUTPUT"
  fi
fi

{
  echo "Judul Audit : 1.2 Use Dedicated Least Privileged Account for MariaDB Daemon/Service"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : MariaDB harus dijalankan sebagai user mysql (least privilege)"
  echo "Deskripsi : Menjalankan MariaDB dengan user terbatas membantu mengurangi risiko jika ada kerentanan pada service."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
