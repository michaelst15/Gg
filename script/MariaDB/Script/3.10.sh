OUTPUT_FILE="audit_results.txt"
CONFIG_FILE="/etc/mysql/mariadb.cnf"

STATUS="Pass"
DETAILS=""

# Ambil nilai file_key_management_filename
FILENAME=$(grep -Po '(?<=file_key_management_filename=).+$' "$CONFIG_FILE" 2>/dev/null)
# Ambil nilai file_key_management_filekey
FILEKEY=$(grep -Po '(?<=file_key_management_filekey=).+$' "$CONFIG_FILE" 2>/dev/null)

if [[ -z "$FILENAME" && -z "$FILEKEY" ]]; then
    STATUS="Fail"
    DETAILS="Plugin File Key Management Encryption tidak dikonfigurasi atau file tidak ditemukan."
else
    for FILE in "$FILENAME" "$FILEKEY"; do
        if [[ -n "$FILE" ]]; then
            if [[ -f "$FILE" ]]; then
                PERM=$(stat -c "%a" "$FILE")
                OWNER=$(stat -c "%U" "$FILE")
                GROUP=$(stat -c "%G" "$FILE")
                if [[ "$PERM" -le 750 && "$OWNER" == "mysql" && "$GROUP" == "mysql" ]]; then
                    DETAILS="$DETAILS\nFile $FILE memiliki permission dan kepemilikan sesuai."
                else
                    STATUS="Fail"
                    DETAILS="$DETAILS\nFile $FILE memiliki permission/kepemilikan yang salah (harus 750 atau lebih ketat, mysql:mysql)."
                fi
            else
                STATUS="Fail"
                DETAILS="$DETAILS\nFile $FILE tidak ditemukan."
            fi
        fi
    done
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.10 Ensure File Key Management Encryption Plugin files have appropriate permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : File plugin harus dimiliki oleh user dan group 'mysql' dengan permission 750 atau lebih ketat."
    echo "Deskripsi : Memastikan file plugin penyimpanan kunci terenkripsi tidak dapat diakses oleh user yang tidak berwenang untuk menjaga keamanan data."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
