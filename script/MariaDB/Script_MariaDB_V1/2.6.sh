OUTPUT_FILE="audit_results.txt"

# Cek nilai global default_password_lifetime
DEFAULT_LIFETIME=$(mysql -N -B -e "
SELECT VARIABLE_VALUE
FROM information_schema.global_variables
WHERE VARIABLE_NAME='default_password_lifetime';
")

# Flag untuk status
STATUS="Pass"
DETAILS=""

# Audit nilai global
if [[ -n "$DEFAULT_LIFETIME" && "$DEFAULT_LIFETIME" -gt 365 ]]; then
    STATUS="Fail"
    DETAILS="Global default_password_lifetime is set to $DEFAULT_LIFETIME (> 365)."
else
    # Audit per user
    USER_LIFETIMES=$(mysql -N -B -e "
    WITH password_expiration_info AS (
        SELECT User, Host,
               IF(
                   IFNULL(JSON_EXTRACT(Priv, '$.password_lifetime'), -1) = -1,
                   @@global.default_password_lifetime,
                   JSON_EXTRACT(Priv, '$.password_lifetime')
               ) AS password_lifetime,
               JSON_EXTRACT(Priv, '$.password_last_changed') AS password_last_changed
        FROM mysql.global_priv
    )
    SELECT User, Host, password_lifetime
    FROM password_expiration_info
    WHERE password_lifetime > 365;
    ")

    if [[ -n "$USER_LIFETIMES" ]]; then
        STATUS="Fail"
        DETAILS="Some users have password_lifetime > 365 days: $USER_LIFETIMES"
    else
        DETAILS="All user password_lifetime values are <= 365 days."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.6 Ensure 'password_lifetime' is Less Than or Equal to '365'"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Password lifetime harus <= 365 hari"
    echo "Deskripsi : Verifikasi bahwa password global MariaDB dan password tiap user memiliki masa berlaku ≤ 365 hari, atau password tidak diatur untuk kedaluwarsa (0 = never expires)."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
