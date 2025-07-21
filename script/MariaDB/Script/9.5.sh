OUTPUT_FILE="audit_results.txt"

# Ambil informasi dari REPLICA
MASTER_SSL_CERT=$(mariadb -N -B -e "SHOW REPLICA STATUS\G" 2>/dev/null | grep -i 'Master_SSL_Cert:' | awk '{print $2}')
MASTER_SSL_KEY=$(mariadb -N -B -e "SHOW REPLICA STATUS\G" 2>/dev/null | grep -i 'Master_SSL_Key:' | awk '{print $2}')

# Cek ssl_type untuk user replika di PRIMARY
# Ganti 'repl' dengan nama user replikasi yang sebenarnya
SSL_TYPE=$(mariadb -N -B -e "SELECT ssl_type FROM mysql.user WHERE user='repl';" 2>/dev/null)

# Tentukan PASS atau FAIL
if [ -n "$MASTER_SSL_CERT" ] && [ -n "$MASTER_SSL_KEY" ] && [ "$SSL_TYPE" = "X509" ]; then
    STATUS="PASS"
    DETAILS="Mutual TLS aktif. Replica menggunakan sertifikat: $MASTER_SSL_CERT dan private key: $MASTER_SSL_KEY. ssl_type untuk user replika: $SSL_TYPE"
else
    STATUS="FAIL"
    DETAILS="Mutual TLS tidak dikonfigurasi dengan benar. Pastikan Replica memiliki sertifikat dan private key serta ssl_type user replikasi diset X509."
fi

{
    echo "Judul Audit : 9.5 Ensure mutual TLS is enabled"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "Master_SSL_Cert: $MASTER_SSL_CERT"
    echo "Master_SSL_Key: $MASTER_SSL_KEY"
    echo "ssl_type untuk user replika: $SSL_TYPE"
    echo "$DETAILS"
    echo "Nilai CIS : Replica harus menyediakan sertifikat klien dan PRIMARY harus memverifikasi sertifikat untuk user replikasi (ssl_type = X509)."
    echo "Deskripsi : Mutual TLS memastikan replikasi aman dengan autentikasi dua arah antara PRIMARY dan REPLICA."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
