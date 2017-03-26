# This is bash script for the dump1090
git clone https://www.github.com/UnpredictablePrashant/dump1090.git
sudo apt-get install librtlsdr
cd dump1090
make
./dump1090 --enable-agc --aggressive --net-http-port 8080
