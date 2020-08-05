Start-Transcript -Path $env:TEMP\APEnroller.txt

#Sourcing functions from Functions-AutopilotValidation.ps1
Invoke-Expression(Invoke-WebRequest https://raw.githubusercontent.com/JaredSeavyHodge/APEnroller/CustomGetAutoPilotDevice_dotsource/Functions-AutopilotValidation.ps1 -UseBasicParsing)

<#Gives the option to delete any answer files found
$confirmation = Read-Host "Do you want to check for and delete any Answer Files found on this device.  If found the device will reboot and you will need to run this script again.  This may be required on Dell Home Edition Images. (Y/N) Default: N"
if ($confirmation -eq 'y') {
    Test-CheckForUnattendXML                                #Will Remove any answerfiles in the Sysprep and/or Panther folder
}
#>
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
$Group = Get-AzureADGroup -SearchString "ENDPOINT Devices" | Out-GridView -OutputMode Single


<#Confirm to continue
$confirmation = Read-Host "The device info will be uploaded, registered with Windows AutoPilot, and enrolled in AAD/MDM.  Continue? (Y/N) Default: Y"
if ($confirmation -eq 'n') {
    Stop-Transcript
    exit
}
#>

#Now that validations have completed, Micahel's script will be used to enroll the
#device into Windows Autopilot, Azure AD, and Intune MDM
#https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo
#Author of Get-WindowsAutoPilotInfo:  Michael Niehaus
#Install-Script -Name Get-WindowsAutoPilotInfo -Force
Invoke-Expression(Invoke-WebRequest https://raw.githubusercontent.com/JaredSeavyHodge/APEnroller/CustomGetAutoPilotDevice_dotsource/Get-WindowsAutoPilotInfo.ps1 -usebasicparsing)

Get-WindowsAutoPilotInfo -Online -Assign -AddToGroup ($Group.DisplayName)
Stop-Transcript
Write-Warning "Finished, press Enter to reboot"
Pause
shutdown /r /t 0
