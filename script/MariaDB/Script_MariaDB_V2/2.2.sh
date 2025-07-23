#!/bin/bash

OUTPUT_FILE="audit_results.txt"

# Daftar layanan yang umum untuk MariaDB dan OS
ALLOWED_SERVICES=("mariadb" "mysql" "sshd" "systemd" "rsyslog" "cron" "network" "auditd")

# Ambil semua layanan aktif
ACTIVE_SERVICES=$(systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}' | sed 's/.service//g')

UNRELATED_SERVICES=""

for svc in $ACTIVE_SERVICES; do
    if [[ ! " ${ALLOWED_SERVICES[@]} " =~ " $svc " ]]; then
        UNRELATED_SERVICES+="$svc "
    fi
done

# Evaluasi hasil
if [[ -n "$UNRELATED_SERVICES" ]]; then
    STATUS="Fail"
    VALUE="
Unrelated services running: 
$UNRELATED_SERVICES"
else
    STATUS="Pass"
    VALUE="No unrelated services detected. Machine dedicated to MariaDB."
fi

# Tulis hasil audit
{
    echo "Judul Audit : 2.2 Dedicate the Machine Running MariaDB"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : Server MariaDB harus berjalan di mesin yang didedikasikan, tanpa layanan atau aplikasi lain yang tidak perlu"
    echo "Deskripsi : Verifikasi bahwa mesin ini hanya menjalankan OS, MariaDB, dan layanan operasional minimum, mengurangi permukaan serangan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
