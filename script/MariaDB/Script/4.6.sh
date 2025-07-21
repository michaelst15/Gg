#!/bin/bash

OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Symbolic links dinonaktifkan pada MariaDB."

# Periksa status symbolic links di MariaDB
SYMLINK_STATUS=$(mariadb -N -B -e "SHOW VARIABLES LIKE 'have_symlink';" 2>/dev/null | awk '{print $2}')

if [[ "$SYMLINK_STATUS" != "DISABLED" ]]; then
    STATUS="Fail"
    DETAILS="Symbolic links saat ini diaktifkan (have_symlink=$SYMLINK_STATUS)."
fi

# Simpan hasil audit
{
    echo "Judul Audit : 4.6 Ensure Symbolic Links are Disabled"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Pastikan 'symbolic-links' dinonaktifkan di MariaDB."
    echo "Deskripsi : Opsi symbolic-links memungkinkan file database diarahkan ke lokasi lain, yang dapat disalahgunakan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
