# Temukan semua script yang bernama angka seperti 1.sh, 2.1.sh, dst
SCRIPTS=$(find . -type f -name "*.sh" | egrep '\./([0-9]+\.)*[0-9]+\.sh$' | sort)

if [ -z "$SCRIPTS" ]; then
  echo "❌ Tidak ditemukan script dengan nama angka (contoh: 1.sh, 2.1.sh)"
  exit 1
fi

# Memberi izin eksekusi semua script
for script in $SCRIPTS; do
  chmod +x "$script"
done

# Kosongkan file hasil gabungan
> audit_results.txt

TOTAL=$(echo "$SCRIPTS" | wc -l)
COUNT=1

# Jalankan semua script satu per satu
for script in $SCRIPTS; do
  echo ""
  echo "[$COUNT/$TOTAL] Menjalankan: $script"
  echo "----------------------------------------"

  {
    echo "----------------------------------------"
    echo "# SCRIPT: $script"
    echo "----------------------------------------"
    ./"$script"
    echo ""
  } >> audit_results.txt

  echo "✅ Selesai: $script"
  COUNT=$((COUNT + 1))

  # Jeda 1 detik sebelum menjalankan script berikutnya
  sleep 1
done

echo ""
echo "🎉 Semua script selesai dijalankan."



find . -type f -name "*.sh" -exec sed -i 's/\r$//' {} +

