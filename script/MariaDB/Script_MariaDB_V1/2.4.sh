OUTPUT_FILE="audit_results.txt"

# Ambil daftar user MariaDB, kecuali user reserved
USER_LIST=$(mysql -N -B -e "
SELECT host, user, plugin,
       IF(plugin = 'mysql_native_password','WEAK SHA1','STRONG SHA2') AS HASHTYPE
FROM mysql.user
WHERE user NOT IN ('mysql.infoschema','mysql.session','mysql.sys')
  AND plugin NOT LIKE 'auth%'
  AND plugin <> 'mysql_no_login'
  AND LENGTH(authentication_string) > 0
ORDER BY plugin;
")

# Analisis user yang mungkin digunakan ulang
# (Jika satu username digunakan untuk lebih dari satu host, ini dianggap reuse)
REUSED_USERS=$(echo "$USER_LIST" | awk '{print $2}' | sort | uniq -d)

if [[ -n "$REUSED_USERS" ]]; then
    STATUS="Fail"
    VALUE="Potentially reused usernames detected: $REUSED_USERS"
else
    STATUS="Pass"
    VALUE="No reused usernames detected"
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.4 Do Not Reuse Usernames"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Username MariaDB harus unik per aplikasi, orang, atau sistem; tidak boleh digunakan ulang"
    echo "Deskripsi : Verifikasi bahwa setiap user MariaDB unik dan tidak digunakan oleh lebih dari satu aplikasi atau entitas, untuk mengurangi risiko kompromi berantai."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
