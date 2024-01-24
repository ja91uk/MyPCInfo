# PS-MyPCInfo v2.1 by Jake Averill
# Powershell script that opens a window with helpful information about the current machine and user
Write-Host "Gathering your PC information, please wait..."

# Get local info to write out
$os = Get-CimInstance Cim_OperatingSystem
$cpu = (Get-CimInstance Cim_Processor).Name
$BootTimeSpan = (New-TimeSpan -Start $os.LastBootUpTime -End (Get-Date))
$ip = (Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "127.*"}).IPAddress
$dom = $env:userdomain
$usr = $env:username
$flname = ([adsi]"WinNT://$dom/$usr,user").fullname
$osver = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\')
$cssbuild = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\CSS\')
$cs = Get-CimInstance Cim_ComputerSystem
$freespace = (Get-PSDrive C).Free

# Clear console to get rid of the please wait message before printing out the output to the user
Clear-Host

# Set layout of the info to be displayed
$o = ([ordered]@{
    "Client PC Name" = "$($os.CSName)"
    "CLient PC Domain" = $cs.Domain
    "IPv4 Address(es)" = $ip
    "User Name" = "$flname"
    "AD User Name" = $usr
    "AD User Domain" = $dom
    Make = $cs.Manufacturer
    Model = "$($cs.SystemFamily) $($cs.Model)"
    CPU = $cpu
    RAM = "$([math]::round($os.TotalVisibleMemorySize / 1MB))GB"
    "C Drive free" = "$([math]::round($freespace / 1GB,2))GB"
    OS = "$($os.Caption)"
    "OS Release" = $osver.DisplayVersion
    "OS Build" = "$($osver.CurrentBuild).$($osver.UBR)"
    "Build Version" = $cssbuild.BuildRevision
    Boot = $os.LastBootUpTime
    Uptime = "$($BootTimeSpan.Days) days, $($BootTimeSpan.Hours) hours, $($BootTimeSpan.Minutes) minutes"

})

# Output the info to the console
$o | Out-String | Write-Host

# Copy the output to the clipboard for the user to paste into a ticket or chat
$o | Out-String | Set-Clipboard

# Let the user know the info has been copied to the clipboard and wait for them to press enter to close the window
Read-Host -Prompt "This information has been copied to the clipboard. Press Enter to close"