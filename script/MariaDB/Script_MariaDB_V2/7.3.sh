OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Jalankan query untuk menemukan akun yang menggunakan plugin autentikasi lemah
WEAK_AUTH_USERS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT User, Host
FROM mysql.user
WHERE (plugin IN('mysql_native_password', 'mysql_old_password', '')
  AND NOT (User = 'root' AND authentication_string = 'invalid')
  AND NOT (User = 'mysql' AND authentication_string = 'invalid'));
" 2>/dev/null)

DETAILS=""
if [[ -n "$WEAK_AUTH_USERS" ]]; then
    STATUS="FAIL"
    DETAILS="Ditemukan akun dengan autentikasi lemah: $WEAK_AUTH_USERS"
else
    DETAILS="Tidak ditemukan akun yang menggunakan plugin autentikasi lemah (mysql_native_password, mysql_old_password, atau kosong)."
fi

{
    echo "Judul Audit : 7.3 Ensure strong authentication is utilized for all accounts"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo "Nilai CIS : Tidak boleh ada akun yang menggunakan mysql_native_password, mysql_old_password, atau plugin kosong, kecuali untuk user 'root' dan 'mysql' yang memiliki authentication_string = 'invalid'."
    echo "Deskripsi : Penggunaan plugin autentikasi lemah dapat menyebabkan risiko kebocoran password dan serangan Pass-the-Hash. Disarankan menggunakan plugin autentikasi yang lebih kuat seperti ed25519."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
