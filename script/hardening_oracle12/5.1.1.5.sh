OUTPUT_FILE="audit_results.txt"
 
echo "🔍 CIS 5.1.1.5 - Memeriksa akses 'EXECUTE' oleh PUBLIC pada paket Job Scheduler (DBMS_SCHEDULER, DBMS_JOB)..." | tee -a "$OUTPUT_FILE"
 
# SQL query
QUERY=$(cat <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT TABLE_NAME FROM DBA_TAB_PRIVS
WHERE GRANTEE='PUBLIC'
AND PRIVILEGE='EXECUTE'
AND TABLE_NAME IN ('DBMS_SCHEDULER','DBMS_JOB');
EXIT;
EOF
)
 
# Jalankan query
RESULT=$(echo "$QUERY" | sqlplus -s / as sysdba | sed '/^$/d')
 
# Evaluasi hasil
if [[ -z "$RESULT" ]]; then
  STATUS="Pass"
  VALUE="PUBLIC tidak memiliki akses EXECUTE pada paket Job Scheduler"
else
  STATUS="Fail"
  VALUE="PUBLIC memiliki akses EXECUTE pada: $RESULT"
fi
 
# Simpan hasil audit
{
echo "Judul Audit : 5.1.1.5 Ensure 'EXECUTE' is revoked from 'PUBLIC' on Job Scheduler Packages"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : EXECUTE ON DBMS_SCHEDULER / DBMS_JOB to PUBLIC"
  echo "Deskripsi : Paket DBMS_SCHEDULER dan DBMS_JOB menyediakan kemampuan untuk menjadwalkan tugas pada database dan sistem OS. Grant ke PUBLIC berisiko digunakan oleh pihak tidak sah untuk menjadwalkan dan menjalankan proses berbahaya atau membanjiri antrian pekerjaan."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"