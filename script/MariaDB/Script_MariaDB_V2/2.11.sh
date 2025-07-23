#!/bin/bash

OUTPUT_FILE="audit_results.txt"

# Cek user yang tidak menggunakan X.509 untuk autentikasi
NON_X509_USERS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT user, host, ssl_type 
FROM mysql.user 
WHERE user NOT IN ('mysql', 'root', 'mariadb.sys') AND (ssl_type IS NULL OR ssl_type != 'X509');
")

# Evaluasi hasil
if [[ -n "$NON_X509_USERS" ]]; then
    STATUS="Fail"
    VALUE="
Some users are not required to use client-side certificates (X.509): 
$NON_X509_USERS"
else
    STATUS="Pass"
    VALUE="All users require X.509 client certificates for authentication."
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.11 Require Client-Side Certificates (X.509)"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Semua user non-sistem harus menggunakan autentikasi berbasis sertifikat klien X.509"
    echo "Deskripsi : Verifikasi bahwa semua user MariaDB (kecuali mysql, root, dan mariadb.sys) membutuhkan sertifikat klien X.509 untuk koneksi, memberikan lapisan keamanan tambahan dalam autentikasi."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
