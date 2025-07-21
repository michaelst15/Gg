
#!/bin/bash

# File konfigurasi target
conf_file="/etc/modprobe.d/rds.conf"
base_name=$(basename "$conf_file")

# File hasil output rollback
rollback_output="rollback_rds_result.txt"

echo "Rollback Konfigurasi RDS (berdasarkan backup jam paling awal)" > "$rollback_output"
echo "Tanggal rollback: $(date)" >> "$rollback_output"
echo "==============================================================" >> "$rollback_output"

# Cari backup jam paling awal berdasarkan timestamp di nama file
earliest_backup=$(find "$(dirname "$conf_file")" -maxdepth 1 -type f -name "$base_name.bak.*" 2>/dev/null | \
  grep -oP "${base_name}\.bak\.\K\d{4}-\d{2}-\d{2}-\d{6}" | \
  sort | head -n 1)

# Gabungkan ke path lengkap
full_backup_path="${conf_file}.bak.${earliest_backup}"

# Lakukan rollback jika backup ditemukan
if [[ -n "$earliest_backup" && -f "$full_backup_path" ]]; then
    cp "$full_backup_path" "$conf_file"
    chmod 644 "$conf_file"
    echo "✅ Konfigurasi dipulihkan dari backup: $full_backup_path (Timestamp: $earliest_backup)" | tee -a "$rollback_output"
else
    if [[ -f "$conf_file" ]]; then
        rm -f "$conf_file"
        echo "⚠️ Tidak ada backup ditemukan. File $conf_file dihapus karena dianggap hasil remediasi." | tee -a "$rollback_output"
    else
        echo "ℹ️ Tidak ada file $conf_file yang perlu dihapus. Rollback tidak diperlukan." | tee -a "$rollback_output"
    fi
fi

echo -e "\nRollback selesai. Log disimpan di: $rollback_output"
