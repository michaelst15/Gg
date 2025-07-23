OUTPUT_FILE="audit_results.txt"

# Jalankan MariaDB untuk ambil lokasi datadir dan file lain
DB_PATHS=$(mysql -u root -p'bangtob150420' -N -B -e "
SELECT VARIABLE_NAME, VARIABLE_VALUE
FROM information_schema.global_variables
WHERE (VARIABLE_NAME LIKE '%dir' OR VARIABLE_NAME LIKE '%file')
AND (VARIABLE_NAME NOT LIKE '%core%'
     AND VARIABLE_NAME <> 'local_infile'
     AND VARIABLE_NAME <> 'relay_log_info_file')
ORDER BY VARIABLE_NAME;
")

# Bersihkan hasil: hanya ambil path yang unik
PATH_LIST=$(echo "$DB_PATHS" | awk '{print $2}' | sort -u)

# Cek apakah ada path yang berada di root (/), /var, atau /usr
FAIL_PATHS=""
for path in $PATH_LIST; do
    if [ -d "$path" ]; then
        MOUNT_POINT=$(df -P "$path" | tail -1 | awk '{print $6}')
        if [[ "$MOUNT_POINT" == "/" || "$MOUNT_POINT" == "/var" || "$MOUNT_POINT" == "/usr" ]]; then
            FAIL_PATHS+="$path mounted on $MOUNT_POINT; "
        fi
    fi
done

# Evaluasi status
if [ -n "$FAIL_PATHS" ]; then
    STATUS="Fail"
    VALUE="
Database directories on system partitions: 
$FAIL_PATHS"
else
    STATUS="Pass"
    VALUE="All database directories are on non-system partitions"
fi

# Tulis hasil ke file audit
{
    echo "Judul Audit : 1.1 Place Databases on Non-System Partitions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Database files should not be on /, /var, or /usr partitions"
    echo "Deskripsi : Verifikasi bahwa file MariaDB ditempatkan di partisi non-sistem"
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
