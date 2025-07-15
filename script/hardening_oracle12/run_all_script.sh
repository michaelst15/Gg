INSTANCES="cmtuaid2 cmtuaid cmtuaid4 cmtuaid3"
#di Temukan semua script yang bernama angka seperti 1.sh, 2.1.sh, dst
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
echo "" > audit_results.txt
 
# Jalankan untuk tiap instance
for SID in $INSTANCES; do
  echo ""
  echo "🔍 Cek Instance $SID .................."
  export ORACLE_SID="$SID"
 
  ORAENV_PATH="/usr/local/bin/oraenv"
 
  if [ ! -f "$ORAENV_PATH" ]; then
    echo "❌ File oraenv tidak ditemukan di $ORAENV_PATH. Harap sesuaikan path-nya."
    exit 1
  fi
 
  echo "$SID" | . "$ORAENV_PATH" > /tmp/oraenv_output.log 2>&1
 
  ORAENV_LOG=$(cat /tmp/oraenv_output.log)
 
  if [ -z "$ORACLE_HOME" ] || [ ! -d "$ORACLE_HOME" ]; then
    echo "⚠️ Gagal mendeteksi ORACLE_HOME dari oraenv untuk instance $SID."
    echo "💬 Output oraenv:"
    cat /tmp/oraenv_output.log
    echo "❓ Masukkan ORACLE_HOME secara manual untuk $SID: \c"
    read ORACLE_HOME
    if [ ! -d "$ORACLE_HOME" ]; then
      echo "❌ Direktori ORACLE_HOME tidak valid: $ORACLE_HOME"
      echo "➡️ Lewati instance $SID..."
      continue
    fi
    export ORACLE_HOME
  fi
 
  export PATH=$ORACLE_HOME/bin:$PATH
 
  echo "✅ Environment siap:"
  echo " ORACLE_SID = $ORACLE_SID"
  echo " ORACLE_HOME = $ORACLE_HOME"
  echo ""
 
  # Tambahkan pemisah dan judul ke hasil audit
  {
    echo "================================================================================"
    echo ">> HASIL AUDIT UNTUK INSTANCE: $SID"
    echo "================================================================================"
    echo ""
  } >> audit_results.txt
 
  TOTAL=$(echo "$SCRIPTS" | wc -l)
  COUNT=1
 
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
    COUNT=$(($COUNT + 1))
  done
 
  echo "\n================================================================================\n" >> audit_results.txt
  echo "✅ Semua script selesai dijalankan untuk instance: $SID"
done
 
echo ""
echo "🎉 Semua proses selesai dijalankan untuk semua instance Oracle."
 
