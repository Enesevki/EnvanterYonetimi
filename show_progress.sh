show_progress() {
    (for i in {1..100}; do
        echo $i
        sleep 0.02
    done) | zenity --progress --title="Lütfen Bekleyiniz..." --text="İşlem sürüyor..." --auto-close
}

show_progress
