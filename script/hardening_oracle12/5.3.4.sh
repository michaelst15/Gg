OUTPUT_FILE="audit_results.txt"
SQL_FILE="check_dba_role.sql"
TMP_RESULT_FILE="/tmp/check_dba_role_$$.tmp"
 
# Ganti dengan nama PDB jika Anda menggunakan multitenant setup
PDB_NAME="ORCLPDB"  # Ganti sesuai nama PDB Anda
USE_PDB=1           # Set ke 0 jika tidak perlu ALTER SESSION
 
echo "🔍 Memeriksa role 'DBA' diberikan kepada user tidak sah..." | tee -a "$OUTPUT_FILE"
 
# Buat file SQL sementara
cat > "$SQL_FILE" <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET PAGESIZE 0
SET LINESIZE 1000
WHENEVER SQLERROR EXIT SQL.SQLCODE
 
-- Jika pakai multitenant, pindah ke PDB
EOF
 
if [ "$USE_PDB" -eq 1 ]; then
  echo "ALTER SESSION SET CONTAINER=$PDB_NAME;" >> "$SQL_FILE"
fi
 
cat >> "$SQL_FILE" <<EOF
 
SELECT 'GRANT:' || GRANTEE FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE = 'DBA'
UNION
SELECT 'PROXY:' || PROXY || '-' || CLIENT FROM DBA_PROXIES
WHERE CLIENT IN (
  SELECT GRANTEE FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE = 'DBA'
);
 
EXIT;
EOF
 
# Jalankan query SQL dan simpan hasilnya
RAW_RESULT=$(sqlplus -s / as sysdba @"$SQL_FILE")
rm -f "$SQL_FILE"
 
# Tangani error ORA- saat database tidak open
echo "$RAW_RESULT" | grep -q "ORA-" && {
  echo "❌ Gagal menjalankan query. Pastikan database/PDB sudah OPEN dan nama PDB benar." | tee -a "$OUTPUT_FILE"
  exit 1
}
 
# Bersihkan hasil
echo "$RAW_RESULT" | tr -d '\r' | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' > "$TMP_RESULT_FILE"
 
# Daftar user sah
AUTHORIZED_USERS="ORACLE ORACLEP"
STATUS="Pass"
VIOLATIONS=""
 
# Loop data hasil
while IFS= read -r line; do
    case "$line" in
        *:*) ;;
        *) continue ;;
    esac
 
    GRANTEE=$(echo "$line" | cut -d':' -f2 | cut -d'-' -f1 | tr '[:lower:]' '[:upper:]' | xargs)
 
    AUTHORIZED=0
    for AUTH in $AUTHORIZED_USERS; do
        if [ "$GRANTEE" = "$AUTH" ]; then
            AUTHORIZED=1
            break
        fi
    done
 
    if [ "$AUTHORIZED" -ne 1 ]; then
        STATUS="Fail"
        VIOLATIONS="${VIOLATIONS}${line}\n"
    fi
done < "$TMP_RESULT_FILE"
 
rm -f "$TMP_RESULT_FILE"
 
# Buat ringkasan
if [ "$STATUS" = "Pass" ]; then
    VALUE="Tidak ditemukan GRANTEE tidak sah dengan role DBA"
else
    VALUE="Ditemukan GRANTEE tidak sah dengan role DBA:\n$VIOLATIONS"
fi
 
# Tulis hasil ke file audit
{
    echo "Judul Audit : 5.3.4 Ensure 'DBA' Is Revoked from Unauthorized 'GRANTEE'"
    echo "Status : $STATUS"
    printf "Nilai Konfigurasi : $VALUE\n"
    echo "Nilai CIS : 1 (Role DBA hanya boleh diberikan kepada user Oracle internal seperti ORACLE/ORACLEP)"
    echo "Deskripsi : Role DBA memberikan akses administratif penuh. Jika diberikan ke user yang tidak sah, dapat menyebabkan pelanggaran keamanan, integritas, atau gangguan layanan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
 

