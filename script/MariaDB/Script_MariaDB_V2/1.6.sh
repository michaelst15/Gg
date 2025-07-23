OUTPUT_FILE="audit_results.txt"

# Cari MYSQL_PWD di file profile dan bashrc semua user
PROFILE_CHECK=$(grep -Hn "MYSQL_PWD" /home/*/.{bashrc,profile,bash_profile} 2>/dev/null)

# Evaluasi hasil
if [[ -n "$PROFILE_CHECK" ]]; then
    STATUS="Fail"
    VALUE="MYSQL_PWD found in users' profiles: $(echo "$PROFILE_CHECK" | awk -F: '{print $1}' | sort -u | tr '\n' ' ')"
else
    STATUS="Pass"
    VALUE="
No MYSQL_PWD found in any user profile or bashrc files
$PROFILE_CHECK
"
fi

# Tulis hasil ke file audit
{
    echo "Judul Audit : 1.6 Verify That 'MYSQL_PWD' is Not Set in Users' Profiles"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Tidak boleh ada MYSQL_PWD di login scripts (.bashrc, .profile, .bash_profile) user"
    echo "Deskripsi : Verifikasi bahwa variabel MYSQL_PWD tidak disetel di profile user untuk menjaga kerahasiaan kredensial MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
