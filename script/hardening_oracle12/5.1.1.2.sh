OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.1.1.2 - Memeriksa akses 'EXECUTE' oleh PUBLIC pada DBMS_LOB..." | tee -a "$OUTPUT_FILE"
 
# SQL Audit Query khusus DBMS_LOB
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT TABLE_NAME FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME = 'DBMS_LOB';
EXIT;
EOF
)
 
# Eksekusi dan ambil hasil
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="PUBLIC tidak memiliki akses EXECUTE pada DBMS_LOB"
else
  STATUS="Fail"
  VALUE="PUBLIC memiliki akses EXECUTE pada DBMS_LOB"
fi
 
# Simpan hasil audit ke file
{
echo "Judul Audit : 5.1.1.2 Ensure 'EXECUTE' is revoked from 'PUBLIC' on DBMS_LOB"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : EXECUTE ON DBMS_LOB to PUBLIC"
  echo "Deskripsi : DBMS_LOB memungkinkan manipulasi LOB termasuk BLOB, CLOB, NCLOB, dan BFILE. Jika PUBLIC memiliki akses EXECUTE ke paket ini, maka bisa digunakan untuk membaca/menulis data sensitif atau menyalahgunakan ruang disk."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"