OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Tidak ada user non-admin yang memiliki privilege PROCESS."

# Jalankan query untuk memeriksa user yang memiliki privilege PROCESS
PROCESS_PRIV_USERS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT GRANTEE FROM INFORMATION_SCHEMA.USER_PRIVILEGES
WHERE PRIVILEGE_TYPE = 'PROCESS';
" 2>/dev/null)

if [[ -n "$PROCESS_PRIV_USERS" ]]; then
    STATUS="Fail"
    DETAILS="
Ditemukan user dengan privilege PROCESS:
$PROCESS_PRIV_USERS"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.3 Ensure 'PROCESS' is Not Granted to Non-Administrative Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Privilege PROCESS hanya boleh dimiliki oleh akun administratif."
    echo "Deskripsi : PROCESS privilege memungkinkan user melihat eksekusi statement milik session lain, termasuk yang mengandung data sensitif seperti manajemen password."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
