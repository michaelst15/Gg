OUTPUT_FILE="audit_results.txt"

# Ambil nilai cipher yang digunakan untuk replikasi
CIPHER=$(mariadb -N -B -e "SHOW REPLICA STATUS\G" 2>/dev/null | grep -i 'Master_SSL_Cipher:' | awk '{print $2}')

# Tentukan PASS atau FAIL
if [ -n "$CIPHER" ]; then
    STATUS="PASS"
    DETAILS="Replication traffic uses TLS with cipher: $CIPHER"
else
    STATUS="FAIL"
    DETAILS="Replication traffic is not using TLS or cipher is not set."
fi

{
    echo "Judul Audit : 9.4 Ensure only approved ciphers are used for Replication"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "Master_SSL_Cipher: $CIPHER"
    echo "$DETAILS"
    echo "Nilai CIS : Master_SSL_Cipher harus diatur dan tidak kosong untuk memastikan replikasi terenkripsi dengan TLS."
    echo "Deskripsi : Memastikan replikasi menggunakan cipher TLS yang disetujui untuk melindungi data dalam perjalanan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
