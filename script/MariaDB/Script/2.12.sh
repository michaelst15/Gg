OUTPUT_FILE="audit_results.txt"

# Cek cipher SSL/TLS yang digunakan MariaDB
SSL_CIPHER=$(mysql -N -B -e "
SELECT VARIABLE_VALUE
FROM information_schema.global_variables
WHERE VARIABLE_NAME = 'ssl_cipher';
")

# Daftar cipher yang disetujui (contoh, dapat disesuaikan dengan kebijakan organisasi)
APPROVED_CIPHERS=("AES256-SHA" "AES256-SHA256" "TLS_AES_256_GCM_SHA384" "TLS_CHACHA20_POLY1305_SHA256")

# Fungsi untuk memeriksa apakah cipher yang digunakan ada dalam daftar yang disetujui
is_approved=false
for cipher in "${APPROVED_CIPHERS[@]}"; do
    if [[ "$SSL_CIPHER" == *"$cipher"* ]]; then
        is_approved=true
        break
    fi
done

# Evaluasi hasil
if [[ -z "$SSL_CIPHER" ]]; then
    STATUS="Fail"
    VALUE="ssl_cipher is empty; MariaDB not enforcing strong ciphers."
elif [[ "$is_approved" = false ]]; then
    STATUS="Fail"
    VALUE="Unapproved cipher in use: $SSL_CIPHER"
else
    STATUS="Pass"
    VALUE="Approved cipher in use: $SSL_CIPHER"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.12 Ensure Only Approved Ciphers are Used"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : MariaDB harus dikonfigurasi untuk hanya menggunakan cipher TLS yang kuat dan disetujui."
    echo "Deskripsi : Verifikasi bahwa MariaDB hanya menerima koneksi yang menggunakan cipher TLS yang sesuai kebijakan keamanan organisasi, untuk melindungi data dalam transit."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
