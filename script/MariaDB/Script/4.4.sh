OUTPUT_FILE="audit_results.txt"

STATUS="Pass"
DETAILS=""

# Cek versi MariaDB client
CLIENT_VERSION=$(mariadb --version 2>/dev/null | awk '{print $5}' | cut -d'-' -f1)

# Konversi versi ke format numerik untuk perbandingan
VERSION_OK=1
if [[ -n "$CLIENT_VERSION" ]]; then
    # Hilangkan titik untuk perbandingan sederhana (10.2.0 menjadi 1002000)
    VERSION_NUM=$(echo "$CLIENT_VERSION" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }')
    REQUIRED_VERSION_NUM=$(echo "10.2.0" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }')

    if (( VERSION_NUM < REQUIRED_VERSION_NUM )); then
        VERSION_OK=0
    fi
else
    VERSION_OK=0
fi

# Jika versi kurang dari 10.2.0, cek nilai local_infile
if [[ $VERSION_OK -eq 0 ]]; then
    LOCAL_INFILE=$(mariadb -N -B -e "SHOW VARIABLES WHERE Variable_name = 'local_infile';" 2>/dev/null | awk '{print $2}')
    if [[ "$LOCAL_INFILE" != "0" ]]; then
        STATUS="Fail"
        DETAILS="MariaDB client versi $CLIENT_VERSION < 10.2.0, dan local_infile diaktifkan ($LOCAL_INFILE)."
    else
        DETAILS="MariaDB client versi $CLIENT_VERSION < 10.2.0, tetapi local_infile dimatikan (0)."
    fi
else
    DETAILS="MariaDB client versi $CLIENT_VERSION ≥ 10.2.0, local_infile aman untuk digunakan."
fi

# Simpan hasil audit
{
    echo "Judul Audit : 4.4 Harden Usage for 'local_infile' on MariaDB Clients"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : MariaDB client harus versi >= 10.2.0, atau jika < 10.2.0 maka 'local_infile' harus dimatikan (0)."
    echo "Deskripsi : Mengurangi risiko SQL injection yang bisa membaca file sensitif dari server."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
