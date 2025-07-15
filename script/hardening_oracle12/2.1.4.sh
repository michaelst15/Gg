# Ganti path ORACLE_HOME sesuai dengan lingkungan Anda
ORACLE_HOME="/poracle/1120"
LISTENER_ORA="$ORACLE_HOME/network/admin/listener.ora"
OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa pengaturan 'SECURE_REGISTER_' pada listener.ora..."

STATUS="Pass"
VALUE=""

if [ -f "$LISTENER_ORA" ]; then
    SECURE_REGISTER_LINES=$(grep -i "SECURE_REGISTER_" "$LISTENER_ORA")

    if [ -n "$SECURE_REGISTER_LINES" ]; then
        echo "$SECURE_REGISTER_LINES" | while read -r line; do
            listener=$(echo "$line" | cut -d'=' -f1 | tr -d ' ' | tr '[:lower:]' '[:upper:]')
            protocol=$(echo "$line" | cut -d'=' -f2 | tr -d ' ' | tr '[:lower:]' '[:upper:]')

            VALUE="${VALUE}${listener}=${protocol}, "

            # Validasi protokol harus TCPS atau IPC
            if [ "$protocol" != "TCPS" ] && [ "$protocol" != "IPC" ]; then
                STATUS="Fail"
            fi
        done

        # Hapus koma terakhir dan spasi
        VALUE=$(echo "$VALUE" | sed 's/, $//')
    else
        STATUS="Fail"
        VALUE="Tidak ditemukan konfigurasi SECURE_REGISTER_"
    fi
else
    STATUS="Fail"
    VALUE="File listener.ora tidak ditemukan di $LISTENER_ORA"
fi

# Simpan hasil audit
{
    echo "Judul Audit       : 2.1.4 Ensure 'SECURE_REGISTER_' Is Set to 'TCPS' or 'IPC'"
    echo "Status            : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS         : TCPS atau IPC"
    echo "Deskripsi         : SECURE_REGISTER_ memastikan listener hanya menerima pendaftaran melalui protokol aman seperti TCPS atau IPC."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
