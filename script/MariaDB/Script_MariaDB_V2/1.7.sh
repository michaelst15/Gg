OUTPUT_FILE="audit_results.txt"

STATUS="Fail"
VALUE="MariaDB is not running in a sandbox environment"

# 1. Cek apakah chroot diaktifkan di konfigurasi MariaDB
CHROOT_PATH=$(grep -E '^[[:space:]]*chroot[[:space:]]*=' /etc/mysql/* 2>/dev/null | awk -F= '{print $2}' | xargs)

if [[ -n "$CHROOT_PATH" && -d "$CHROOT_PATH" ]]; then
    STATUS="Pass"
    VALUE="MariaDB is running with chroot at $CHROOT_PATH"
else
    # 2. Cek apakah MariaDB dijalankan di bawah systemd dengan user non-root
    SYSTEMD_STATUS=$(systemctl show -p MainPID --value mariadb.service 2>/dev/null)
    if [[ -n "$SYSTEMD_STATUS" && "$SYSTEMD_STATUS" != "0" ]]; then
        MAIN_USER=$(ps -o user= -p "$SYSTEMD_STATUS" 2>/dev/null)
        if [[ -n "$MAIN_USER" && "$MAIN_USER" != "root" ]]; then
            STATUS="Pass"
            VALUE="MariaDB is managed by systemd and running as $MAIN_USER (not root)"
        fi
    fi

    # 3. Cek apakah MariaDB berjalan di Docker
    if command -v docker &>/dev/null; then
        DOCKER_MARIADB_RUNNING=$(docker ps --filter "ancestor=mariadb" --format "{{.Names}}" 2>/dev/null)
        if [[ -n "$DOCKER_MARIADB_RUNNING" ]]; then
            STATUS="Pass"
            VALUE="MariaDB is running inside Docker container(s): $DOCKER_MARIADB_RUNNING"
        fi
    fi
fi

# Tulis hasil audit
{
    echo "Judul Audit : 1.7 Ensure MariaDB is Run Under a Sandbox Environment"
    echo "Status : $STATUS"
    echo "Nilai Konfigurasi : $VALUE"
    echo "Nilai CIS : MariaDB harus dijalankan dalam sandbox environment (chroot, systemd dengan isolasi, atau Docker)"
    echo "Deskripsi : Verifikasi bahwa MariaDB berjalan di lingkungan sandbox untuk meminimalkan dampak potensi kerentanan."
    echo "-------------------------------------------------------------"
    echo ""
} >> "$OUTPUT_FILE"
