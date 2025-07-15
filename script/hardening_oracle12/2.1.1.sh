ORACLE_HOME="/poracle/1120"
LISTENER_ORA="$ORACLE_HOME/network/admin/listener.ora"
OUTPUT_FILE="audit_results.txt"

echo "🔍 Memeriksa konfigurasi SECURE_CONTROL_ di listener.ora..."

if [ -f "$LISTENER_ORA" ]; then
    LISTENERS=$(grep '^[[:space:]]*[A-Za-z0-9_]\+[[:space:]]*=' "$LISTENER_ORA" | grep -v '^ *SECURE_CONTROL_' | cut -d '=' -f1 | tr -d ' ' | sort -u)

    MISSING_LISTENERS=""
    CONFIGURED_DIRECTIVES=""

    for LISTENER in $LISTENERS; do
        if grep -q "SECURE_CONTROL_${LISTENER}" "$LISTENER_ORA"; then
            MATCHED_LINE=$(grep "SECURE_CONTROL_${LISTENER}" "$LISTENER_ORA" | tr -d '\n')
            CONFIGURED_DIRECTIVES="${CONFIGURED_DIRECTIVES}${MATCHED_LINE}, "
        else
            MISSING_LISTENERS="${MISSING_LISTENERS}${LISTENER} "
        fi
    done

    if [ -z "$MISSING_LISTENERS" ]; then
        STATUS="Pass"
        VALUE="$CONFIGURED_DIRECTIVES"
    else
        STATUS="Fail"
        VALUE="Missing SECURE_CONTROL_ for listener(s): $MISSING_LISTENERS"
    fi
else
    STATUS="Fail"
    VALUE="listener.ora not found at $LISTENER_ORA"
fi

{
  echo "Judul Audit : 2.1.1 Ensure 'SECURE_CONTROL_' Is Set In 'listener.ora'"
  echo "Status : $STATUS"
  echo "Nilai Konfigurasi : $VALUE"
  echo "Nilai CIS : 1 (Enabled)"
  echo "Deskripsi : Direktif 'SECURE_CONTROL_<listener_name>' harus disetel untuk setiap listener guna mencegah konfigurasi jarak jauh yang tidak terenkripsi."
  echo "-------------------------------------------------------------"
  echo ""
} >> "$OUTPUT_FILE"
