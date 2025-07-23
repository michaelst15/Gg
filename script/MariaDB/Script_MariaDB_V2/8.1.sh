OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Cek nilai require_secure_transport
REQ_SECURE=$(mysql -u root -p'bangtob150420' -N -B -e "SELECT @@require_secure_transport;" 2>/dev/null)
# Jika kosong, set ke "Empty"
if [[ -z "$REQ_SECURE" ]]; then
    REQ_SECURE="Empty"
fi

# Cek nilai have_ssl
HAVE_SSL=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW VARIABLES WHERE Variable_name = 'have_ssl';" 2>/dev/null | awk '{print $2}')
# Jika kosong, set ke "Empty"
if [[ -z "$HAVE_SSL" ]]; then
    HAVE_SSL="Empty"
fi

DETAILS="
require_secure_transport: $REQ_SECURE
have_ssl: $HAVE_SSL
"

if [[ "$REQ_SECURE" != "1" || "$HAVE_SSL" != "YES" ]]; then
    STATUS="FAIL"
fi

{
    echo "Judul Audit : 8.1 Ensure 'require_secure_transport' is Set to 'ON' and 'have_ssl' is Set to 'YES'"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS :"
    echo "- require_secure_transport harus diset ke 1 untuk memastikan koneksi tidak aman ditolak."
    echo "- have_ssl harus diset ke YES untuk memastikan TLS diaktifkan."
    echo "Deskripsi : Mengaktifkan SSL/TLS akan mengenkripsi lalu lintas jaringan dan memverifikasi identitas server, mencegah penyadapan dan serangan man-in-the-middle."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
