OUTPUT_FILE="audit_results.txt"

# Cek versi TLS yang diterima MariaDB
TLS_VERSIONS=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW VARIABLES LIKE 'tls_version';" 2>/dev/null | awk '{print $2}')

# Jika kosong, set ke "Empty"
if [[ -z "$TLS_VERSIONS" ]]; then
    TLS_VERSIONS="Empty"
    STATUS="Fail"
    VALUE="
Tidak dapat menentukan versi TLS yang diterima (variabel tls_version tidak tersedia di MariaDB ini).
"
else
    # Evaluasi hasil
    if echo "$TLS_VERSIONS" | grep -E "TLSv1(\.1)?"; then
        STATUS="Fail"
        VALUE="
MariaDB menerima TLS lemah: 
$TLS_VERSIONS"
    else
        STATUS="Pass"
        VALUE="
Accepted TLS versions are secure: 
$TLS_VERSIONS"
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.10 Limit Accepted Transport Layer Security (TLS) Versions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : MariaDB tidak boleh menerima koneksi TLSv1 atau TLSv1.1, hanya TLSv1.2 atau lebih baru"
    echo "Deskripsi : Verifikasi bahwa MariaDB hanya menerima koneksi menggunakan TLS modern (TLSv1.2 atau TLSv1.3), untuk melindungi data dalam transit dari serangan downgrade."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
