OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Cek user yang punya host wildcard
WILDCARD_USERS=$(mariadb -N -B -e "SELECT user, host FROM mysql.user WHERE host = '%';" 2>/dev/null)

DETAILS=""

if [[ -n "$WILDCARD_USERS" ]]; then
    STATUS="FAIL"
    DETAILS="Ditemukan user dengan wildcard hostnames:\n$WILDCARD_USERS"
else
    DETAILS="Tidak ada user dengan wildcard hostnames ('%')."
fi

{
    echo "Judul Audit : 7.5 Ensure No Users Have Wildcard Hostnames"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo ""
    echo "Nilai CIS : Tidak boleh ada user dengan host = '%'."
    echo "Deskripsi : Hindari penggunaan wildcard hostnames untuk mengontrol dari lokasi mana user dapat terhubung ke database."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
