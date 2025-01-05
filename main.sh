
# CSV dosyalarının varlığını kontrol et ve eksik olanları oluştur, tüm bash dosyalarına gerekli izinleri ver
find . -type f -name "init.sh" -exec chmod +x {} \; 
./init.sh

# Kullanıcı giriş fonksiyonu
kullanici_giris() {
    kullanici=$(zenity --entry --title="Giriş Yap" --text="Kullanıcı Adınızı Girin:" --width=300)

    # Kullanıcıyı kontrol et ve kilit durumu kontrolü yap
    user_entry=$(grep "^$kullanici," kullanicilar.csv)
    if [[ -z "$user_entry" ]]; then
        zenity --error --text="Kullanıcı bulunamadı!" --width=300
        return 1
    fi

    locked=$(echo "$user_entry" | cut -d ',' -f4)
    if [[ "$locked" == "Evet" ]]; then
        zenity --error --text="Hesabınız kilitlenmiştir. Yönetici ile iletişime geçin." --width=300
        exit 1
    fi

    local attempts=0

    while true; do
        sifre=$(zenity --password --title="Şifre Girin:" --width=300)

        # Şifreyi MD5 ile hashle ve karşılaştır
        sifre_md5=$(echo -n "$sifre" | md5sum | awk '{print $1}')
        stored_password=$(echo "$user_entry" | cut -d ',' -f2)
        if [[ "$sifre_md5" == "$stored_password" ]]; then
            role=$(echo "$user_entry" | cut -d ',' -f3)
            sed -i "s/^$kullanici,.*/$kullanici,$sifre_md5,$role,Hayır/" kullanicilar.csv  # Giriş başarılı
            echo "$role"
            return 0
        else
            attempts=$((attempts + 1))
            if [[ $attempts -ge 3 ]]; then
                sed -i "s/^$kullanici,.*/$kullanici,$sifre_md5,$role,Evet/" kullanicilar.csv
                echo "$(date),ERROR,Account Locked,$kullanici" >> log.csv
                zenity --error --text="Hesabınız 3 hatalı giriş nedeniyle kilitlenmiştir. Yönetici ile iletişime geçin." --width=300
                exit 1
            fi
            zenity --error --text="Hatalı şifre, tekrar deneyin! ($attempts/3)" --width=300
        fi
    done
}
kullanici_kayit() {
    # Yeni kullanıcı bilgilerini al
    kullanici=$(zenity --entry --title="Kayıt Ol" --text="Kullanıcı Adınızı Girin:" --width=300)
    if grep -qi "^$kullanici," kullanicilar.csv; then
        zenity --error --text="Bu kullanıcı adı zaten mevcut!" --width=300
        return 1
    fi

    sifre=$(zenity --password --title="Kayıt Ol" --text="Şifre Girin:" --width=300)
    sifre_tekrar=$(zenity --password --title="Kayıt Ol" --text="Şifreyi Tekrar Girin:" --width=300)
    if [[ "$sifre" != "$sifre_tekrar" ]]; then
        zenity --error --text="Şifreler uyuşmuyor!" --width=300
        return 1
    fi

    role="Kullanıcı"

    # Şifreyi MD5 ile hashle
    sifre_md5=$(echo -n "$sifre" | md5sum | awk '{print $1}')

    # Yeni kullanıcıyı ekle
    echo "$kullanici,$sifre_md5,$role,Hayır" >> kullanicilar.csv
    zenity --info --text="Kullanıcı başarıyla oluşturuldu!" --width=300
}

ana_menu() {
    secim=$(zenity --list --title="Hoş Geldiniz" \
        --text="Giriş yapmak veya kayıt olmak ister misiniz?" \
        --column="Seçim" "Giriş Yap" "Kayıt Ol" --width=300 --height=200)

    if [[ "$secim" == "Giriş Yap" ]]; then
        rol=$(kullanici_giris)
        if [[ $rol == "Yönetici" ]]; then
            yonetici_menu
        elif [[ $rol == "Kullanıcı" ]]; then
            kullanici_menu
        else
            zenity --error --text="Bilinmeyen rol!" --width=300
            exit 1
        fi
    elif [[ "$secim" == "Kayıt Ol" ]]; then
        kullanici_kayit
        ana_menu  # Kayıt sonrası girişe geri dön
    else
        ./show_progress.sh
        exit 0
    fi
}


# Yönetici menüsü
yonetici_menu() {
    while true; do
        secim=$(zenity --list --title="Yönetici Menüsü"             --column="Seçenekler" "Ürün Ekle" "Ürün Listele" "Ürün Güncelle" "Ürün Sil"             "Rapor Al" "Kullanıcı Yönetimi" "Program Yönetimi" "Çıkış" --width=400 --height=300)

        case $secim in
            "Ürün Ekle")
                ./urun_ekle.sh
                ;;
            "Ürün Listele")
                ./urun_listele.sh
                ;;
            "Ürün Güncelle")
                ./urun_guncelle.sh
                ;;
            "Ürün Sil")
                ./urun_sil.sh
                ;;
            "Rapor Al")
                ./rapor_al.sh
                ;;
            "Kullanıcı Yönetimi")
                ./kullanici_yonetimi.sh
                ;;
            "Program Yönetimi")
                ./program_yonetimi.sh
                ;;
            "Çıkış")
                exit 0
                ;;
            *)
                zenity --error --text="Geçersiz seçim!" --width=300
                ;;
        esac
    done
}

# Kullanıcı menüsü
kullanici_menu() {
    while true; do
        secim=$(zenity --list --title="Kullanıcı Menüsü"             --column="Seçenekler" "Ürün Listele" "Rapor Al" "Çıkış" --width=400 --height=200)

        case $secim in
            "Ürün Listele")
                ./urun_listele.sh
                ;;
            "Rapor Al")
                ./rapor_al.sh
                ;;
            "Çıkış")
                exit 0
                ;;
            *)
                zenity --error --text="Geçersiz seçim!" --width=300
                ;;
        esac
    done
}

# Ana program
ana_menu
