#!/bin/bash

# Ürün silme fonksiyonu
urun_sil() {
    # Kullanıcıdan silmek istediği ürünün adını al
    local urun_adi=$(zenity --entry --title="Ürün Sil" --text="Silmek istediğiniz ürünün adını girin:" --width=300)

    # Ürünün var olup olmadığını kontrol et
    local urun_satiri=$(grep -i "^.*,${urun_adi}," depo.csv)
    
    if [[ -z "$urun_satiri" ]]; then
        zenity --error --text="Bu isimde bir ürün bulunamadı." --width=300
        return 1
    fi

    # Ürünün numarasını, stok miktarını ve fiyatını al
    local urun_numarasi=$(echo $urun_satiri | cut -d ',' -f1)
    local urun_adi=$(echo $urun_satiri | cut -d ',' -f2)
    local urun_stok=$(echo $urun_satiri | cut -d ',' -f3)
    local urun_fiyat=$(echo $urun_satiri | cut -d ',' -f4)

    # Kullanıcıya silme onayı sor
    local onay_silme=$(zenity --question --title="Ürün Sil" --text="Emin misiniz? Bu işlem geri alınamaz.\n\nÜrün Adı: $urun_adi\nStok: $urun_stok\nFiyat: $urun_fiyat" --width=400)

    if [[ $? -eq 1 ]]; then
        zenity --info --text="Silme işlemi iptal edildi." --width=300
        return 1
    fi

    # Ürünü sil
    sed -i "/^$urun_numarasi,$urun_adi,/d" depo.csv

    # Başarı mesajı
    ./show_progress.sh
    zenity --info --text="Ürün başarıyla silindi!" --width=300
}



urun_sil

