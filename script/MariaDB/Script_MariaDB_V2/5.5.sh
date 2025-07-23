OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Tidak ada user non-admin yang memiliki privilege SHUTDOWN."

# Jalankan query untuk memeriksa user yang memiliki privilege SHUTDOWN
SHUTDOWN_PRIV_USERS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT GRANTEE FROM INFORMATION_SCHEMA.USER_PRIVILEGES
WHERE PRIVILEGE_TYPE = 'SHUTDOWN';
" 2>/dev/null)

if [[ -n "$SHUTDOWN_PRIV_USERS" ]]; then
    STATUS="Fail"
    DETAILS="
Ditemukan user dengan privilege SHUTDOWN:
$SHUTDOWN_PRIV_USERS"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.5 Ensure 'SHUTDOWN' is Not Granted to Non-Administrative Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Privilege SHUTDOWN hanya boleh dimiliki oleh akun administratif."
    echo "Deskripsi : SHUTDOWN privilege memungkinkan user mematikan server MariaDB, yang dapat disalahgunakan untuk mengganggu ketersediaan sistem. Privilege ini harus dibatasi hanya untuk administrator."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
