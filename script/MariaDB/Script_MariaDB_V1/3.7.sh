OUTPUT_FILE="audit_results.txt"

# Ambil semua file SSL yang digunakan oleh MariaDB
SSL_FILES=$(mysql -N -B -e "SELECT VARIABLE_VALUE FROM information_schema.global_variables WHERE REGEXP_INSTR(VARIABLE_NAME,'^ssl_(ca|capath|cert|crl|crlpath|key)$') AND VARIABLE_VALUE <> '';")

STATUS="Pass"
DETAILS=""

if [[ -z "$SSL_FILES" ]]; then
    STATUS="Pass"
    DETAILS="MariaDB tidak menggunakan SSL/TLS, tidak ada file SSL yang perlu diperiksa."
else
    while read -r FILE; do
        if [[ -f "$FILE" ]]; then
            COMPLIANT=$(ls -l "$FILE" 2>/dev/null | grep '^-r--------.*mysql.*mysql')
            if [[ -z "$COMPLIANT" ]]; then
                STATUS="Fail"
                DETAILS+="File $FILE tidak memiliki permission '-r--------' dan owner 'mysql:mysql'.\n"
            else
                DETAILS+="File $FILE memiliki permission sesuai (-r-------- mysql mysql).\n"
            fi
        else
            STATUS="Fail"
            DETAILS+="File $FILE tidak ditemukan di sistem.\n"
        fi
    done <<< "$SSL_FILES"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.7 Ensure SSL Key Files Have Appropriate Permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Semua file SSL MariaDB harus memiliki permission '-r--------' dan dimiliki oleh user dan group 'mysql'."
    echo "Deskripsi : Memastikan file kunci SSL MariaDB hanya dapat diakses oleh user MariaDB untuk mencegah kebocoran kunci yang dapat menyebabkan serangan man-in-the-middle."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
