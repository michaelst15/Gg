 "Mencari dan menghapus semua karakter  (carriage return) dari file .sh ..."
find . -type f -name "*.sh" | while read -r file; do
    echo "Membersihkan: $file"
    tr -d '\r' < "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
done
echo "Semua  telah dihapus dari semua file .sh"
