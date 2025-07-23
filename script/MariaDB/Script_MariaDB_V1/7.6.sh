OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Cek akun anonim (user kosong)
ANON_USERS=$(mariadb -N -B -e "SELECT user, host FROM mysql.user WHERE user = '';" 2>/dev/null)

DETAILS=""

if [[ -n "$ANON_USERS" ]]; then
    STATUS="FAIL"
    DETAILS="Ditemukan akun anonim (user=''):\n$ANON_USERS"
else
    DETAILS="Tidak ada akun anonim (user='')."
fi

{
    echo "Judul Audit : 7.6 Ensure No Anonymous Accounts Exist"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo ""
    echo "Nilai CIS : Tidak boleh ada akun dengan user kosong ('')."
    echo "Deskripsi : Menghapus akun anonim memastikan hanya pengguna teridentifikasi dan tepercaya yang dapat berinteraksi dengan MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
