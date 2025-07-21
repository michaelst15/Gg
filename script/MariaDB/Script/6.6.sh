OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil nilai ENCRYPT_LOG dari global_variables
ENCRYPT_LOG_VALUE=$(mariadb -N -B -e "SELECT VARIABLE_VALUE FROM information_schema.global_variables WHERE VARIABLE_NAME LIKE '%ENCRYPT_LOG%';" 2>/dev/null)

# Tentukan PASS/FAIL
if [[ -z "$ENCRYPT_LOG_VALUE" ]]; then
    STATUS="FAIL"
    DETAILS="Variabel ENCRYPT_LOG tidak ditemukan. Binary/relay log mungkin tidak dienkripsi."
elif [[ "$ENCRYPT_LOG_VALUE" != "ON" ]]; then
    STATUS="FAIL"
    DETAILS="ENCRYPT_LOG = $ENCRYPT_LOG_VALUE (seharusnya ON)."
else
    DETAILS="ENCRYPT_LOG aktif (ON), binary dan relay logs dienkripsi."
fi

{
    echo "Judul Audit : 6.6 Ensure Binary and Relay Logs are Encrypted"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "ENCRYPT_LOG: $ENCRYPT_LOG_VALUE"
    echo "$DETAILS"
    echo ""
    echo "Nilai CIS : Variabel ENCRYPT_LOG harus diset ke ON untuk memastikan binary dan relay logs terenkripsi."
    echo "Deskripsi : Mengenkripsi binary dan relay logs melindungi data sensitif yang tersimpan dari ancaman internal maupun eksternal."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
