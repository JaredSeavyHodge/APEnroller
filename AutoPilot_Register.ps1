Start-Transcript -Path $env:TEMP\APEnroller.txt

#Sourcing functions from Functions-AutopilotValidation.ps1
Invoke-Expression(Invoke-WebRequest https://raw.githubusercontent.com/JaredSeavyHodge/APEnroller/master/Functions-AutopilotValidation.ps1 -UseBasicParsing)

#Gives the option to delete any answer files found
$confirmation = Read-Host "Do you want to check for and delete any Answer Files found on this device.  If found the device will reboot and you will need to run this script again.  This may be required on Dell Home Edition Images. (Y/N) Default: N"
if ($confirmation -eq 'y') {
    Test-CheckForUnattendXML                                #Will Remove any answerfiles in the Sysprep and/or Panther folder
}

Test-WindowsEditionforAutopilot                             #Will Upgrade Home/Core Edition to Education to support Autopilot
Connect-Tennant                                             #Connects to Azure and MS-Graph - Imports Dependency Modules if Necessary


#Check for the device in Autopilot before attempting to add it as a new device.
$Result = Get-AutopilotDevice -serial ((Get-CimInstance -CimSession $(New-CimSession) -Class Win32_BIOS).SerialNumber)
if(-not $Result){
    Write-Output $Result
    Write-Host "This device is not currently registered in AutoPilot. Continue to register this device."
    Pause
}else {$DeviceResult; Write-Warning "STOP - This device is already registered in AutoPilot, you do not need to use this script.  Exiting..."; Stop-Transcript; pause; exit}

#If shared device, Select Azure Group for self deployment profile
#Else, add to user driven autopilot profile dynamically
#Using Script source: https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo
$Shared = Read-Host "Will this be a shared, multi-user device? (Y/N) Default: Y"
if ($Shared -eq 'n'){
    Install-Script -Name Get-WindowsAutoPilotInfo -Force    
    Get-WindowsAutoPilotInfo.ps1 -Online -Assign
    Stop-Transcript
    Read-Host "Finished, press Enter to reboot"
    Pause
    shutdown /r /t 0
}else {
    $Group = Get-AzureADGroup -SearchString "ENDPOINT Devices" | Out-GridView -OutputMode Single
    Install-Script -Name Get-WindowsAutoPilotInfo -Force        
    Get-WindowsAutoPilotInfo.ps1 -Online -Assign -AddToGroup ($Group.DisplayName)
    Stop-Transcript
    Read-Host "Finished, press Enter to reboot"
    Pause
    shutdown /r /t 0
}

