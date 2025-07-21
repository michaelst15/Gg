#!/bin/bash

# File konfigurasi yang ditargetkan
conf_file="/etc/modprobe.d/sctp.conf"
base_name=$(basename "$conf_file")
backup_pattern="${conf_file}.bak."  # Pola nama backup: /etc/modprobe.d/sctp.conf.bak.YYYY-MM-DD-HHMMSS

# File hasil log rollback
rollback_output="rollback_sctp_result.txt"

echo "Rollback Konfigurasi SCTP (backup jam paling awal)" > "$rollback_output"
echo "Tanggal rollback: $(date)" >> "$rollback_output"
echo "==============================================================" >> "$rollback_output"

# Cari backup jam paling awal berdasarkan nama timestamp
earliest_backup=$(find "$(dirname "$conf_file")" -maxdepth 1 -type f -name "$base_name.bak.*" 2>/dev/null | \
  grep -oP "${base_name}\.bak\.\K\d{4}-\d{2}-\d{2}-\d{6}" | \
  sort | \
  head -n 1)

full_path_backup="${conf_file}.bak.${earliest_backup}"

# Jika backup dengan timestamp awal ditemukan
if [[ -n "$earliest_backup" && -f "$full_path_backup" ]]; then
  cp "$full_path_backup" "$conf_file"
  chmod 644 "$conf_file"
  echo "✅ Konfigurasi dipulihkan dari backup paling awal: $full_path_backup" | tee -a "$rollback_output"
else
  if [[ -f "$conf_file" ]]; then
    rm -f "$conf_file"
    echo "⚠️ Tidak ada backup ditemukan. File $conf_file dihapus karena dianggap hasil remediasi." | tee -a "$rollback_output"
  else
    echo "ℹ️ Tidak ada file $conf_file yang perlu dihapus. Rollback tidak diperlukan." | tee -a "$rollback_output"
  fi
fi

echo -e "\nRollback selesai. Log disimpan di: $rollback_output"
