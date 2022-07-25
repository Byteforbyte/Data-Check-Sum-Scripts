scanpath='/var';
now='date +"%m_%d_%Y"';
sha256sum ${scanpath}/* 2>/dev/null > ${scanpath}/${now}_checksum.csv;
