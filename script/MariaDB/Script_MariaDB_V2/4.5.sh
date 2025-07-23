#!/bin/bash

OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Tidak ditemukan konfigurasi 'skip-grant-tables' atau 'skip_grant_tables' yang aktif."

# Lokasi file konfigurasi utama MariaDB
CONFIG_FILE="/etc/mysql/mariadb.cnf"

# Cari parameter skip-grant-tables di file konfigurasi MariaDB
if grep -Eiq '^\s*(skip-grant-tables|skip_grant_tables)\s*=?\s*(1|on|true|yes)?' "$CONFIG_FILE" 2>/dev/null; then
    STATUS="Fail"
    DETAILS="
Ditemukan 'skip-grant-tables' atau 'skip_grant_tables' diaktifkan di $CONFIG_FILE."
fi

# Simpan hasil audit
{
    echo "Judul Audit : 4.5 Ensure MariaDB is Not Started With 'skip-grant-tables'"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Pastikan MariaDB tidak dijalankan dengan 'skip-grant-tables' atau 'skip_grant_tables' aktif."
    echo "Deskripsi : Jika opsi ini aktif, semua klien memiliki akses penuh ke seluruh database tanpa otentikasi."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
