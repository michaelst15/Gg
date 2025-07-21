OUTPUT_FILE="audit_results.txt"

# Ambil status account MariaDB dari mysql.global_priv
LOCK_STATUS=$(mysql -N -B -e "
SELECT CONCAT(User, '@', Host, ' => ', JSON_DETAILED(Priv))
FROM mysql.global_priv;
")

# Identifikasi akun yang tidak terkunci tetapi mungkin tidak digunakan
# (Cek akun yang tidak memiliki 'account_locked:true' di JSON priv)
UNLOCKED_ACCOUNTS=$(echo "$LOCK_STATUS" | grep -v "account_locked\": true")

if [[ -n "$UNLOCKED_ACCOUNTS" ]]; then
    STATUS="Fail"
    VALUE="Some accounts are not locked: $UNLOCKED_ACCOUNTS"
else
    STATUS="Pass"
    VALUE="All unused or reserved accounts are locked"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.7 Lock Out Accounts if Not Currently in Use"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Akun MariaDB yang tidak digunakan harus dalam status account_locked:true"
    echo "Deskripsi : Verifikasi bahwa semua akun MariaDB yang tidak digunakan atau dicurigai sudah dikunci untuk mengurangi risiko penyalahgunaan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
