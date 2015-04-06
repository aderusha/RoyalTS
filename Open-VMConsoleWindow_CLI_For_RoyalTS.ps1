if ($args.Length -ne 2) {
  Write-host "================================================="
  Write-Host "Usage: In RoyalTS"
  Write-Host -foregroundcolor Green "`tCreate a New Task"
  Write-Host -foregroundcolor Cyan "`tSet the following:"
  Write-Host -foregroundcolor Magenta "`t`tName: `t`t`tPowerCLI: Launch VMRC"
  Write-Host -foregroundcolor Yellow "`t`tCommand: `t`tC:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
  Write-Host -foregroundcolor Yellow "`t`tArguments: `t`t`"& `"`"<PATH_SAVED>\Open-VMConsoleWindow_CLI_For_RoyalTS.ps1`"`"`" `$URI`$ `$$CustomField1`$"
  Write-Host -foregroundcolor Yellow "`t`tWorking Directory: `tC:\Windows\System32\WindowsPowerShell\v1.0"
  Write-Host "Don't forget to check the box 'Show in Favorites'"
  Write-host "================================================="
  return
}
$strComputer = $args[0]
$strVCenter = $args[1]

$strSnapin="VMware.VimAutomation.Core"
if (Get-PSSnapin $strSnapin -ErrorAction "SilentlyContinue") {
  #Write-Host "PSsnapin $snapin is loaded"
}
elseif (Get-PSSnapin $strSnapin -registered -ErrorAction "SilentlyContinue") {
  #Write-Host "PSsnapin $snapin is registered but not loaded"
  Add-PSSnapin $strSnapin
}
else {
  throw "Required PSSnapin $snapin not found"
}
Connect-VIServer $strVCenter

Get-VM $strComputer | Open-VMConsoleWindow