Function Test-WindowsEditionforAutopilot {
    [cmdletbinding()]

    Param (
    )
    
    Process {
        $Edition = Get-WindowsEdition -online
        if ($Edition.Edition -eq "Core" -OR $Edition.Edition -eq "Home"){
            Write-Warning "The Windows edition must be upgraded to support AutoPilot ... Upgrading Windows Edition"

            $Proc = Start-Process changepk.exe -ArgumentList "/ProductKey NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" -PassThru
            $Proc | Wait-Process -Timeout 60 -ErrorAction SilentlyContinue -errorvariable $TimedOut
            if ($TimedOut){
                $Proc | Kill 
                Write-Host "Edition upgrade Timed Out ... Rebooting"
                Pause
                Shutdown /r /t 0
			}else{Write-Host "Finished without Timeout ... Reboot"; Pause; Shutdown /r /t 0}

            #changepk.exe /ProductKey NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
            <#
            if (-not($Edition.Edition -eq "Core" -OR $Edition.Edition -eq "Home")){
                Write-Host "Ignore error associated with Edition Upgrade."
                Write-Host "Successfully upgraded to Windows Education Edition."
            }else{
                Write-Warning "Upgrade Winodws Edition from Home/Core has failed"
                $confirmation = Read-Host "Do you want to Generalize, Reboot, and try again? (Y/N) Default:Yes"
                if ($confirmation -eq 'n') {exit}else{"$env:systemroot\system32\sysprep\sysprep.exe /generalize /oobe /reboot"}
            }
            #>
        }else{Write-Host "Windows Edition: $($Edition.Edition) ... This Edition is supported by Windows AutoPilot"}
    }        
}

Function Connect-Tennant {
    [cmdletbinding()]
    Param (
    )
    Process{
        $module = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
        if (-not $module) {
            Write-Host "Installing module WindowsAutopilotIntune"
            Install-Module WindowsAutopilotIntune -Force
        }
        Import-Module WindowsAutopilotIntune -Scope Global
        $graph = Connect-MSGraph 
        Connect-AzureAD -AccountId $graph.UPN
    }
}

Function Get-DeviceSerial {
    [cmdletbinding()]
    [OutputType([psobject])]
    Param (
    )
    # End of Parameters
    Process {
        $Serial = (Get-CimInstance -CimSession $(New-CimSession) -Class Win32_BIOS).SerialNumber
        $Serial
    }
}

Function Test-AutopilotForExistingDevice {
    [cmdletbinding()]
    [OutputType([psobject])]

    Param (
        [psobject]$DeviceToCheck
    )
    
    Process {
        $DeviceResult = Get-AutopilotDevice -serial ($DeviceToCheck).SerialNumber
        if($DeviceResult -eq $null){
            Write-Host "This device is not currently registered in AutoPilot."
        }else {$DeviceResult; Write-Warning "STOP - This device is already registered in AutoPilot, Exiting Now"; pause; exit}
    }        
}

Function Test-CheckForUnattendXML {
    [cmdletbinding()]

    Param (
    )
    
    Process {
        $Unattend = "c:\windows\system32\sysprep\unattend.xml","c:\windows\panther\unattend.xml"
        $Sysprep = $false
        foreach ($i in $Unattend){
            if (Test-Path $i -PathType leaf){
                Write-Host "Deleting file $i"
                Remove-Item $i
                $Sysprep = $true
            }else{Write-Host "Unattend file at $i not found"}
        }
        if ($Sysprep){Start-Process "$env:systemroot\system32\Shutdown.exe" -ArgumentList "/r /f /t 0"<#Start-Process "$env:systemroot\system32\sysprep\sysprep.exe" -ArgumentList "/generalize /oobe /reboot" -wait#>}
    }        
}

