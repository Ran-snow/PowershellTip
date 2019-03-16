# https://stackoverflow.com/questions/1674119/what-key-in-windows-registry-disables-ie-connection-parameter-automatically-det/1674377#1674377
function Set-ProxySettings {
    [CmdletBinding()]
    param ( 
        #could improve with parameter sets 
        [Parameter(Mandatory = $false)]
        [bool]$AutomaticDetect = $true
        ,
        [Parameter(Mandatory = $false)]
        [bool]$UseProxyForLAN = $false
        ,
        [Parameter(Mandatory = $false)]
        [AllowNull()][AllowEmptyString()]
        [string]$ProxyAddress = $null
        ,
        [AllowNull()][AllowEmptyString()]
        [bool]$UseAutomaticConfigurationScript = $false
    )
    begin {
        [string]$ProxyRegRoot = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
        [string]$DefaultConnectionSettingsPath = (Join-Path $ProxyRegRoot 'Connections')
        [byte]$MaskProxyEnabled = 2
        [byte]$MaskUseAutomaticConfigurationScript = 4
        [byte]$MaskAutomaticDetect = 8
        [int]$ProxyConnectionSettingIndex = 8
    }
    process {
        #this setting is affected by multiple options, so fetch once here 
        [byte[]]$DefaultConnectionSettings = Get-ItemProperty -Path $DefaultConnectionSettingsPath -Name 'DefaultConnectionSettings' | Select-Object -ExpandProperty 'DefaultConnectionSettings'

        #region auto detect
        if ($AutomaticDetect) { 
            Set-ItemProperty -Path $ProxyRegRoot -Name AutoDetect -Value 1
            $DefaultConnectionSettings[$ProxyConnectionSettingIndex] = $DefaultConnectionSettings[$ProxyConnectionSettingIndex] -bor $MaskAutomaticDetect
        }
        else {
            Set-ItemProperty -Path $ProxyRegRoot -Name AutoDetect -Value 0
            $DefaultConnectionSettings[$ProxyConnectionSettingIndex] = $DefaultConnectionSettings[$ProxyConnectionSettingIndex] -band (-bnot $MaskAutomaticDetect)
        }
        #endregion

        #region defined proxy
        if ($UseProxyForLAN) {
            if (-not ([string]::IsNullOrWhiteSpace($ProxyAddress))) {
                Set-ItemProperty -Path $ProxyRegRoot -Name ProxyServer -Value ("socks={0}" -f $ProxyAddress)
            }
            Set-ItemProperty -Path $ProxyRegRoot -Name ProxyEnable -Value 1
            $DefaultConnectionSettings[$ProxyConnectionSettingIndex] = $DefaultConnectionSettings[$ProxyConnectionSettingIndex] -bor $MaskProxyEnabled
        }
        else {
            Set-ItemProperty -Path $ProxyRegRoot -Name ProxyEnable -Value 0        
            $DefaultConnectionSettings[$ProxyConnectionSettingIndex] = $DefaultConnectionSettings[$ProxyConnectionSettingIndex] -band (-bnot $MaskProxyEnabled)
        }
        #endregion

        #region config script
        if ($UseAutomaticConfigurationScript) {
            $DefaultConnectionSettings[$ProxyConnectionSettingIndex] = $DefaultConnectionSettings[$ProxyConnectionSettingIndex] -bor $MaskUseAutomaticConfigurationScript
        }
        else {
            $DefaultConnectionSettings[$ProxyConnectionSettingIndex] = $DefaultConnectionSettings[$ProxyConnectionSettingIndex] -band (-bnot $MaskUseAutomaticConfigurationScript )
        }
        #endregion

        #persist the updates made above
        Set-ItemProperty -Path $DefaultConnectionSettingsPath -Name 'DefaultConnectionSettings' -Value $DefaultConnectionSettings
    }
}

Write-Host "Start work"

$enableProxy = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable

if ($enableProxy.ProxyEnable -eq "1") {
    Write-Host "IE代理已禁用。"
    Set-ProxySettings -UseProxyForLAN $false -AutomaticDetect $false -UseAutomaticConfigurationScript $false
}
else {
    Write-Host "IE代理已启用"
    Set-ProxySettings -UseProxyForLAN $true -AutomaticDetect $false -ProxyAddress "127.0.0.1:1080" -UseAutomaticConfigurationScript $false
}

Write-Host "End."