adb disconnect
adb tcpip 5555

echo -n "Entrez la fin de l'adresse IP (ex: 100) : "
read ip_end

adb connect 192.168.11.$ip_end:5555


