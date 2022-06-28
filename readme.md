## Usage :

1) Download "connect-vpn-proxy.ps1" to your machine
2) Replace credentials
3) Execute script

## To execute with double click create a shortcut with the following target
powershell.exe -command "& 'C:\path to script\connect-vpn-proxy.ps1'"

Baldo's command to bypass powershell execution policy

powershell -noprofile -executionpolicy bypass -command "& 'C:\Data\cac-scripts-main\connect-vpn-proxy.ps1'"
