OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil daftar user remote dengan ssl_type
REMOTE_USERS=$(mariadb -N -B -e "SELECT user, host, ssl_type FROM mysql.user WHERE NOT HOST IN ('::1', '127.0.0.1', 'localhost');" 2>/dev/null)

# Cek apakah ada user dengan ssl_type tidak sesuai
INVALID_USERS=$(echo "$REMOTE_USERS" | awk '$3 != "ANY" && $3 != "X509" && $3 != "SPECIFIED"')

DETAILS="Daftar user remote dengan ssl_type:\n$REMOTE_USERS"

if [[ -n "$INVALID_USERS" ]]; then
    STATUS="FAIL"
    DETAILS+="\n\nUser dengan ssl_type tidak sesuai:\n$INVALID_USERS"
fi

{
    echo "Judul Audit : 8.2 Ensure 'ssl_type' is Set to 'ANY', 'X509', or 'SPECIFIED' for All Remote Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :\n$DETAILS"
    echo ""
    echo "Nilai CIS : ssl_type untuk semua user remote harus diset ke ANY, X509, atau SPECIFIED untuk memastikan SSL/TLS digunakan."
    echo "Deskripsi : SSL/TLS mencegah penyadapan dan serangan man-in-the-middle. User tanpa pengaturan ini dapat menghubungkan tanpa enkripsi."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
