OUTPUT_FILE="audit_results.txt"

# Lokasi default direktori sertifikat MariaDB (ubah sesuai environment Anda)
SSL_DIR="/etc/mysql/ssl"
SERVER_CERT="$SSL_DIR/server-cert.pem"

if [[ ! -f "$SERVER_CERT" ]]; then
    STATUS="Fail"
    VALUE="Server certificate not found in $SERVER_CERT"
else
    SUBJECT=$(openssl x509 -in "$SERVER_CERT" -subject -noout 2>/dev/null | grep "Auto_Generated_Server_Certificate")
    if [[ -n "$SUBJECT" ]]; then
        STATUS="Fail"
        VALUE="Default auto-generated MariaDB server certificate detected"
    else
        STATUS="Pass"
        VALUE="Custom and unique MariaDB server certificate in use"
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.5 Ensure Non-Default, Unique Cryptographic Material is in Use"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : MariaDB harus menggunakan material kriptografi yang unik dan tidak default"
    echo "Deskripsi : Verifikasi bahwa MariaDB menggunakan sertifikat dan kunci enkripsi unik, bukan auto-generated atau digunakan bersama di instance lain."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
