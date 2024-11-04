#!/bin/bash

PURPLE='\033[1;33m'
RESET='\033[0m'

# Fungsi untuk menampilkan progress bar
progress_bar() {
    local pid=$1
    local duration=50  # Durasi total dalam detik (sesuaikan jika perlu)
    local interval=1   # Interval pembaruan progress bar dalam detik
    local elapsed=0
    local bar_length=50

    while ps -p $pid > /dev/null; do
        elapsed=$((elapsed + interval))
        local progress=$((elapsed * 100 / duration))
        local filled_length=$((progress * bar_length / 100))
        local bar=$(printf "%-${bar_length}s" "#" | sed "s/ /#/g")
        printf "\r${PURPLE}[${bar:0:filled_length}${RESET}${bar:filled_length} ${progress}%%]"
        sleep $interval
    done

    # Menampilkan progress bar penuh jika cloning selesai
    printf "\r${PURPLE}[${bar:0:bar_length}${RESET} 100%%]\n"
}

# Nama folder yang akan dibuat
REPO_NAME="docker"
# Lokasi untuk menyalin file sebelum penghapusan
DESTINATION_DIR="backup"

# Memeriksa apakah folder sudah ada
if [ -d "$REPO_NAME" ]; then
    echo -e "${PURPLE}Folder '$REPO_NAME' sudah ada. Proses cloning dibatalkan.${RESET}"
    exit 1
fi

# Meminta Personal Access Token GitHub
read -sp "Masukkan Personal Access Token GitHub: " TOKEN
echo

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

# Menampilkan pesan setelah cloning selesai
echo -e "${PURPLE}Clone selesai!${RESET}"

# Memeriksa apakah direktori tujuan ada, jika tidak, buat direktori tersebut
if [ ! -d "$DESTINATION_DIR" ]; then
    mkdir "$DESTINATION_DIR"
fi

# Menyalin file dari folder repositori ke lokasi tujuan
cp -r "$REPO_NAME/"* "$DESTINATION_DIR/"

# Menghapus folder setelah menyalin file
rm -rf "$REPO_NAME"
echo -e "${PURPLE}Folder '$REPO_NAME' telah dihapus dan file telah disalin ke '$DESTINATION_DIR'.${RESET}"
