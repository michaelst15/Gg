OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.1.2.1 - Memeriksa akses 'EXECUTE' oleh PUBLIC pada paket Non-default..." | tee -a "$OUTPUT_FILE"
 
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT TABLE_NAME FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME IN (
  'DBMS_BACKUP_RESTORE','DBMS_FILE_TRANSFER','DBMS_SYS_SQL','DBMS_AQADM_SYSCALLS',
  'DBMS_REPCAT_SQL_UTL','INITJVMAUX','DBMS_STREAMS_ADM_UTL','DBMS_AQADM_SYS',
  'DBMS_STREAMS_RPC','DBMS_PRVTAQIM','LTADM','WWV_DBMS_SQL',
  'WWV_EXECUTE_IMMEDIATE','DBMS_IJOB','DBMS_PDB_EXEC_SQL'
);
EXIT;
EOF
)
 
# Jalankan query
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="PUBLIC tidak memiliki akses EXECUTE pada paket non-default"
else
  STATUS="Fail"
  VALUE="PUBLIC memiliki akses EXECUTE pada: $RESULT"
fi
 
# Simpan hasil audit
{
echo "Judul Audit : 5.1.2.1 Ensure 'EXECUTE' is not granted to 'PUBLIC' on Non-default Packages"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : EXECUTE on non-default packages to PUBLIC"
  echo "Deskripsi : Paket-paket non-default ini memberikan kemampuan administratif atau akses sistem, yang seharusnya tidak dapat diakses oleh PUBLIC karena dapat disalahgunakan untuk menjalankan perintah sensitif atau OS-level."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"