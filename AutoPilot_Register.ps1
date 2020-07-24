#. .\Functions-AutopilotValidation.ps1
iex(iwr https://raw.githubusercontent.com/JaredSeavyHodge/APEnroller/master/Functions-AutopilotValidation.ps1)

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

Install-Script -Name Get-WindowsAutoPilotInfo -Force
Get-WindowsAutoPilotInfo.ps1 -Online -Assign -AddToGroup ($Group.DisplayName) -reboot
Write-Host "Rebooting?"
