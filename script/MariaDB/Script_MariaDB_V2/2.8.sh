OUTPUT_FILE="audit_results.txt"

# Cek apakah plugin unix_socket aktif
PLUGIN_STATUS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT PLUGIN_STATUS
FROM INFORMATION_SCHEMA.PLUGINS
WHERE PLUGIN_NAME = 'unix_socket';
" 2>/dev/null)

# Cek user yang menggunakan unix_socket (fallback untuk versi lama)
USER_LIST=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT CONCAT(User, '@', Host)
FROM mysql.user
WHERE plugin = 'unix_socket';
" 2>/dev/null)

# Jika kosong, set ke "Empty"
if [[ -z "$PLUGIN_STATUS" ]]; then
    PLUGIN_STATUS="Empty"
fi
if [[ -z "$USER_LIST" ]]; then
    USER_LIST="Empty"
fi

# Default status
STATUS="Pass"
DETAILS=""

# Evaluasi kondisi plugin
if [[ "$PLUGIN_STATUS" == "ACTIVE" ]]; then
    # Plugin aktif, periksa apakah ada user yang menggunakan unix_socket dengan host bukan localhost
    INVALID_USERS=$(echo "$USER_LIST" | grep -v "@localhost" | grep -v "@127.0.0.1")
    if [[ -n "$INVALID_USERS" && "$USER_LIST" != "Empty" ]]; then
        STATUS="Fail"
        DETAILS="
unix_socket plugin active; unauthorized users or non-localhost hosts detected: 
$INVALID_USERS"
    else
        DETAILS="unix_socket plugin active; all users limited to localhost."
    fi
else
    DETAILS="unix_socket plugin is not active."
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.8 Ensure Socket Peer-Credential Authentication is Used Appropriately"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Plugin unix_socket hanya boleh digunakan bila dibutuhkan, dengan host terbatas ke localhost dan user yang diotorisasi."
    echo "Deskripsi : Verifikasi bahwa plugin unix_socket hanya aktif ketika sesuai kebijakan, dan semua user yang menggunakannya dibatasi untuk akses lokal saja."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
