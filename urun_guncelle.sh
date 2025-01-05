#!/bin/bash

# Ürün güncelleme fonksiyonu
urun_guncelle() {
    # Kullanıcıdan güncellemek istediği ürünün adını al
    local urun_adi=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürünün adını girin:" --width=300)

    # Ürünün var olup olmadığını kontrol et
    local urun_satiri=$(grep -i "^.*,${urun_adi}," depo.csv)
    
    if [[ -z "$urun_satiri" ]]; then
        zenity --error --text="Bu isimde bir ürün bulunamadı." --width=300
        return 1
    fi

    # Ürünün numarasını, stok miktarını ve fiyatını al
    local urun_numarasi=$(echo $urun_satiri | cut -d ',' -f1)
    local eski_urun_adi=$(echo $urun_satiri | cut -d ',' -f2)
    local eski_stok_miktari=$(echo $urun_satiri | cut -d ',' -f3)
    local eski_birim_fiyat=$(echo $urun_satiri | cut -d ',' -f4)

    # Kullanıcıya yeni stok miktarını ve fiyatı sor
    local yeni_stok_miktari=$(zenity --entry --title="Ürün Güncelle" --text="Eski stok miktarı: $eski_stok_miktari\nYeni stok miktarını girin:" --width=300)
    local yeni_birim_fiyat=$(zenity --entry --title="Ürün Güncelle" --text="Eski birim fiyatı: $eski_birim_fiyat\nYeni birim fiyatını girin:" --width=300)

    # Veri doğrulama
    if ! [[ "$yeni_stok_miktari" =~ ^[0-9]+$ ]] || ! [[ "$yeni_birim_fiyat" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        zenity --error --text="Stok miktarı ve birim fiyatı pozitif sayılar olmalıdır!" --width=300
        return 1
    fi

    # Ürünü güncelle
    # Dosyadaki eski satırı yeni bilgilerle değiştir
    sed -i "s/^$urun_numarasi,$eski_urun_adi,$eski_stok_miktari,$eski_birim_fiyat$/$urun_numarasi,$eski_urun_adi,$yeni_stok_miktari,$yeni_birim_fiyat/" depo.csv

    # Başarı mesajı
    ./show_progress.sh
    zenity --info --text="Ürün başarıyla güncellendi!" --width=300
}

validate_product_name() {
    local name=$1
    if [[ "$name" =~ \  ]]; then
        echo "Product name cannot contain spaces."
        return 1
    fi
}

# Fonksiyonu çağır
urun_guncelle

