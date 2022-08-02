#Check https://byteforbyte.io/tools for more information

scanpath='./test';
now='date +%m_%d_%Y';
results=();
for i in $(find ${scanpath});
   do result=$( echo $(sha256sum ${i} 2>/dev/null)); 
   results+=($(echo $result));
   done; 
output=$(echo $(echo ${scanpath})/$(${now})_checksum.csv)
printf '%s\n' "${results[@]}" > $output
