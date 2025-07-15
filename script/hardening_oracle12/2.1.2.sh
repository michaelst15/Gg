# Path ORACLE_HOME disesuaikan dengan lingkungan
ORACLE_HOME="/poracle/1120"
LISTENER_ORA="$ORACLE_HOME/network/admin/listener.ora"
OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa apakah 'extproc' digunakan dalam listener.ora..."

if [[ -f "$LISTENER_ORA" ]]; then
    # Cari semua entri yang mengandung extproc (case-insensitive)
    EXTPROC_FOUND=$(grep -i "extproc" "$LISTENER_ORA")

    if [[ -n "$EXTPROC_FOUND" ]]; then
        STATUS="Fail"
        VALUE=$(echo "$EXTPROC_FOUND" | sed 's/^/  /')
    else
        STATUS="Pass"
        VALUE="extproc tidak ditemukan dalam listener.ora"
    fi
else
    STATUS="Fail"
    VALUE="File listener.ora tidak ditemukan di path: $LISTENER_ORA"
fi

# Tulis hasil audit ke file
{
    echo "Judul Audit         : 2.1.2 Ensure 'extproc' Is Not Present in 'listener.ora'"
    echo "Status              : $STATUS"
    echo "Nilai Konfigurasi   : $VALUE"
    echo "Nilai CIS           : Remove extproc from listener.ora"
    echo "Deskripsi           : 'extproc' memungkinkan database menjalankan prosedur dari OS libraries, yang berisiko dieksploitasi untuk mengeksekusi perintah OS. Untuk mengurangi risiko, pastikan 'extproc' tidak dikonfigurasi dalam listener.ora."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
