OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil nilai old_passwords dan secure_auth
OLD_PASSWORDS=$(mariadb -N -B -e "SHOW VARIABLES WHERE Variable_name = 'old_passwords';" 2>/dev/null | awk '{print $2}')
SECURE_AUTH=$(mariadb -N -B -e "SHOW VARIABLES WHERE Variable_name = 'secure_auth';" 2>/dev/null | awk '{print $2}')

# Tentukan PASS/FAIL
DETAILS=""
if [[ "$OLD_PASSWORDS" != "OFF" ]]; then
    STATUS="FAIL"
    DETAILS+="old_passwords = $OLD_PASSWORDS (seharusnya OFF). "
fi
if [[ "$SECURE_AUTH" != "ON" ]]; then
    STATUS="FAIL"
    DETAILS+="secure_auth = $SECURE_AUTH (seharusnya ON)."
fi

if [[ "$STATUS" == "PASS" ]]; then
    DETAILS="mysql_old_password plugin dinonaktifkan. old_passwords = OFF dan secure_auth = ON."
fi

{
    echo "Judul Audit : 7.1 Disable use of the mysql_old_password plugin"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "old_passwords: $OLD_PASSWORDS"
    echo "secure_auth: $SECURE_AUTH"
    echo "$DETAILS"
    echo ""
    echo "Nilai CIS :"
    echo "• old_passwords harus OFF"
    echo "• secure_auth harus ON"
    echo "Deskripsi : Menonaktifkan mysql_old_password mencegah penggunaan algoritma hash lama yang rentan dan memblokir koneksi klien yang menggunakan plugin ini."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
