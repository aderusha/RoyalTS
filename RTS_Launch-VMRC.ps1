<#  
.SYNOPSIS 
  Launch a VMware Remote Console for a named VM
.DESCRIPTION
  The script will launch the VMware Remote Console for a named VM

  This script requires the following tools from VMware to be installed locally:
  PowerCLI: https://www.vmware.com/support/developer/PowerCLI/
  VMRC: https://www.vmware.com/support/developer/vmrc/

  When used with Royal TS this will require that Custom Field 1 is populated
  with the controlling vSphere server for the selected VM.  The URI must match
  the VM object name as it appears in vSphere.
  
  To run this script from within Royal TS, complete the following steps to add
  the script as a Command Task:
  
  Right-click > Add > Command Task
    Command Task Tab
	  Display Name: Launch VMRC
	  Optionally Check "Show in favorite task menu" and "No confirmation required"
    Command tab
	  Command: %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe
      Arguments: "& ""<SCRIPT PATH>\RTS_Launch-VMRC.ps1""" -Name $URI$ -Server $CustomField1$ -Username $EffectiveUsername$ -Password $EffectivePassword$
      (Note that the mess of quotes above are correct and must be entered as
	  shown with the entire command on one line)
	Credentials tab
	  Select "Use the Context Credentials"
	  Uncheck "Run task in user context of credential"
	  Uncheck "Load user profile"
  
.COMPONENT
  This script requires the following tools from VMware to be installed on the local system
  PowerCLI: https://www.vmware.com/support/developer/PowerCLI/
  VMRC: https://www.vmware.com/support/developer/vmrc/
   
.PARAMETER Name
  Specify the name of the virtual machine
.PARAMETER Server
  Specify the vSphere server to connect to
.PARAMETER Username
  Specify the user name you want to use for authenticating with the server.
.PARAMETER Password
  Specify the password you want to use for authenticating with the server.
.EXAMPLE
  PS> RTS_Launch-VMRC.ps1 -Name guest1 -Server vcenter2 -username administrator -password password
.NOTES
  Author: Allen Derusha
#>

Param(
  [Parameter(Mandatory=$True,HelpMessage="Virtual Machine name")][String]$Name,
  [Parameter(Mandatory=$True,HelpMessage="vSphere server name")][String]$Server,
  [Parameter(HelpMessage="vSphere user name")][String][String]$Username,
  [Parameter(HelpMessage="vSphere user password")][String][String]$Password
)

# if a Username is provided, check to make sure the password is provided to
if ($Username -and ! $Password) {
  throw "ERROR: Username provided without password"
}

# If we have both a username and a password, create a credential object
if ($Username -and $Password) {
  $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
  $vSphereCreds = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
}

# Check to see if we can find VMRC.exe and tell the user where to download it if we can't find it
if (Test-Path "${env:ProgramFiles(x86)}\VMware\VMware Remote Console\vmrc.exe") {
  $VMRCpath = "${env:ProgramFiles(x86)}\VMware\VMware Remote Console\vmrc.exe"
}
elseif (Test-Path "$env:ProgramFiles\VMware\VMware Remote Console\vmrc.exe") {
  $VMRCpath = "$env:ProgramFiles\VMware\VMware Remote Console\vmrc.exe"
}
else {
  throw "Could not find VMRC.exe.  Download and install the VMRC package from VMware at https://www.vmware.com/support/developer/vmrc/"
}

# Check to see if we have PowerCLI loaded, load it if not, and if that fails tell the user where to download it
$Snapin="VMware.VimAutomation.Core"
if (Get-PSSnapin $Snapin -ErrorAction "SilentlyContinue") {
  #Write-Host "PSsnapin $snapin is loaded"
}
elseif (Get-PSSnapin $Snapin -registered -ErrorAction "SilentlyContinue") {
  #Write-Host "PSsnapin $snapin is registered but not loaded"
  Add-PSSnapin $Snapin
}
else {
  throw "VMware PowerCLI not found.  Download and install the PowerCLI package from VMware at https://www.vmware.com/support/developer/PowerCLI/"
}

# Connect to the provided vCenter server with user provided creds if provided or with session creds if not
if ($vSphereCreds) {
  try {
    Connect-VIServer -Server $Server -Credential $vSphereCreds -ErrorAction Stop
  }
  catch {
    throw "ERROR: failed to authenticate to vSphere server $Server as user $Username"
  }
}
else {
  try {
    Connect-VIServer -Server $Server -ErrorAction Stop
  }
  catch {
    throw "ERROR: failed to authenticate to vSphere server $Server"
  }
}

# Get the MoRef for the provided VM, fail if we can't find it
$VMobject = Get-VM $Name
$VMmoref = $VMobject.extensiondata.moref.value
if (! $VMmoref) {
  throw "ERROR: Failed to find VM object $Name"
}

# Get a Clone Ticket for opening a remote console
$Session = Get-View -Id Sessionmanager
$Ticket = $Session.AcquireCloneTicket()
if (! $Ticket) {
  throw "ERROR: Failed to acquire session ticket"
}

# Launch VMRC
Start-Process -FilePath $VMRCpath -ArgumentList "vmrc://clone:$Ticket@$Server/?moid=$VMmoref"