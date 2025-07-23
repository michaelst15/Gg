OUTPUT_FILE="audit_results.txt"

# Cek apakah tabel mysql.global_priv ada (MariaDB >=10.4)
TABLE_EXISTS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT COUNT(*) 
FROM information_schema.tables 
WHERE table_schema='mysql' 
AND table_name='global_priv';
" 2>/dev/null)

STATUS="Pass"
VALUE=""

if [[ "$TABLE_EXISTS" -eq 1 ]]; then
    # Versi baru (MariaDB >=10.4)
    LOCK_STATUS=$(mysql -u root -p'bangtob150420' -N -B -e "
    SELECT CONCAT(User, '@', Host, ' => ', JSON_DETAILED(Priv))
    FROM mysql.global_priv;
    " 2>/dev/null)

    UNLOCKED_ACCOUNTS=$(echo "$LOCK_STATUS" | grep -v "account_locked\": true")

elif mysql -u root -p'bangtob150420' -e "SHOW COLUMNS FROM mysql.user LIKE 'account_locked';" 2>/dev/null | grep -q 'account_locked'; then
    # Versi menengah (MariaDB <10.4 tapi punya kolom account_locked)
    LOCK_STATUS=$(mysql -u root -p'bangtob150420' -N -B -e "
    SELECT CONCAT(User, '@', Host, ' => account_locked:', account_locked)
    FROM mysql.user;
    " 2>/dev/null)

    UNLOCKED_ACCOUNTS=$(echo "$LOCK_STATUS" | grep -v "account_locked:Y")
else
    # Versi lama (tidak ada kolom account_locked)
    LOCK_STATUS="Empty (field not supported in this MariaDB version)"
    UNLOCKED_ACCOUNTS="$LOCK_STATUS"
fi

# Evaluasi status
if [[ -n "$UNLOCKED_ACCOUNTS" && "$UNLOCKED_ACCOUNTS" != "Empty (field not supported in this MariaDB version)" ]]; then
    STATUS="Fail"
    VALUE="
Some accounts are not locked: 
$UNLOCKED_ACCOUNTS"
elif [[ "$UNLOCKED_ACCOUNTS" == "Empty (field not supported in this MariaDB version)" ]]; then
    STATUS="Fail"
    VALUE="$UNLOCKED_ACCOUNTS"
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
    echo "Deskripsi : Versi MariaDB ini tidak memiliki fitur account_locked atau beberapa akun belum dikunci. Semua akun yang tidak digunakan harus dikunci untuk mengurangi risiko penyalahgunaan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
