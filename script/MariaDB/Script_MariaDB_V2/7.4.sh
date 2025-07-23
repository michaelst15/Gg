OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Cek plugin password complexity yang aktif
PLUGINS=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW PLUGINS;" 2>/dev/null | grep -E 'simple_password_check|cracklib_password_check' | grep ACTIVE)

# Ambil variabel password policy
PASSWORD_VARS=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW VARIABLES LIKE '%pass%';" 2>/dev/null)

DETAILS=""

if [[ -z "$PLUGINS" ]]; then
    STATUS="FAIL"
    DETAILS+="
    * Plugin password complexity (simple_password_check atau cracklib_password_check) tidak aktif.
    "
else
    DETAILS+="
    * Plugin aktif: $PLUGINS
    "
fi

# Cek nilai minimal panjang password
MIN_LENGTH=$(echo "$PASSWORD_VARS" | awk '/simple_password_check_minimal_length/ {print $2}')
STRICT_VALIDATION=$(echo "$PASSWORD_VARS" | awk '/strict_password_validation/ {print $2}')
DICTIONARY_FILE=$(echo "$PASSWORD_VARS" | awk '/cracklib_password_check_dictionary/ {print $2}')

if [[ -z "$MIN_LENGTH" || "$MIN_LENGTH" -lt 14 ]]; then
    STATUS="FAIL"
    DETAILS+="
    * simple_password_check_minimal_length kurang dari 14.
    "
fi

if [[ "$STRICT_VALIDATION" != "ON" ]]; then
    STATUS="FAIL"
    DETAILS+="
    * strict_password_validation tidak diaktifkan.
    "
fi

if [[ -z "$DICTIONARY_FILE" ]]; then
    STATUS="FAIL"
    DETAILS+="
    * cracklib_password_check_dictionary tidak diatur ke file kamus yang sesuai.
    "
else
    DETAILS+="
    * Dictionary file digunakan: $DICTIONARY_FILE
    "
fi

if [[ "$STATUS" == "PASS" ]]; then
    DETAILS+="
    * Semua kebijakan kompleksitas password memenuhi rekomendasi.
    "
fi

{
    echo "Judul Audit : 7.4 Ensure Password Complexity Policies are in Place"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo "Nilai CIS :"
    echo "• simple_password_check_minimal_length harus >= 14"
    echo "• strict_password_validation harus ON"
    echo "• cracklib_password_check_dictionary harus diatur ke file kamus yang sesuai"
    echo "Deskripsi : Kebijakan password yang kuat membantu mencegah serangan brute force, dictionary, dan penggunaan password yang mudah ditebak."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
