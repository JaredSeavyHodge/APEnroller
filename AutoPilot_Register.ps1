Start-Transcript -Path $env:TEMP\APEnroller.txt

#Sourcing functions from Functions-AutopilotValidation.ps1
Invoke-Expression(Invoke-WebRequest https://raw.githubusercontent.com/JaredSeavyHodge/APEnroller/AddUserDrivenDeployment/Functions-AutopilotValidation.ps1 -UseBasicParsing)

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
#Using Script source to perform this: https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo
Install-Script -Name Get-WindowsAutoPilotInfo -Force 
$Shared = Read-Host "Will this be a shared, multi-user device? (Y/N) Default: Y"
if ($Shared -eq 'n'){   
    Get-WindowsAutoPilotInfo.ps1 -Online -Assign
    Stop-Transcript
    Read-Host "Finished, press Enter to reboot"
    Pause
    shutdown /r /t 0
}else {
    $Group = Get-AzureADGroup -SearchString "ENDPOINT Devices" | Out-GridView -OutputMode Single     
    Get-WindowsAutoPilotInfo.ps1 -Online -Assign -AddToGroup ($Group.DisplayName)
    Stop-Transcript
    Read-Host "Finished, press Enter to reboot"
    Pause
    shutdown /r /t 0
}

