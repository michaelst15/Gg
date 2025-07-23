OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil lokasi log_bin_basename
LOG_BIN_BASE=$(mysql -u root -p'bangtob150420' -N -B -e "SELECT @@global.log_bin_basename;" 2>/dev/null)

# Tentukan PASS/FAIL
if [[ -z "$LOG_BIN_BASE" ]]; then
    STATUS="FAIL"
    DETAILS="log_bin_basename tidak dikonfigurasi atau kosong."
elif [[ "$LOG_BIN_BASE" == /* && ( "$LOG_BIN_BASE" == /var/* || "$LOG_BIN_BASE" == /usr/* || "$LOG_BIN_BASE" == /* ) ]]; then
    STATUS="FAIL"
    DETAILS="log_bin_basename disimpan di partisi sistem: $LOG_BIN_BASE"
else
    DETAILS="log_bin_basename disimpan di non-system partition: $LOG_BIN_BASE"
fi

{
    echo "Judul Audit : 6.2 Ensure Log Files are Stored on a Non-System Partition"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo "Nilai CIS : Pastikan log MariaDB tidak disimpan di partisi sistem (/ , /var , /usr)."
    echo "Deskripsi : Memindahkan log MariaDB dari partisi sistem mengurangi risiko denial of service akibat habisnya ruang disk pada sistem."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
