Start-Transcript -Path $env:TEMP\APEnroller.txt

#Sourcing functions from Functions-AutopilotValidation.ps1
Invoke-Expression(Invoke-WebRequest https://raw.githubusercontent.com/JaredSeavyHodge/APEnroller/master/Functions-AutopilotValidation.ps1 -UseBasicParsing)
Test-WindowsEditionforAutopilot                             #Will Upgrade Home/Core Edition to Education to support Autopilot
Connect-Tennant                                             #Connects to Azure and MS-Graph - Imports Dependency Modules if Necessary

#Check for the device in Autopilot before attempting to add it as a new device.
$Result = Get-AutopilotDevice -serial ((Get-CimInstance -CimSession $(New-CimSession) -Class Win32_BIOS).SerialNumber)
if(-not $Result){
    Write-Output $Result
    Write-Host "This device is not currently registered in AutoPilot. Continue to register this device."
    Pause
}else {$DeviceResult; Write-Warning "STOP - This device is already registered in AutoPilot, you do not need to use this script.  Exiting..."; Stop-Transcript; pause; exit}

#Select Azure Group to Add This Device Too
$Group = Get-AzureADGroup -SearchString "ENDPOINT Devices" -All $true | Out-GridView -OutputMode Single

#Now that validations have completed, Micahel's script will be used to enroll the
#device into Windows Autopilot, Azure AD, and Intune MDM
#https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo
#Author of Get-WindowsAutoPilotInfo:  Michael Niehaus
#Install-Script -Name Get-WindowsAutoPilotInfo -Force
Invoke-Expression(Invoke-WebRequest https://raw.githubusercontent.com/JaredSeavyHodge/APEnroller/master/Get-WindowsAutoPilotInfo.ps1 -usebasicparsing)

Get-WindowsAutoPilotInfo -Online -Assign -AddToGroup ($Group.DisplayName)
Stop-Transcript
Start-Process "C:\windows\System32\Sysprep\sysprep.exe" -argumentlist "/oobe /reboot"

