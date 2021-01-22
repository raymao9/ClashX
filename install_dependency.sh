#!/bin/bash
set -eu
echo "Build Clash core"
cd ClashX/goClash
python3 build_clash.py
echo "Pod install"
cd ../..
pod install
echo "delete old files"
rm -f ./ClashX/Resources/Country.mmdb
rm -rf ./ClashX/Resources/dashboard
#rm -f GeoLite2-Country.*
echo "install mmdb"
#wget --no-check-certificate https://static.clash.to/GeoIP2/GeoIP2-Country.mmdb
#wget https://download.maxmind.com/app/geoip_download_by_token?edition_id=GeoLite2-Country&date=20210112&suffix=tar.gz&token=v2.local.r4kaeI8Y0iVYW0JIidJjPAdbNZHgJf0xM-0bBMb0B7ToypNzSMitHS6FHFKlk4NCs0uFe5arwMqyG5q0EcePW50QD4GCC34G1kWf8pGZlRj_JrNZfrQn_7pTpTyfoaDi_k2sypMRsfijGQLiZiX0PvOXYDs_uVwjHhwJ3xsf5Tv6L2TyH3jmf4fErFRHDtsXLGebsw
#tar xvf GeoLite2-Country_20210112.tar
mv GeoLite2-Country.mmdb ./ClashX/Resources/Country.mmdb
echo "install dashboard"
cd ClashX/Resources
git clone -b gh-pages https://github.com/Dreamacro/clash-dashboard.git dashboard
