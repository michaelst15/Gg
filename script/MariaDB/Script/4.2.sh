OUTPUT_FILE="audit_results.txt"

STATUS="Pass"
DETAILS=""

# Cek database yang ada, kecuali bawaan
DB_LIST=$(mysql -N -B -e "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME NOT IN ('mysql','information_schema','sys','performance_schema');" 2>/dev/null)

if [[ -z "$DB_LIST" ]]; then
    DETAILS="Tidak ada database contoh atau test yang ditemukan."
else
    STATUS="Fail"
    DETAILS="Ditemukan database non-standar: $DB_LIST\nPastikan ini bukan database contoh atau test di production."
fi

# Simpan hasil audit
{
    echo "Judul Audit : 4.2 Ensure Example or Test Databases are Not Installed on Production Servers"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Database contoh atau test tidak boleh ada di server produksi."
    echo "Deskripsi : Menghapus database contoh akan mengurangi attack surface pada server MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
