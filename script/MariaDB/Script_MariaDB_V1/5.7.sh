OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Tidak ada user non-admin yang memiliki GRANT OPTION."

# Jalankan query untuk memeriksa user dengan GRANT OPTION
GRANT_OPTION_USERS=$(mariadb -N -B -e "
SELECT DISTINCT GRANTEE
FROM INFORMATION_SCHEMA.USER_PRIVILEGES
WHERE IS_GRANTABLE = 'YES';
" 2>/dev/null)

if [[ -n "$GRANT_OPTION_USERS" ]]; then
    STATUS="Fail"
    DETAILS="Ditemukan user dengan GRANT OPTION:\n$GRANT_OPTION_USERS"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.7 Ensure 'GRANT OPTION' is Not Granted to Non-Administrative Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : GRANT OPTION hanya boleh dimiliki oleh akun administratif."
    echo "Deskripsi : GRANT OPTION memungkinkan user memberikan privilege tambahan kepada user lain. Membatasi hak ini mengurangi risiko eskalasi hak akses yang tidak sah."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
