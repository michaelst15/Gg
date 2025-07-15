OUTPUT_FILE="audit_results.txt"
 
echo "🔍 Memeriksa role 'EXECUTE_CATALOG_ROLE' untuk grantee tidak sah..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SELECT GRANTEE FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE = 'EXECUTE_CATALOG_ROLE'
AND GRANTEE NOT IN (
  SELECT USERNAME FROM DBA_USERS WHERE ORACLE_MAINTAINED = 'Y'
)
AND GRANTEE NOT IN (
  SELECT ROLE FROM DBA_ROLES WHERE ORACLE_MAINTAINED = 'Y'
);
EXIT;
EOF
)
 
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Ganti ini jika Anda memiliki grantee resmi yang diperbolehkan
AUTHORIZED_GRANTEE=""
 
# Cek apakah output mengandung error ORA
if echo "$RESULT" | grep -q "ORA-"; then
  STATUS="Fail"
  VALUE="Gagal menjalankan query: $RESULT"
elif [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="Tidak ditemukan GRANTEE tidak sah dengan role EXECUTE_CATALOG_ROLE"
elif [[ "$RESULT" == "$AUTHORIZED_GRANTEE" ]]; then
  STATUS="Pass"
  VALUE="EXECUTE_CATALOG_ROLE hanya diberikan kepada grantee yang sah: $AUTHORIZED_GRANTEE"
else
  STATUS="Fail"
  VALUE="Ditemukan GRANTEE tidak sah dengan role EXECUTE_CATALOG_ROLE: $RESULT"
fi
 
{
  echo "Judul Audit : 5.3.3 Ensure 'EXECUTE_CATALOG_ROLE' Is Revoked from Unauthorized 'GRANTEE'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (Role hanya boleh diberikan kepada user yang secara resmi disetujui)"
  echo "Deskripsi : Role EXECUTE_CATALOG_ROLE memberikan hak akses untuk mengeksekusi package dan procedure dalam schema SYS. Jika diberikan ke user tidak sah, maka berpotensi disalahgunakan untuk mengganggu sistem atau mengeksekusi prosedur tidak sah."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
 
