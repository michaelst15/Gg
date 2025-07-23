OUTPUT_FILE="audit_results.txt"
REPL_USER="repl"  # Ganti dengan nama user replika Anda

# Cek apakah ada user replika dengan Super_priv = 'Y'
SUPER_PRIV_CHECK=$(mariadb -N -B -e "SELECT user, host FROM mysql.user WHERE user='$REPL_USER' AND Super_priv='Y';" 2>/dev/null)

if [ -z "$SUPER_PRIV_CHECK" ]; then
    STATUS="PASS"
else
    STATUS="FAIL"
fi

{
    echo "Judul Audit : 9.3 Ensure 'super_priv' is Not Set to 'Y' for Replication Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "User yang diperiksa: $REPL_USER"
    echo "Hasil pengecekan Super_priv:"
    echo "${SUPER_PRIV_CHECK:-Tidak ada user dengan Super_priv = 'Y'}"
    echo ""
    echo "Nilai CIS : Tidak boleh ada akun replika dengan 'Super_priv' diset ke 'Y'."
    echo "Deskripsi : Membatasi hak SUPER pada user replikasi mengurangi risiko eskalasi hak istimewa dan modifikasi konfigurasi database yang tidak diinginkan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
