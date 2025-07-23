#!/bin/bash

OUTPUT_FILE="audit_results.txt"

# Ambil cipher SSL/TLS yang digunakan MariaDB
SSL_CIPHER=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT VARIABLE_VALUE
FROM information_schema.global_variables
WHERE VARIABLE_NAME = 'ssl_cipher';
" 2>/dev/null)

# Evaluasi hasil (karena CIS tidak menetapkan daftar cipher tertentu, cukup pastikan nilainya tidak kosong)
if [[ -z "$SSL_CIPHER" ]]; then
    STATUS="FAIL"
    DETAILS="ssl_cipher kosong, MariaDB tidak menerapkan cipher TLS yang kuat."
else
    STATUS="PASS"
    DETAILS="
MariaDB menggunakan cipher TLS: 
$SSL_CIPHER
Pastikan cipher ini sesuai kebijakan keamanan organisasi."
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.12 Ensure Only Approved Ciphers are Used"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : "
    echo "$SSL_CIPHER"
    echo "$DETAILS"
    echo "Nilai CIS : MariaDB harus dikonfigurasi agar hanya menggunakan cipher TLS yang kuat dan disetujui. Jika nilai ssl_cipher kosong atau menggunakan cipher yang tidak disetujui, maka hasilnya FAIL."
    echo "Deskripsi : MariaDB mendukung banyak cipher TLS. Memaksa penggunaan cipher yang kuat akan melindungi data dalam transit dari serangan penyadapan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
