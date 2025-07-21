OUTPUT_FILE="audit_results.txt"

# Ambil status Master_SSL_Allowed dari replika
MASTER_SSL_ALLOWED=$(mariadb -N -B -e "SHOW REPLICA STATUS\G" 2>/dev/null | grep -i "Master_SSL_Allowed" | awk '{print $2}')

if [[ "$MASTER_SSL_ALLOWED" == "Yes" ]]; then
    STATUS="PASS"
else
    STATUS="FAIL"
fi

DETAILS="Master_SSL_Allowed: ${MASTER_SSL_ALLOWED:-'Tidak ditemukan'}\n\
Pastikan replikasi menggunakan salah satu metode berikut untuk menjamin keamanan:\n\
- Private network\n- VPN\n- SSL/TLS\n- SSH Tunnel"

{
    echo "Judul Audit : 9.1 Ensure Replication Traffic is Secured"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :\n$DETAILS"
    echo ""
    echo "Nilai CIS : Replikasi harus menggunakan metode aman seperti private network, VPN, SSL/TLS, atau SSH Tunnel. Jika menggunakan SSL/TLS, pastikan Master_SSL_Allowed bernilai 'Yes'."
    echo "Deskripsi : Replikasi yang aman mencegah kebocoran password dan informasi sensitif dari lalu lintas replikasi antara server MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
