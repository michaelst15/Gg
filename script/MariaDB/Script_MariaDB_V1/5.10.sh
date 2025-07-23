OUTPUT_FILE="audit_results.txt"
STATUS="PASS"

# Ambil daftar stored procedures dan functions
PROCEDURES=$(mariadb -N -B -e "SHOW PROCEDURE STATUS;" 2>/dev/null)
FUNCTIONS=$(mariadb -N -B -e "SHOW FUNCTION STATUS;" 2>/dev/null)

# Cek DEFINER berisiko
RISKY_DEFINERS=$(mariadb -N -B -e "SELECT ROUTINE_SCHEMA, ROUTINE_NAME, DEFINER, SECURITY_TYPE 
FROM information_schema.ROUTINES
WHERE DEFINER LIKE 'root@%' OR DEFINER LIKE '%@%';" 2>/dev/null)

# Cek SECURITY_TYPE DEFINER
SECURITY_DEFINER=$(mariadb -N -B -e "SELECT ROUTINE_SCHEMA, ROUTINE_NAME, DEFINER, SECURITY_TYPE
FROM information_schema.ROUTINES
WHERE SECURITY_TYPE='DEFINER';" 2>/dev/null)

# Tentukan PASS/FAIL
if [[ -n "$RISKY_DEFINERS" || -n "$SECURITY_DEFINER" ]]; then
    STATUS="FAIL"
    DETAILS="Ditemukan DEFINER atau SECURITY_TYPE berisiko:\n$RISKY_DEFINERS\n$SECURITY_DEFINER"
else
    DETAILS="Tidak ditemukan DEFINER atau SECURITY_TYPE berisiko."
fi

{
    echo "Judul Audit : 5.10 Securely Define Stored Procedures and Functions DEFINER and INVOKER"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi :"
    echo "$DETAILS"
    echo ""
    echo "Daftar Stored Procedures:"
    echo "$PROCEDURES"
    echo ""
    echo "Daftar Stored Functions:"
    echo "$FUNCTIONS"
    echo ""
    echo "Nilai CIS : Pastikan stored procedures dan functions tidak menggunakan DEFINER dengan hak istimewa berlebih, dan INVOKER sesuai kebutuhan."
    echo "Deskripsi : DEFINER dan INVOKER harus diperiksa untuk mencegah eskalasi hak istimewa yang tidak disengaja."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
