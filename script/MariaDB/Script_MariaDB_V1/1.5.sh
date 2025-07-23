OUTPUT_FILE="audit_results.txt"

# Ambil informasi akun mysql dari /etc/passwd
MYSQL_USER_INFO=$(getent passwd mysql)

# Default hasil
STATUS="Fail"
VALUE="MariaDB user has interactive login enabled or does not exist"

if [[ -n "$MYSQL_USER_INFO" ]]; then
    LOGIN_SHELL=$(echo "$MYSQL_USER_INFO" | awk -F: '{print $7}')
    if [[ "$LOGIN_SHELL" == "/sbin/nologin" || "$LOGIN_SHELL" == "/usr/sbin/nologin" || "$LOGIN_SHELL" == "/bin/false" ]]; then
        STATUS="Pass"
        VALUE="MariaDB user has interactive login disabled ($LOGIN_SHELL)"
    else
        VALUE="MariaDB user login shell is $LOGIN_SHELL (should be nologin or false)"
    fi
else
    VALUE="MariaDB user 'mysql' not found"
fi

# Tulis hasil ke file audit
{
    echo "Judul Audit : 1.5 Ensure Interactive Login is Disabled"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Akun MariaDB harus menggunakan shell /sbin/nologin atau /bin/false untuk mencegah login interaktif"
    echo "Deskripsi : Verifikasi bahwa user MariaDB tidak dapat melakukan login interaktif ke sistem operasi."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
