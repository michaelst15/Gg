CONFIG_FILE="db_config.sh"
 
find . -type f -name "*.sh" ! -name "$CONFIG_FILE" ! -name "$(basename "$0")" | while read -r file; do
    echo "Memproses: $file"
 
# Lewati jika sudah mengarah ke db_config.sh
if grep "source.*db_config.sh" "$file" >/dev/null 2>&1; then
echo " Sudah mengarah ke db_config.sh, lewati."
        continue
    fi
 
    tmp_file="${file}.tmp"
 
awk -v insert_line='source "$(dirname \"$0\")/db_config.sh"' '
    BEGIN { inserted = 0 }
    # Hapus semua baris USERNAME, PASSWORD, PASSWOR, DATABASE dalam berbagai variasi
    /^[[:space:]]*(export[[:space:]]*)?(USERNAME|PASSWORD|PASSWOR|DATABASE)[[:space:]]*=[[:space:]]*/ { next }
 
    # Sisipkan source setelah shebang
    NR == 1 {
        print
        if ($0 ~ /^#!/) {
            print insert_line
            inserted = 1
            next
        }
    }
    { print }
 
    END {
        if (!inserted) {
            print insert_line
        }
    }
    ' "$file" > "$tmp_file"
 
    mv "$tmp_file" "$file"
    chmod +x "$file"
echo "Kredensial dihapus dan db_config.sh ditambahkan."
done
