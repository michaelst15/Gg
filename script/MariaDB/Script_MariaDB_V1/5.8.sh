OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="Tidak ada user non-replika yang memiliki REPLICATION SLAVE privilege."

# Jalankan query untuk memeriksa user dengan REPLICATION SLAVE privilege
REPL_SLAVE_USERS=$(mariadb -N -B -e "
SELECT GRANTEE
FROM INFORMATION_SCHEMA.USER_PRIVILEGES
WHERE PRIVILEGE_TYPE = 'REPLICATION SLAVE';
" 2>/dev/null)

if [[ -n "$REPL_SLAVE_USERS" ]]; then
    STATUS="Fail"
    DETAILS="Ditemukan user dengan REPLICATION SLAVE privilege:\n$REPL_SLAVE_USERS"
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.8 Ensure 'REPLICATION SLAVE' is Not Granted to Non-Administrative Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : Hanya akun replika yang sah boleh memiliki REPLICATION SLAVE privilege."
    echo "Deskripsi : REPLICATION SLAVE memungkinkan pengguna mengambil binlog yang berisi semua perintah perubahan data. Hak ini harus dibatasi hanya untuk akun replikasi yang diperlukan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
