echo '[+] Running ADSB!'
cd dump1090
./dump1090 --enable-agc --aggressive --net-http-port 8080 && firefox 127.0.0.1:8080

