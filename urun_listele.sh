#!/bin/bash

urun_listele() {
    # Depo dosyasındaki ürünleri al
    ./show_progress.sh
    local urunler=$(cat depo.csv)

    # Ürünlerin her birini satır satır ayır ve listele
    if [[ -z "$urunler" ]]; then
        zenity --info --text="Envanterde ürün bulunmamaktadır." --width=300
    else
        zenity --text-info --title="Ürün Listele" \
            --width=600 --height=400 \
            --filename=<(echo "$urunler")
    fi
}

# Fonksiyonun çağrılması
urun_listele


