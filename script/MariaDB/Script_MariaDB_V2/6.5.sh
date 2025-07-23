OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil nilai LOAD_OPTION untuk plugin SERVER_AUDIT
LOAD_OPTION=$(mysql -u root -p'bangtob150420' -N -B -e "SELECT LOAD_OPTION FROM information_schema.plugins WHERE PLUGIN_NAME='SERVER_AUDIT';" 2>/dev/null)

# Tentukan PASS/FAIL
if [[ -z "$LOAD_OPTION" ]]; then
    STATUS="FAIL"
    DETAILS="Plugin SERVER_AUDIT tidak ditemukan atau tidak aktif."
elif [[ "$LOAD_OPTION" != "FORCE_PLUS_PERMANENT" ]]; then
    STATUS="FAIL"
    DETAILS="Plugin SERVER_AUDIT ditemukan tetapi LOAD_OPTION = $LOAD_OPTION (seharusnya FORCE_PLUS_PERMANENT)."
else
    DETAILS="Plugin SERVER_AUDIT memiliki LOAD_OPTION = FORCE_PLUS_PERMANENT, tidak bisa di-unload."
fi

{
    echo "Judul Audit : 6.5 Ensure the Audit Plugin Can't be Unloaded"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo "Nilai CIS : server_audit harus diset ke FORCE_PLUS_PERMANENT agar plugin audit tidak bisa di-unload."
    echo "Deskripsi : Mencegah unloading plugin audit untuk memastikan semua aktivitas database tercatat di audit log."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
