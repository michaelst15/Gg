OUTPUT_FILE="audit_results.txt"

# Jalankan query untuk mengambil nilai Master_SSL_Verify_Server_Cert
SSL_VERIFY=$(mariadb -N -B -e "SHOW REPLICA STATUS\G" 2>/dev/null | grep -i 'Master_SSL_Verify_Server_Cert' | awk '{print $2}')

if [ "$SSL_VERIFY" == "Yes" ]; then
    STATUS="PASS"
else
    STATUS="FAIL"
fi

{
    echo "Judul Audit : 9.2 Ensure 'MASTER_SSL_VERIFY_SERVER_CERT' is enabled"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "Master_SSL_Verify_Server_Cert: ${SSL_VERIFY:-Tidak ditemukan}"
    echo ""
    echo "Nilai CIS : Pastikan pada REPLICA MariaDB 'MASTER_SSL_VERIFY_SERVER_CERT' bernilai 'Yes' untuk memverifikasi sertifikat PRIMARY."
    echo "Deskripsi : REPLICA harus memverifikasi sertifikat PRIMARY saat menggunakan SSL/TLS untuk mencegah koneksi ke server yang tidak sah."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
