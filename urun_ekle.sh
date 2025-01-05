#!/bin/bash

urun_ekle() {
    # Ürün bilgilerini alma
    local urun_bilgileri=$(zenity --forms --title="Ürün Ekle" \
        --text="Yeni ürün bilgilerini girin:" \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Birim Fiyatı" \
        --width=400)

    # Kullanıcı işlemi iptal ettiyse çıkış yap
    if [[ -z "$urun_bilgileri" ]]; then
        zenity --error --text="İşlem iptal edildi!" --width=300
        return
    fi

    # Bilgileri ayır
    local urun_adi=$(echo $urun_bilgileri | cut -d '|' -f1)
    local stok=$(echo $urun_bilgileri | cut -d '|' -f2)
    local fiyat=$(echo $urun_bilgileri | cut -d '|' -f3)

    # Ürün adı doğrulaması
    if ! validate_product_name "$urun_adi"; then
        zenity --error --text="Ürün adı boşluk içeremez!" --width=300
        return
    fi

    # Doğrulama
    if [[ -z "$urun_adi" || -z "$stok" || -z "$fiyat" ]]; then
        zenity --error --text="Tüm alanlar doldurulmalıdır!" --width=300
        return
    fi
    if ! [[ $stok =~ ^[0-9]+$ ]] || ! [[ $fiyat =~ ^[0-9]+(\.[0-9]{1,2})?$ ]]; then
        zenity --error --text="Stok ve fiyat pozitif sayı olmalıdır!" --width=300
        return
    fi
    if grep -qi "^.*,$urun_adi,.*$" depo.csv; then
        zenity --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz." --width=400
        echo "$(date),HATA,Ürün eklenemedi: $urun_adi zaten mevcut." >> log.csv
        return
    fi

    # Ürün numarasını belirle
    local son_numara=$(tail -n 1 depo.csv | cut -d ',' -f1)
    local urun_no=$((son_numara + 1))

    # Veriyi CSV'ye ekle
    echo "$urun_no,$urun_adi,$stok,$fiyat" >> depo.csv
    ./show_progress.sh
    zenity --info --text="Ürün başarıyla eklendi!" --width=300
}

validate_product_name() {
    local name=$1
    if [[ "$name" =~ \  ]]; then
        echo "Product name cannot contain spaces."
        return 1
    fi
    return 0
}



# Fonksiyonun çağrılması
urun_ekle

