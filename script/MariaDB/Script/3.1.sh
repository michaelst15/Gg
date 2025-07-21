OUTPUT_FILE="audit_results.txt"

# Ambil nilai datadir dari MariaDB
DATADIR=$(mysql -N -B -e "
SELECT VARIABLE_VALUE
FROM information_schema.global_variables
WHERE VARIABLE_NAME = 'datadir';
")

# Cek apakah datadir ditemukan
if [[ -z "$DATADIR" ]]; then
    STATUS="Fail"
    VALUE="Tidak dapat menentukan datadir dari MariaDB."
else
    # Cek permission direktori datadir
    PERMISSIONS=$(sudo ls -ld "$DATADIR" 2>/dev/null | grep "drwxr-x---.*mysql.*mysql")

    if [[ -n "$PERMISSIONS" ]]; then
        STATUS="Pass"
        VALUE="datadir ($DATADIR) memiliki permission yang sesuai: $PERMISSIONS"
    else
        STATUS="Fail"
        VALUE="datadir ($DATADIR) tidak memiliki permission drwxr-x--- dengan user dan group mysql."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.1 Ensure 'datadir' Has Appropriate Permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Direktori data MariaDB harus memiliki permission 'drwxr-x---' dengan user dan group 'mysql'."
    echo "Deskripsi : Memastikan bahwa direktori data MariaDB hanya dapat diakses oleh user dan group MariaDB, untuk melindungi kerahasiaan, integritas, dan ketersediaan database."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
