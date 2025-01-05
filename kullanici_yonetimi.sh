#!/bin/bash

# Kullanıcı ekleme fonksiyonu
kullanici_ekle() {
    # Yeni kullanıcı bilgilerini al
    local kullanici_adi=$(zenity --entry --title="Kullanıcı Ekle" --text="Yeni kullanıcı adını girin:" --width=300)
    local sifre=$(zenity --entry --title="Kullanıcı Ekle" --text="Yeni şifreyi girin:" --width=300 --hide-text)

    # Şifre doğrulaması
    local sifre_tekrar=$(zenity --entry --title="Kullanıcı Ekle" --text="Şifreyi tekrar girin:" --width=300 --hide-text)
    if [[ "$sifre" != "$sifre_tekrar" ]]; then
        zenity --error --text="Şifreler uyuşmuyor!" --width=300
        return 1
    fi

    # Rol seçimini yap (Yönetici veya Kullanıcı)
    local rol=$(zenity --list --title="Kullanıcı Rolü" --text="Kullanıcı rolünü seçin:" --column="Rol" --height=200 --width=300 \
        "Yönetici" "Kullanıcı")
    if [[ -z "$rol" ]]; then
        zenity --error --text="Rol seçmediniz!" --width=300
        return 1
    fi

    # Kilitli durumu otomatik olarak "Hayır" ata
    local kilitli="Hayır"

    # Şifreyi MD5 ile hashle
    local sifre_md5=$(echo -n "$sifre" | md5sum | awk '{print $1}')

    # Kullanıcıyı kullanicilar.csv'ye ekle
    echo "$kullanici_adi,$sifre_md5,$rol,$kilitli" >> kullanicilar.csv

    # Başarı mesajı
    zenity --info --text="Kullanıcı başarıyla eklendi!" --width=300
}

# Kullanıcı silme fonksiyonu
kullanici_sil() {
    # Kullanıcıları listele
    local kullanici_listesi=$(awk -F',' '{print $1 " " $2}' kullanicilar.csv)

    # Kullanıcıyı seçtirme
    local secilen_kullanici=$(zenity --list --title="Kullanıcı Sil" --column="ID" --column="Kullanıcı Adı" --text="Silmek istediğiniz kullanıcıyı seçin:" \
        --height=400 --width=600 --radiolist --multiple --separator="," $kullanici_listesi)

    if [[ -z "$secilen_kullanici" ]]; then
        zenity --error --text="Bir kullanıcı seçmediniz!" --width=300
        return 1
    fi

    # Seçilen kullanıcıyı ID'ye göre sil
    local kullanici_id=$(echo $secilen_kullanici | cut -d ' ' -f1)
    sed -i "/^$kullanici_id,/d" kullanicilar.csv

    # Başarı mesajı
    zenity --info --text="Kullanıcı başarıyla silindi!" --width=300
}

# Kullanıcı listeleme fonksiyonu
kullanici_listele() {
    # Kullanıcıları listele
    local kullanici_listesi=$(cat kullanicilar.csv)

    if [[ -z "$kullanici_listesi" ]]; then
        zenity --info --text="Henüz kullanıcı eklenmemiş." --width=300
        return 1
    fi

    # Kullanıcıları zenity ile göster
    zenity --info --title="Kullanıcı Listesi" --text="$kullanici_listesi" --width=600 --height=400
}

# Kullanıcı güncelleme fonksiyonu
kullanici_guncelle() {
    # Kullanıcı adlarını ve rollerini listele, başlık satırını atla
    local kullanici_listesi=()
    while IFS=',' read -r username password role locked; do
        # Başlık satırını atla ve sadece geçerli kullanıcıları ekle
        if [[ "$username" != "Username" && -n "$username" && -n "$role" ]]; then
            kullanici_listesi+=("$username" "$role")
        fi
    done < kullanicilar.csv

    # Kullanıcı listesi boşsa hata göster
    if [[ ${#kullanici_listesi[@]} -eq 0 ]]; then
        zenity --error --text="Kullanıcı listesi boş!" --width=300
        return 1
    fi

    # Zenity ile kullanıcı seçtirme
    local secilen_kullanici=$(zenity --list --title="Kullanıcı Güncelle" \
        --text="Güncellemek istediğiniz kullanıcıyı seçin:" \
        --column="Kullanıcı Adı" --column="Rol" \
        --height=400 --width=600 \
        "${kullanici_listesi[@]}")

    # Kullanıcı seçilmediyse hata göster
    if [[ -z "$secilen_kullanici" ]]; then
        zenity --error --text="Bir kullanıcı seçmediniz!" --width=300
        return 1
    fi

    # Seçilen kullanıcıyı bul
    local user_entry=$(grep "^$secilen_kullanici," kullanicilar.csv)

    # Yeni şifreyi sor
    local yeni_sifre=$(zenity --password --title="Kullanıcı Güncelle" --text="Yeni şifreyi girin:" --width=300)

    # Şifre doğrulaması
    local yeni_sifre_tekrar=$(zenity --password --title="Kullanıcı Güncelle" --text="Yeni şifreyi tekrar girin:" --width=300)

    if [[ "$yeni_sifre" != "$yeni_sifre_tekrar" ]]; then
        zenity --error --text="Şifreler uyuşmuyor!" --width=300
        return 1
    fi

    # Şifreyi MD5 ile hashle
    local sifre_md5=$(echo -n "$yeni_sifre" | md5sum | awk '{print $1}')

    # Kullanıcıyı güncelle
    sed -i "s/^$secilen_kullanici,.*/$secilen_kullanici,$sifre_md5,${user_entry#*,}" kullanicilar.csv

    # Başarı mesajı
    zenity --info --text="Kullanıcı başarıyla güncellendi!" --width=300
}


# Ana Menü



# Kilitli hesap açma fonksiyonu
unlock_account() {
    local kilitli_kullanici=$(grep "Evet" kullanicilar.csv | cut -d ',' -f1 | zenity --list --title="Kilitli Hesapları Aç" --column="Kullanıcı Adları")
    if [ -n "$kilitli_kullanici" ]; then
        sed -i "s/^$kilitli_kullanici,.*,.*,Evet/$kilitli_kullanici,\1,\2,Hayır/" kullanicilar.csv
        ./show_progress.sh
        zenity --info --text="Hesap başarıyla açıldı!" --width=300
    else
        zenity --info --text="Kilitli hesap bulunamadı veya seçim yapılmadı." --width=300
    fi
}

menu() {
    while true; do
        # Menü seçenekleri
        secim=$(zenity --list --title="Kullanıcı Yönetimi" \
            --text="Lütfen bir işlem seçin:" \
            --column="İşlemler" \
            "Kullanıcı Ekle" \
            "Kullanıcı Sil" \
            "Kullanıcı Listele" \
            "Kullanıcı Güncelle" \
            "Kilitli Hesapları Aç" \
            "Çıkış" \
            --height=400 --width=600)

        # Seçim boşsa veya geçersizse kontrol
        if [[ -z "$secim" ]]; then
            zenity --info --text="Hiçbir işlem seçilmedi. Menüye geri dönülüyor..." --width=300
            continue
        fi

        # Seçime göre işlem yapılacak
        case $secim in
            "Kullanıcı Ekle") kullanici_ekle ;;
            "Kullanıcı Sil") kullanici_sil ;;
            "Kullanıcı Listele") kullanici_listele ;;
            "Kullanıcı Güncelle") kullanici_guncelle ;;
            "Kilitli Hesapları Aç") unlock_account ;;
            "Çıkış")
                exit 0
                break
                ;;
            *)
                zenity --error --text="Geçersiz işlem!" --width=300
                ;;
        esac
    done
}




# Ana Menü'yü başlat
menu

