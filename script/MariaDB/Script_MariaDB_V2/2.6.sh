OUTPUT_FILE="audit_results.txt"

# Cek apakah default_password_lifetime ada
VAR_EXISTS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT COUNT(*)
FROM information_schema.global_variables
WHERE VARIABLE_NAME='default_password_lifetime';
" 2>/dev/null)

STATUS="Pass"
DETAILS=""

if [[ "$VAR_EXISTS" -eq 0 ]]; then
    STATUS="Fail"
    DETAILS="default_password_lifetime: Empty (variable not supported in this MariaDB version)."
else
    # Ambil nilai default_password_lifetime
    DEFAULT_LIFETIME=$(mysql -u root -p'bangtob150420' -N -B -e "
    SELECT VARIABLE_VALUE
    FROM information_schema.global_variables
    WHERE VARIABLE_NAME='default_password_lifetime';
    " 2>/dev/null)

    if [[ -n "$DEFAULT_LIFETIME" && "$DEFAULT_LIFETIME" -gt 365 ]]; then
        STATUS="Fail"
        DETAILS="Global default_password_lifetime is set to $DEFAULT_LIFETIME (> 365)."
    else
        DETAILS="default_password_lifetime is supported and ≤ 365 days."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.6 Ensure 'password_lifetime' is Less Than or Equal to '365'"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Password lifetime harus <= 365 hari"
    echo "Deskripsi : Versi MariaDB ini tidak memiliki variabel default_password_lifetime. CIS merekomendasikan pengaturan masa berlaku password ≤ 365 hari, atau password tidak diatur untuk kedaluwarsa (0 = never expires)."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
