# Modified starting from https://gist.github.com/jhorsman/88321511ce4f416c0605
# Usage: & '.\Cisco_Anyconnect.ps1' [-Server <server name or ip>] [-Group <group>] [-User <user>] [-Proxyscript <ps>] [-Password <password>]

param (
    [string]$Server = $( Read-Host "Input server, please" ),
    [string]$Group = $( Read-Host "Input group, please" ),
    [string]$User = $( Read-Host "Input username, please" ),
    [string]$Password = $( Read-Host -assecurestring "Input password, please" ),
    [string]$ProxyScript = $( Read-Host "Input proxy script, please" )
)

[string]$vpncliAbsolutePath = 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe'
[string]$vpnuiAbsolutePath = 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe'

Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop

Add-Type @'
  using System;
  using System.Runtime.InteropServices;
  public class Win {
     [DllImport("user32.dll")]
     [return: MarshalAs(UnmanagedType.Bool)]
     public static extern bool SetForegroundWindow(IntPtr hWnd);
  }
'@ -ErrorAction Stop

Function VPNConnect() {
    Start-Process -WindowStyle Minimized -FilePath $vpncliAbsolutePath -ArgumentList "connect $Server"
    $counter = 0; $h = 0;
    while ($counter++ -lt 1000 -and $h -eq 0) {
        sleep -m 10
        $h = (Get-Process vpncli).MainWindowHandle
    }
    if ($h -eq 0) { echo "Could not start VPNUI it takes too long." }
    else { [void] [Win]::SetForegroundWindow($h) }
}

Get-Process | ForEach-Object { if ($_.ProcessName.ToLower() -eq "vpnui")
    { $Id = $_.Id; Stop-Process $Id; echo "Process vpnui with id: $Id was stopped" } }
Get-Process | ForEach-Object { if ($_.ProcessName.ToLower() -eq "vpncli")
    { $Id = $_.Id; Stop-Process $Id; echo "Process vpncli with id: $Id was stopped" } }


echo "Trying to terminate remaining vpn connections"
Start-Process -WindowStyle Minimized -FilePath $vpncliAbsolutePath -ArgumentList 'disconnect' -wait
echo "Connecting to VPN address '$Server' as user '$User'."
VPNConnect

[System.Windows.Forms.SendKeys]::SendWait("$Group{Enter}")
[System.Windows.Forms.SendKeys]::SendWait("$User{Enter}")
[System.Windows.Forms.SendKeys]::SendWait("$Password{Enter}")

Start-Process -WindowStyle Minimized -FilePath $vpnuiAbsolutePath

Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -name AutoConfigURL -Value $ProxyScript
