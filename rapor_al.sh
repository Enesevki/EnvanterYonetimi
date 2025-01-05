#!/bin/bash

# Rapor Al fonksiyonu
rapor_al() {
    while true; do
        # Menü seçenekleri
        secim=$(zenity --list --title="Rapor Al" --column="Seçenek" --height=300 --width=400 \
            "Stokta Azalan Ürünler" \
            "En Yüksek Stok Miktarına Sahip Ürünler" \
            "Çıkış")

        case $secim in
            "Stokta Azalan Ürünler")
                stokta_azalan_urunler
                ;;
            "En Yüksek Stok Miktarına Sahip Ürünler")
                en_yuksek_stok_urunleri
                ;;
            "Çıkış")
                zenity --info --text="Rapor almayı sonlandırıyorsunuz..." --width=300
                break
                ;;
            *)
                zenity --error --text="Geçersiz seçim!" --width=300
                ;;
        esac
    done
}

# Stokta azalan ürünleri listeleyen fonksiyon
stokta_azalan_urunler() {
    # Eşik değeri kullanıcıdan alınır
    local esik_degeri=$(zenity --entry --title="Stokta Azalan Ürünler" \
        --text="Eşik değerini girin:" --width=300)

    if [[ ! "$esik_degeri" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Eşik değeri geçerli bir sayı olmalıdır!" --width=300
        return 1
    fi

    # Depo dosyasından stok miktarları  eşik değerinin altındaki ürünleri al
    local azalan_urunler=$(awk -F',' -v esik=$esik_degeri '$3 < esik {print $2 " - Stok: " $3 " - Fiyat: " $4}' depo.csv)

    if [[ -z "$azalan_urunler" ]]; then
        zenity --info --text="Stokta azalan ürün bulunmamaktadır." --width=300
    else
        zenity --info --text="Stokta Azalan Ürünler:\n$azalan_urunler" --width=600
    fi
}

# En yüksek stok miktarına sahip ürünleri listeleyen fonksiyon
en_yuksek_stok_urunleri() {
    # Eşik değeri kullanıcıdan alınır
    local esik_degeri=$(zenity --entry --title="En Yüksek Stok Miktarına Sahip Ürünler" \
        --text="Eşik değerini girin:" --width=300)

    if [[ ! "$esik_degeri" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Eşik değeri geçerli bir sayı olmalıdır!" --width=300
        return 1
    fi

    # Depo dosyasından stok miktarları eşik değerinin üzerindeki ürünleri al
    local yuksek_stok_urunler=$(awk -F',' -v esik=$esik_degeri '$3 > esik {print $2 " - Stok: " $3 " - Fiyat: " $4}' depo.csv)

    if [[ -z "$yuksek_stok_urunler" ]]; then
        zenity --info --text="Eşik değerinin üzerinde stok bulunan ürün yok." --width=300
    else
        zenity --info --text="En Yüksek Stok Miktarına Sahip Ürünler:\n$yuksek_stok_urunler" --width=600
    fi
}

# Fonksiyonu çağır
rapor_al

