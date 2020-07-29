#Sourcing functions from Functions-AutopilotValidation.ps1
iex(iwr https://raw.githubusercontent.com/JaredSeavyHodge/APEnroller/Check_Unattend/Functions-AutopilotValidation.ps1 -UseBasicParsing)

#$AADCredentials = Get-Credential

$confirmation = Read-Host "Do you want to check for and delete any Answer Files found on this device.  If found the device will reboot and you will need to run this script again.  This may be required on Dell Home Edition Images. (Y/N) Default: N"
if ($confirmation -eq 'y') {
    Test-CheckForUnattendXML                                    #Will Remove any answerfiles in the Sysprep and/or Panther folder
}

Write-Host "Press Enter to continue to Test-WindowsEditionforAutoPilot"
Pause

Test-WindowsEditionforAutopilot                             #Will Upgrade Home/Core Edition to Education to Support Autopilot
$Serial = Get-DeviceSerial                                  #Creates CimSession and Returns Device serial
Connect-Tennant                                             #Connects to Azure and MS-Graph - Imports Dependency Modules if Necessary
Test-AutopilotForExistingDevice -DeviceToCheck $Serial      #Check for Device Existence in Autopilot to Avoid Bug Behavior

#Out-Grid for User to Select Azure Group to Add This Device Too
$Group = Get-AzureADGroup -SearchString "ENDPOINT Devices" | Out-GridView -OutputMode Single
$confirmation = Read-Host "The device info will be uploaded, registered with Windows AutoPilot, and enrolled in AAD/MDM.  Continue? (Y/N) Default: Y"
if ($confirmation -eq 'n') {
    exit
}

#Now that validations have completed, Micahel's script will be used to enroll the
#device into Windows Autopilot, Azure AD, and Intune MDM
#https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo
#Author of Get-WindowsAutoPilotInfo:  Michael Niehaus
Install-Script -Name Get-WindowsAutoPilotInfo -Force
Get-WindowsAutoPilotInfo.ps1 -Online -Assign -AddToGroup ($Group.DisplayName) -reboot
Write-Host "Rebooting?"
