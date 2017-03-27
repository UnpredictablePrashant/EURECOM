echo '[+] Installing Git!'
sudo apt-get install git
echo '[+] Removing old files!'
rm -rf dump1090
echo '[+] Cloning the repository!'
git clone https://www.github.com/UnpredictablePrashant/dump1090.git
echo '[+] Exporting Environment Variable!'
export PKG_CONFIG_PATH=/opt/local/lib/pkgconfig
echo '[+] Installing the libraries!'
sudo apt-get install librtlsdr-dev
echo '[+] Making the File'
cd dump1090
make
cd ..
