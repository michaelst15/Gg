OUTPUT_FILE="audit_results.txt"

STATUS="Pass"
DETAILS=""

# Cek apakah parameter allow-suspicious-udfs ada di konfigurasi MariaDB
ALLOW_SUSPICIOUS=$(my_print_defaults mysqld | grep -i "allow-suspicious-udfs")

if [[ -n "$ALLOW_SUSPICIOUS" ]]; then
    STATUS="Fail"
    DETAILS="
Parameter 'allow-suspicious-udfs' ditemukan di konfigurasi: 
$ALLOW_SUSPICIOUS. Nilai harus dihapus atau diset OFF."
else
    DETAILS="Parameter 'allow-suspicious-udfs' tidak ditemukan di konfigurasi MariaDB (status OFF)."
fi

# Simpan hasil audit
{
    echo "Judul Audit : 4.3 Ensure 'allow-suspicious-udfs' is Set to 'OFF'"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : 'allow-suspicious-udfs' harus OFF dan tidak boleh disertakan di startup MariaDB."
    echo "Deskripsi : Mencegah pemuatan library sembarangan sebagai UDF, mengurangi attack surface server."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
