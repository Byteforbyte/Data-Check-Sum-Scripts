#More info can be found @ https://byteforbyte.io/tools

$dir = "c:\path\to\scan"
$alldata = @()
$files = Get-ChildItem -Path $dir -Filter *.* -Recurse -ErrorAction SilentlyContinue -Force | %{$_.FullName}

foreach($file in $files){
        $data = get-filehash $file
        $alldata+=$data
    }

$date = get-date -f MM-dd-yy
$exportpath = $dir + "\" + $date + "_checksum.csv"
$alldata | export-csv $exportpath
