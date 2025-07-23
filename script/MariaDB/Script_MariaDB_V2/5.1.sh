OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Hanya user administratif yang memiliki akses penuh ke database."

# Jalankan query untuk memeriksa user dengan privileges penuh
FULL_PRIV_USERS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT * FROM information_schema.user_privileges
WHERE GRANTEE NOT LIKE \"'mysql.%'@'localhost'\";
" 2>/dev/null)

if [[ -n "$FULL_PRIV_USERS" ]]; then
    STATUS="Fail"
    DETAILS="
Ditemukan user non-administratif dengan privileges penuh:
$FULL_PRIV_USERS"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.1 Ensure Only Administrative Users Have Full Database Access"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Hanya akun administratif yang boleh memiliki akses penuh ke database."
    echo "Deskripsi : Membatasi akses penuh ke mysql.* melindungi kerahasiaan, integritas, dan ketersediaan data di MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
