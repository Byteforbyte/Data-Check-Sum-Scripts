#Designed to copy a directory and its files and verify that the copy did not corrupt anything. Generates a csv in target directory.
#More info can be found at : https://byteforbyte.io/community
$dir = "C:\sourceDir\"
$targetdir = "C:\destinationDir\"
$alldata = @()
$files = Get-ChildItem -Path $dir -Filter *.* -Recurse -ErrorAction SilentlyContinue -Force | %{$_.FullName}

foreach($file in $files){
        $newtarfilepath = $file.replace($dir,$targetdir)
        Copy-Item $file -Destination $newtarfilepath
        $origdata = get-filehash $file
        $resultdata = get-filehash  $newtarfilepath
        $desthash = $resultdata.Hash
        $data = $origdata | select Algorithm, Hash, Path, @{Name="Destination Hash"; Expression={$resultdata.Hash}}, @{Name="Destination Path";Expression={$newtarfilepath}},  @{Name="Files Match";Expression={$desthash.Equals($origdata.Hash)}}
        $alldata+=$data
   
    }

$date = get-date -f MM-dd-yy
$exportpath = $targetdir + "\" + $date + "_copyResults.csv"
$alldata | export-csv $exportpath
