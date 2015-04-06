# This script utilizes PowerCLI to launch a VMware Remote Console for a specified VM in your default browser.
#
# Requirements:
# PowerCLI: https://my.vmware.com/group/vmware/get-download?downloadGroup=PCLI600R1
# Custom Field 1: managing vCenter server name
# Connection name/URI must match the VM name in vCenter
# Connection context credentials will require vCenter permissions to view the VM console
#
# Royal TS Configuration:
# Right-click > Add > Command Task
# Display Name: PowerCLI: Launch VMRC
# Command: %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe
# Arguments: "& ""<PATH_SAVED>\Open-VMConsoleWindow_CLI_For_RoyalTS.ps1""" $URI$ $CustomField1$
# (Note that the mess of quotes above are correct and must be entered as shown)

if ($args.Length -ne 2) {
  Write-host "================================================="
  Write-Host "Usage: In RoyalTS"
  Write-Host -foregroundcolor Green "`tCreate a New Task"
  Write-Host -foregroundcolor Cyan "`tSet the following:"
  Write-Host -foregroundcolor Magenta "`t`tName: `t`t`tPowerCLI: Launch VMRC"
  Write-Host -foregroundcolor Yellow "`t`tCommand: `t`tC:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
  Write-Host -foregroundcolor Yellow "`t`tArguments: `t`t`"& `"`"<PATH_SAVED>\Open-VMConsoleWindow_CLI_For_RoyalTS.ps1`"`"`" `$URI`$ `$$CustomField1`$"
  Write-Host -foregroundcolor Yellow "`t`tWorking Directory: `tC:\Windows\System32\WindowsPowerShell\v1.0"
  Write-Host "Don't forget to check the box 'Show in favorite tasks menu'"
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