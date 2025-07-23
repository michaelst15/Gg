OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="secure_file_priv dikonfigurasi dengan benar."

# Periksa nilai secure_file_priv di MariaDB
SECURE_FILE_PRIV=$(mariadb -N -B -e "SHOW GLOBAL VARIABLES WHERE Variable_name = 'secure_file_priv';" 2>/dev/null | awk '{print $2}')

if [[ -z "$SECURE_FILE_PRIV" ]]; then
    STATUS="Fail"
    DETAILS="secure_file_priv kosong (''), harus NULL atau path direktori yang valid."
elif [[ "$SECURE_FILE_PRIV" == "NULL" ]]; then
    DETAILS="secure_file_priv diset NULL, LOAD DATA INFILE dinonaktifkan."
else
    if [[ ! -d "$SECURE_FILE_PRIV" ]]; then
        STATUS="Fail"
        DETAILS="secure_file_priv diset ke path yang tidak ada: $SECURE_FILE_PRIV."
    fi
fi

# Simpan hasil audit
{
    echo "Judul Audit : 4.7 Ensure the 'secure_file_priv' is Configured Correctly"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : secure_file_priv harus NULL (untuk menonaktifkan) atau path direktori khusus yang aman."
    echo "Deskripsi : Opsi ini membatasi direktori yang dapat digunakan oleh LOAD DATA INFILE atau SELECT INTO OUTFILE, untuk mengurangi risiko SQL injection yang membaca file sensitif."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
