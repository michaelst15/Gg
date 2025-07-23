OUTPUT_FILE="audit_results.txt"

# Cek versi TLS yang diterima MariaDB
TLS_VERSIONS=$(mysql -N -B -e "SELECT @@tls_version;")

# Evaluasi hasil
if echo "$TLS_VERSIONS" | grep -E "TLSv1(\.1)?"; then
    STATUS="Fail"
    VALUE="MariaDB accepts weak TLS versions: $TLS_VERSIONS"
else
    STATUS="Pass"
    VALUE="Accepted TLS versions are secure: $TLS_VERSIONS"
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
