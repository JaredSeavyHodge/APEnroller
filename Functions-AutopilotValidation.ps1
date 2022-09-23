Function Test-WindowsEditionforAutopilot {
    [cmdletbinding()]
    Param (
    )
    
    Process {
        $Edition = Get-WindowsEdition -online
        if ($Edition.Edition -eq "Core" -OR $Edition.Edition -eq "Home"){
            Write-Warning "The Windows edition must be upgraded to support AutoPilot. After the upgrade, the computer will reboot and you must run this script again."

            $Proc = Start-Process changepk.exe -ArgumentList "/ProductKey NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" -PassThru
            $Proc | Wait-Process -Timeout 90 -ErrorAction SilentlyContinue -errorvariable $TimedOut
            $Proc | Stop-Process
            
            if ($TimedOut){
                Write-Host "Edition upgrade Timed Out ... Reboot and try again?"
                Pause
                Shutdown /r /t 0
			}else{Write-Host "Finished without Timeout ... Reboot"; Pause; Shutdown /r /t 0}

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