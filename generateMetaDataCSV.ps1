 <# Used for archiving systems. Information can be found @ https://byteforbyte.io/forum/t/collect-metadata-of-files-in-a-directory-and-generate-a-csv-powershell-tutorial/5/ #>

$dirpath = 'G:\dirtoscan'


function Get-FileMetaData {
        <#
        Original function  made by 
        https://evotec.xyz/getting-file-metadata-with-powershell-similar-to-what-windows-explorer-provides/
        #>
        [CmdletBinding()]
        param (
            [Parameter(Position = 0, ValueFromPipeline)][Object] $File,
            [switch] $Signature
        )
        Process {
            foreach ($F in $File) {
                $MetaDataObject = [ordered] @{}
                if ($F -is [string]) {
                    $FileInformation = Get-ItemProperty -Path $F
                } elseif ($F -is [System.IO.DirectoryInfo]) {
                    #Write-Warning "Get-FileMetaData - Directories are not supported. Skipping $F."
                    continue
                } elseif ($F -is [System.IO.FileInfo]) {
                    $FileInformation = $F
                } else {
                    Write-Warning "Get-FileMetaData - Only files are supported. Skipping $F."
                    continue
                }
                $ShellApplication = New-Object -ComObject Shell.Application
                $ShellFolder = $ShellApplication.Namespace($FileInformation.Directory.FullName)
                $ShellFile = $ShellFolder.ParseName($FileInformation.Name)
                $MetaDataProperties = [ordered] @{}
                0..400 | ForEach-Object -Process {
                    $DataValue = $ShellFolder.GetDetailsOf($null, $_)
                    $PropertyValue = (Get-Culture).TextInfo.ToTitleCase($DataValue.Trim()).Replace(' ', '')
                    if ($PropertyValue -ne '') {
                        $MetaDataProperties["$_"] = $PropertyValue
                    }
                }
                foreach ($Key in $MetaDataProperties.Keys) {
                    $Property = $MetaDataProperties[$Key]
                    $Value = $ShellFolder.GetDetailsOf($ShellFile, [int] $Key)
                    if ($Property -in 'Attributes', 'Folder', 'Type', 'SpaceFree', 'TotalSize', 'SpaceUsed') {
                        continue
                    }
                    If (($null -ne $Value) -and ($Value -ne '')) {
                        $MetaDataObject["$Property"] = $Value
                    }
                }
                if ($FileInformation.VersionInfo) {
                    $SplitInfo = ([string] $FileInformation.VersionInfo).Split([char]13)
                    foreach ($Item in $SplitInfo) {
                        $Property = $Item.Split(":").Trim()
                        if ($Property[0] -and $Property[1] -ne '') {
                            $MetaDataObject["$($Property[0])"] = $Property[1]
                        }
                    }
                }
                $MetaDataObject["Attributes"] = $FileInformation.Attributes
                $MetaDataObject['IsReadOnly'] = $FileInformation.IsReadOnly
                $MetaDataObject['IsHidden'] = $FileInformation.Attributes -like '*Hidden*'
                $MetaDataObject['IsSystem'] = $FileInformation.Attributes -like '*System*'
                if ($Signature) {
                    $DigitalSignature = Get-AuthenticodeSignature -FilePath $FileInformation.Fullname
                    $MetaDataObject['SignatureCertificateSubject'] = $DigitalSignature.SignerCertificate.Subject
                    $MetaDataObject['SignatureCertificateIssuer'] = $DigitalSignature.SignerCertificate.Issuer
                    $MetaDataObject['SignatureCertificateSerialNumber'] = $DigitalSignature.SignerCertificate.SerialNumber
                    $MetaDataObject['SignatureCertificateNotBefore'] = $DigitalSignature.SignerCertificate.NotBefore
                    $MetaDataObject['SignatureCertificateNotAfter'] = $DigitalSignature.SignerCertificate.NotAfter
                    $MetaDataObject['SignatureCertificateThumbprint'] = $DigitalSignature.SignerCertificate.Thumbprint
                    $MetaDataObject['SignatureStatus'] = $DigitalSignature.Status
                    $MetaDataObject['IsOSBinary'] = $DigitalSignature.IsOSBinary
                }
                [PSCustomObject] $MetaDataObject
            }
        }
}


$a = @()
$files = Get-ChildItem $dirpath -Recurse | Where {! $_.PSIsContainer }

foreach($file in $files){
    $a += $file | Get-FileMetaData -Signature
}

$date = get-date -f MM-dd-yy
$savepath = $dirpath + "\" + $date + "_metadata.csv"

$a | export-csv $savepath
