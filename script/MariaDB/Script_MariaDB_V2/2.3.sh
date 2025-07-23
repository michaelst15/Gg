OUTPUT_FILE="audit_results.txt"

# Cek proses yang mungkin menjalankan MariaDB/MySQL dengan password di command line
PROCESS_CHECK=$(ps aux | grep -E "mariadb|mysql" | grep -E -- "-p[^ ]+" | grep -v grep)

# Cek history command semua user
HISTORY_CHECK=""
for histfile in /home/*/.bash_history /root/.bash_history; do
    if [[ -f "$histfile" ]]; then
        FOUND=$(grep -E "mariadb .* -p[^ ]+|mysql .* -p[^ ]+" "$histfile")
        if [[ -n "$FOUND" ]]; then
            HISTORY_CHECK+="$histfile "
        fi
    fi
done

# Evaluasi hasil
if [[ -n "$PROCESS_CHECK" || -n "$HISTORY_CHECK" ]]; then
    STATUS="Fail"
    VALUE="Passwords found in: "
    [[ -n "$PROCESS_CHECK" ]] && VALUE+="process list; "
    [[ -n "$HISTORY_CHECK" ]] && VALUE+="command history ($HISTORY_CHECK);"
else
    STATUS="Pass"
    VALUE="No passwords visible in process list or command history"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.3 Do Not Specify Passwords in the Command Line"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Password MariaDB tidak boleh muncul di command line atau history shell"
    echo "Deskripsi : Verifikasi bahwa password MariaDB tidak terlihat di daftar proses yang berjalan atau di riwayat perintah shell pengguna."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
