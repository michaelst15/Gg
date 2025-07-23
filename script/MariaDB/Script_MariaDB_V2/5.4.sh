OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Tidak ada user non-admin yang memiliki privilege SUPER."

# Jalankan query untuk memeriksa user yang memiliki privilege SUPER
SUPER_PRIV_USERS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT GRANTEE FROM INFORMATION_SCHEMA.USER_PRIVILEGES
WHERE PRIVILEGE_TYPE = 'SUPER';
" 2>/dev/null)

if [[ -n "$SUPER_PRIV_USERS" ]]; then
    STATUS="Fail"
    DETAILS="
Ditemukan user dengan privilege SUPER:
$SUPER_PRIV_USERS"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.4 Ensure 'SUPER' is Not Granted to Non-Administrative Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Privilege SUPER hanya boleh dimiliki oleh akun administratif."
    echo "Deskripsi : SUPER privilege memungkinkan user melakukan tindakan kritis, termasuk konfigurasi server, menghentikan query milik user lain, mengubah logging, dan lainnya. Pembatasan privilege ini mengurangi risiko penyalahgunaan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
