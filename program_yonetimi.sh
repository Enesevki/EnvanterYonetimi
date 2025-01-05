#!/bin/bash

# Ana menü fonksiyonu
ana_menu() {
    while true; do
        # Menü seçenekleri
        secim=$(zenity --list --title="Program Yönetimi" \
            --text="Lütfen bir işlem seçin:" \
            --column="Seçenek" \
            "Disk Alanını Göster" \
            "Diske Yedek Al" \
            "Hata Kayıtlarını Görüntüle" \
            "Çıkış" \
            --height=300 --width=400)

        # Seçime göre işlem yapılacak
        case $secim in
            "Disk Alanını Göster")
                diskteki_alani_goster
                ;;
            "Diske Yedek Al")
                diske_yedekle
                ;;
            "Hata Kayıtlarını Görüntüle")
                hata_kayitlarini_goster
                ;;
            "Çıkış")
                ./show_progress.sh
                exit 0
                ;;
            *)
                zenity --error --text="Geçersiz seçim!" --width=300
                ;;
        esac
    done
}

# Diskteki alanı gösterme fonksiyonu
diskteki_alani_goster() {
    # Disk kullanımını daha anlaşılır bir şekilde hazırlama
    local disk_kullanimi=$(df -h --output=source,size,used,avail,pcent / | tail -n 1)
    
    # Başlıkları ve verileri ayırarak daha kullanıcı dostu hale getir
    local kaynak=$(echo "$disk_kullanimi" | awk '{print $1}')
    local toplam=$(echo "$disk_kullanimi" | awk '{print $2}')
    local kullanilan=$(echo "$disk_kullanimi" | awk '{print $3}')
    local bos=$(echo "$disk_kullanimi" | awk '{print $4}')
    local yuzde=$(echo "$disk_kullanimi" | awk '{print $5}')

    # Kullanıcı dostu mesaj oluştur
    local mesaj="Disk Kullanım Detayları:\n\n"
    mesaj+="Kaynak: $kaynak\n"
    mesaj+="Toplam Alan: $toplam\n"
    mesaj+="Kullanılan Alan: $kullanilan\n"
    mesaj+="Boş Alan: $bos\n"
    mesaj+="Kullanım Oranı: $yuzde\n"

    # Zenity ile göster
    zenity --info --title="Disk Alanı" --text="$mesaj" --width=400
}

# Verileri diske yedekleme fonksiyonu
diske_yedekle() {
    # Yedeklenecek dosyalar
    local dosyalar=("depo.csv" "kullanicilar.csv")
    local yedek_dosyalar=()
    local hata_dosyalar=()

    for dosya in "${dosyalar[@]}"; do
        if [[ -f $dosya ]]; then
            cp "$dosya" "${dosya}.bak"
            yedek_dosyalar+=("$dosya")
        else
            hata_dosyalar+=("$dosya")
        fi
    done

    if [[ ${#yedek_dosyalar[@]} -gt 0 ]]; then
        zenity --info --text="Başarıyla Yedeklenen Dosyalar:\\n$(printf '%s\\n' "${yedek_dosyalar[@]}")" --width=400
    fi

    if [[ ${#hata_dosyalar[@]} -gt 0 ]]; then
        zenity --error --text="Yedeklenemeyen Dosyalar:\\n$(printf '%s\\n' "${hata_dosyalar[@]}")" --width=400
    fi
}

# Hata kayıtlarını gösterme fonksiyonu
hata_kayitlarini_goster() {
    # log.csv dosyasının içeriğini gösterir
    if [[ -f log.csv ]]; then
        zenity --text-info --title="Hata Kayıtları" --filename=log.csv --width=600 --height=400
    else
        zenity --info --text="Hata kaydı bulunamadı. Sistem sorunsuz çalışıyor!" --width=400
    fi
}

# Ana menüyü başlat
ana_menu

