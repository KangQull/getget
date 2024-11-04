#!/bin/bash
cilukbwaa
clear
PURPLE='\033[1;33m'
RESET='\033[0m'

# Fungsi untuk menampilkan progress bar
progress_bar() {
    local pid=$1
    local bar_length=50

    while ps -p $pid > /dev/null; do
        # Menghitung persentase dengan cara yang lebih sederhana
        echo -ne "\r${PURPLE}[${bar:0:filled_length}${RESET}${bar:filled_length} ...... ${PURPLE}]${RESRT}"
        sleep 1
    done

    # Menampilkan progress bar penuh jika cloning selesai
    printf "\r${PURPLE}[${bar:0:bar_length}${RESET} 100%%\n"
}

# Nama folder yang akan dibuat
REPO_NAME="docker"

# Memeriksa apakah folder sudah ada
if [ -d "$REPO_NAME" ]; then
    echo -e "${PURPLE}Folder '$REPO_NAME' sudah ada. Proses cloning dibatalkan.${RESET}"
    exit 1
fi

# Meminta Personal Access Token GitHub
read -sp "Masukkan Access Token Script: " TOKEN
echo
clear
# Menampilkan pesan sebelum mulai cloning
echo -e "${PURPLE}Tunggu sebentar...${RESET}"

# Mengkode dan mengkloning repositori dengan opsi --quiet
CODE=aHR0cHM6Ly9naXRodWIuY29tL0thbmdRdWxsL2RvY2tlci5naXQ=
REPO_URL=$(echo $CODE | base64 --decode)

# Melakukan cloning dengan autentikasi menggunakan token
GIT_ASKPASS=$(mktemp) # Membuat file sementara untuk menyimpan password
echo "echo $TOKEN" > $GIT_ASKPASS
chmod +x $GIT_ASKPASS

# Melakukan git clone dan menangkap status
git clone --quiet https://x-access-token:$TOKEN@github.com/KangQull/docker.git &
PID=$!  # Menyimpan PID dari proses git clone

# Menampilkan progress bar
progress_bar $PID

# Menunggu proses cloning selesai
wait $PID
STATUS=$?  # Menyimpan status keluaran

# Menghapus file sementara
rm -f $GIT_ASKPASS

# Memeriksa status dan memberikan pesan sesuai
if [ $STATUS -ne 0 ]; then
    echo -e "\n${PURPLE}Gagal melakukan cloning. Pastikan Personal Access Token Anda benar.${RESET}"
    # Menghapus folder jika cloning gagal
    rm -rf "$REPO_NAME"
    exit 1
fi

# Menampilkan pesan setelah cloning selesai dan menambahkan jeda
echo -e "${PURPLE}Downloading selesai!${RESET}"
sleep 3  # Jeda selama 3 detik

# Menyalin file dari folder repositori ke lokasi tujuan
cp docker/windocker.sh ~/

# Menghapus folder setelah menyalin file
rm -rf "$REPO_NAME"
echo ""
echo -e "${PURPLE}Menjalankan Script dalam 5 detik..${RESET}"
for ((i=5; i>0; i--)); do
    echo -ne "${PURPLE}$i detik tersisa...\r${RESET}"
    sleep 1
done
clear
#start
bash windocker.sh
