OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Tidak ada user non-admin yang memiliki hak FILE."

# Jalankan query untuk memeriksa user yang memiliki privilege FILE
FILE_PRIV_USERS=$(mariadb -N -B -e "
SELECT GRANTEE FROM INFORMATION_SCHEMA.USER_PRIVILEGES
WHERE PRIVILEGE_TYPE = 'FILE';
" 2>/dev/null)

if [[ -n "$FILE_PRIV_USERS" ]]; then
    STATUS="Fail"
    DETAILS="Ditemukan user dengan privilege FILE:\n$FILE_PRIV_USERS"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.2 Ensure 'FILE' is Not Granted to Non-Administrative Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Privilege FILE hanya boleh dimiliki oleh akun administratif."
    echo "Deskripsi : FILE privilege memberikan kemampuan untuk membaca/menulis file pada host server, yang dapat digunakan untuk mengeksploitasi MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
