#!/bin/bash

# Direktori backup
backup_dir="/var/backups/tmout"

# File target konfigurasi
target_files=(
  "/etc/bashrc"
  "/etc/profile"
)

# File hasil output rollback
rollback_output="rollback_result.txt"

echo "Rollback konfigurasi TMOUT" > "$rollback_output"
echo "Tanggal rollback: $(date)" >> "$rollback_output"
echo "==============================================================" >> "$rollback_output"

for file in "${target_files[@]}"; do
  base_name=$(basename "$file")
  
  # Cari backup terbaru berdasarkan timestamp
  latest_backup=$(find "$backup_dir" -type f -name "$base_name.bak.*" | sort -r | head -n 1)
  
  if [[ -n "$latest_backup" && -f "$latest_backup" ]]; then
    cp "$latest_backup" "$file"
    chmod 644 "$file"
    timestamp=$(echo "$latest_backup" | grep -oP '\d{4}-\d{2}-\d{2}-\d{6}')
    echo "✅ Restored $file from $latest_backup (Backup timestamp: $timestamp)" >> "$rollback_output"
    echo "✅ $file dikembalikan dari backup $timestamp"
  else
    echo "⚠️  Backup tidak ditemukan untuk $file" >> "$rollback_output"
    echo "⚠️  Backup tidak ditemukan untuk $file"
  fi
done

echo -e "\nRollback selesai. Log disimpan di: $rollback_output"
