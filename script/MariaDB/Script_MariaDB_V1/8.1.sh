OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Cek nilai require_secure_transport
REQ_SECURE=$(mariadb -N -B -e "SELECT @@require_secure_transport;" 2>/dev/null)
# Cek nilai have_ssl
HAVE_SSL=$(mariadb -N -B -e "SHOW VARIABLES WHERE Variable_name = 'have_ssl';" 2>/dev/null | awk '{print $2}')

DETAILS="require_secure_transport: $REQ_SECURE\nhave_ssl: $HAVE_SSL"

if [[ "$REQ_SECURE" != "1" || "$HAVE_SSL" != "YES" ]]; then
    STATUS="FAIL"
fi

{
    echo "Judul Audit : 8.1 Ensure 'require_secure_transport' is Set to 'ON' and 'have_ssl' is Set to 'YES'"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :\n$DETAILS"
    echo ""
    echo "Nilai CIS :"
    echo "- require_secure_transport harus diset ke 1 untuk memastikan koneksi tidak aman ditolak."
    echo "- have_ssl harus diset ke YES untuk memastikan TLS diaktifkan."
    echo "Deskripsi : Mengaktifkan SSL/TLS akan mengenkripsi lalu lintas jaringan dan memverifikasi identitas server, mencegah penyadapan dan serangan man-in-the-middle."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
