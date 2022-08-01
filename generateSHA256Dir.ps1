<# Check https://byteforbyte.io/tools for more information#>

$dir = "C:\path\to\directory"
$alldata = @()
$files = Get-ChildItem -Path $dir* -Include *.* -Recurse | select target
foreach($file in $files){
  $data = get-filehash $file.Target
  $alldata+=$data
}
$date = get-date -f MM-dd-YYYY
$exportpath = $dir + "\" + $date + "_checksum.csv"
$alldata | export-csv $exportpath
