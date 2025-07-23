OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil nilai konfigurasi global untuk koneksi
GLOBAL_CONN=$(mysql -u root -p'bangtob150420' -N -B -e "SELECT VARIABLE_NAME, VARIABLE_VALUE FROM information_schema.global_variables WHERE VARIABLE_NAME LIKE 'max_%connections';" 2>/dev/null)

# Ambil pengaturan user-specific
USER_CONN=$(mysql -u root -p'bangtob150420' -N -B -e "SELECT user, host, max_connections, max_user_connections FROM mysql.user WHERE user NOT LIKE 'mysql.%' AND user NOT LIKE 'root';" 2>/dev/null)

DETAILS="
$GLOBAL_CONN
"

# Tentukan PASS/FAIL berdasarkan kriteria CIS
MAX_CONN_VAL=$(echo "$GLOBAL_CONN" | awk '$1 == "MAX_CONNECTIONS" {print $2}')
MAX_USER_CONN_VAL=$(echo "$GLOBAL_CONN" | awk '$1 == "MAX_USER_CONNECTIONS" {print $2}')

if [[ -z "$MAX_CONN_VAL" || "$MAX_CONN_VAL" == "0" || "$MAX_USER_CONN_VAL" == "0" ]]; then
    STATUS="FAIL"
fi

# Cek user-specific apakah ada yang tidak punya batasan
UNLIMITED_USERS=$(echo "$USER_CONN" | awk '$3 == 0 && $4 == 0')
if [[ -n "$UNLIMITED_USERS" ]]; then
    STATUS="FAIL"
    DETAILS+="\n\nUser tanpa batasan koneksi:\n$UNLIMITED_USERS"
fi

{
    echo "Judul Audit : 8.3 Set Maximum Connection Limits for Server and per User"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : max_connections dan max_user_connections harus dibatasi, dan setiap user harus memiliki batas koneksi untuk mengurangi risiko DoS."
    echo "Deskripsi : Membatasi jumlah koneksi simultan pada level server dan user membantu mengurangi risiko serangan DoS akibat habisnya resource koneksi."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
