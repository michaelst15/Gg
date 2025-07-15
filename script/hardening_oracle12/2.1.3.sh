ORACLE_HOME="/poracle/1120"
LISTENER_ORA="$ORACLE_HOME/network/admin/listener.ora"
OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa pengaturan 'ADMIN_RESTRICTIONS_' pada listener.ora..."

STATUS="Pass"
VALUE=""

if [ -f "$LISTENER_ORA" ]; then
    ADMIN_RESTRICTIONS=$(grep -i "ADMIN_RESTRICTIONS_" "$LISTENER_ORA")

    if [ -n "$ADMIN_RESTRICTIONS" ]; then
        echo "$ADMIN_RESTRICTIONS" | while read -r line; do
            listener=$(echo "$line" | cut -d'=' -f1 | tr -d ' ' | tr '[:lower:]' '[:upper:]')
            value=$(echo "$line" | cut -d'=' -f2 | tr -d ' ' | tr '[:lower:]' '[:upper:]')

            VALUE="${VALUE}${listener}=${value}, "

            if [ "$value" != "ON" ]; then
                STATUS="Fail"
            fi
        done

        # Hapus koma terakhir
        VALUE=$(echo "$VALUE" | sed 's/, $//')
    else
        STATUS="Fail"
        VALUE="Konfigurasi ADMIN_RESTRICTIONS_ tidak ditemukan"
    fi
else
    STATUS="Fail"
    VALUE="File listener.ora tidak ditemukan di $LISTENER_ORA"
fi

{
    echo "Judul Audit       : 2.1.3 Ensure 'ADMIN_RESTRICTIONS_' Is Set to 'ON'"
    echo "Status            : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS         : ON"
    echo "Deskripsi         : Direktif 'ADMIN_RESTRICTIONS_<listener>' harus disetel ke 'ON' untuk memastikan hanya pengguna dengan hak istimewa yang dapat memodifikasi listener.ora secara manual dan me-restart listener. Hal ini melindungi dari perubahan tak sah melalui koneksi runtime."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
