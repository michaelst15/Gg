OUTPUT_FILE="audit_results.txt"
STATUS="Pass"
DETAILS="
Tidak ada user dengan hak DML/DDL yang tidak sesuai ditemukan.
$DML_DDL_USERS
"

# Jalankan query untuk mencari user yang memiliki DML/DDL privilege
DML_DDL_USERS=$(mysql -N -B -e "
SELECT User, Host, Db
FROM mysql.db
WHERE Select_priv='Y'
 OR Insert_priv='Y'
 OR Update_priv='Y'
 OR Delete_priv='Y'
 OR Create_priv='Y'
 OR Drop_priv='Y'
 OR Alter_priv='Y';
" 2>/dev/null)

if [[ -n "$DML_DDL_USERS" ]]; then
    STATUS="Fail"
    DETAILS="
Ditemukan user dengan DML/DDL privilege:
$DML_DDL_USERS
Pastikan user tersebut hanya memiliki akses pada database yang diperbolehkan."
fi

# Simpan hasil audit
{
    echo "Judul Audit : 5.9 Ensure DML/DDL Grants are Limited to Specific Databases and Users"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : "
    echo "$DETAILS"
    echo "Nilai CIS : Hanya user yang memerlukan hak DML/DDL yang boleh memiliki privilege INSERT, SELECT, UPDATE, DELETE, DROP, CREATE, ALTER pada database yang sesuai."
    echo "Deskripsi : Membatasi hak akses DML/DDL pada user tertentu dan database yang spesifik akan mengurangi permukaan serangan pada MariaDB."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
