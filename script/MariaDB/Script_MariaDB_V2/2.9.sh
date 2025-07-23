OUTPUT_FILE="audit_results.txt"

# Cek nilai bind_address di MariaDB
BIND_ADDRESS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT VARIABLE_VALUE
FROM information_schema.global_variables
WHERE VARIABLE_NAME = 'bind_address';
")

# Evaluasi hasil
if [[ -z "$BIND_ADDRESS" || "$BIND_ADDRESS" == "*" || "$BIND_ADDRESS" == "::" ]]; then
    STATUS="Fail"
    VALUE="bind_address is not restricted (value: '${BIND_ADDRESS:-empty}')"
else
    STATUS="Pass"
    VALUE="MariaDB bind_address is set to $BIND_ADDRESS"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.9 Ensure MariaDB is Bound to an IP Address"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : MariaDB harus dikonfigurasi untuk listen hanya pada IP tertentu, bukan pada semua interface"
    echo "Deskripsi : Verifikasi bahwa parameter 'bind_address' di MariaDB tidak kosong, bukan '*' atau '::', sehingga akses TCP/IP dibatasi hanya pada IP tertentu."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
