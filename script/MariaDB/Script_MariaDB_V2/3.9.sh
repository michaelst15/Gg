OUTPUT_FILE="audit_results.txt"

# Ambil nilai server_audit_file_path dari MariaDB
AUDIT_FILE=$(mysql -u root -p'bangtob150420' -N -B -e "SHOW GLOBAL VARIABLES WHERE Variable_name='server_audit_file_path';" | awk '{print $2}')

STATUS="Pass"
DETAILS=""

if [[ -z "$AUDIT_FILE" ]]; then
    STATUS="Fail"
    DETAILS="server_audit_file_path tidak dikonfigurasi atau auditing tidak diaktifkan."
else
    # Jika hanya nama file diberikan, gunakan datadir sebagai path
    if [[ "$AUDIT_FILE" != /* ]]; then
        DATADIR=$(mysql -N -B -e "SHOW VARIABLES WHERE Variable_name='datadir';" | awk '{print $2}')
        AUDIT_FILE="
${DATADIR}${AUDIT_FILE}"
    fi

    if [[ -f "$AUDIT_FILE" ]]; then
        COMPLIANT=$(ls -l "$AUDIT_FILE" 2>/dev/null | egrep "^-([rw-]{2}-){2}---[[:space:]]*[0-9]+[[:space:]]*mysql[[:space:]]*mysql.*$")
        if [[ -z "$COMPLIANT" ]]; then
            STATUS="Fail"
            DETAILS="File audit $AUDIT_FILE tidak memiliki permission atau kepemilikan yang sesuai."
        else
            DETAILS="File audit $AUDIT_FILE memiliki permission sesuai (hanya mysql yang dapat membaca/menulis)."
        fi
    else
        STATUS="Fail"
        DETAILS="File audit $AUDIT_FILE tidak ditemukan di sistem."
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 3.9 Ensure 'server_audit_file_path' Has Appropriate Permissions"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $DETAILS"
    echo "Nilai CIS : File audit MariaDB harus dimiliki oleh user dan group 'mysql', dengan permission ketat (-rw-------)."
    echo "Deskripsi : Memastikan file audit MariaDB tidak dapat diakses oleh user yang tidak berwenang untuk menjaga kerahasiaan dan integritas log."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
