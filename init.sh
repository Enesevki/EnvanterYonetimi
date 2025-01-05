#!/bin/bash


initialize_csv_files() {
    if [ ! -f "log.csv" ]; then
        echo "ID,Action,Timestamp" > log.csv
    fi
    if [ ! -f "depo.csv" ]; then
        echo "ProductID,ProductName,Quantity,Price" > depo.csv
    fi
    if [ ! -f "kullanicilar.csv" ]; then
        echo "Username,Password,Role,Locked" > kullanicilar.csv
        local admin_password_md5=$(echo -n "admin123" | md5sum | awk '{print $1}')
        echo "admin,$admin_password_md5,Yönetici,Hayır" >> kullanicilar.csv
    fi
}
initialize_csv_files
echo "Bash dosyaları için gerekli izinler ayarlanıyor..."
find . -type f -name "*.sh" -exec chmod +x {} \;

echo "İzinler başarıyla ayarlandı."


