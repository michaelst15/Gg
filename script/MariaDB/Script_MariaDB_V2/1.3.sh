OUTPUT_FILE="audit_results.txt"

# Cari file .mysql_history di home dan root
HISTORY_FILES=$(find /home /root -name ".mysql_history" 2>/dev/null)

# Variabel status dan value default
STATUS="Pass"
VALUE="No .mysql_history files found or all properly disabled"

if [[ -n "$HISTORY_FILES" ]]; then
    FAIL_FILES=""
    for file in $HISTORY_FILES; do
        if [ ! -L "$file" ] || [[ "$(readlink -f "$file")" != "/dev/null" ]]; then
            FAIL_FILES+="$file "
        fi
    done

    if [[ -n "$FAIL_FILES" ]]; then
        STATUS="Fail"
        VALUE=".mysql_history files not linked to /dev/null: $FAIL_FILES"
    else
        VALUE="All .mysql_history files are properly disabled (linked to /dev/null)"
    fi
fi

# Tulis hasil ke file audit
{
    echo "Judul Audit : 1.3 Disable MariaDB Command History"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Semua file .mysql_history harus di-nonaktifkan dengan symbolic link ke /dev/null"
    echo "Deskripsi : Verifikasi bahwa MariaDB client dan shell command history telah dinonaktifkan untuk mencegah kebocoran data sensitif."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
