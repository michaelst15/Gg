OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Tidak ada user non-admin yang memiliki privilege CREATE USER."

# Jalankan query untuk memeriksa user yang memiliki privilege CREATE USER
CREATE_USER_PRIV_USERS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT GRANTEE FROM INFORMATION_SCHEMA.USER_PRIVILEGES
WHERE PRIVILEGE_TYPE = 'CREATE USER';
" 2>/dev/null)

if [[ -n "$CREATE_USER_PRIV_USERS" ]]; then
    STATUS="Fail"
    DETAILS="
Ditemukan user dengan privilege CREATE USER:
$CREATE_USER_PRIV_USERS"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.6 Ensure 'CREATE USER' is Not Granted to Non-Administrative Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Privilege CREATE USER hanya boleh dimiliki oleh akun administratif."
    echo "Deskripsi : CREATE USER privilege memungkinkan user membuat, menghapus, dan mengubah akun user lain. Pembatasan privilege ini meminimalkan risiko penyalahgunaan hak akses."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
