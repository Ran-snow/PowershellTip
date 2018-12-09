param($extensioname, $vsico, $vspath)

function RemoveItem {
    param (
        $item
    )

    if (Test-Path $item) {
        Write-Host "����ɾ��"$item
        Remove-Item $item -Recurse
    }
}

if (!$extensioname -or !$vsico -or !$vspath) {
    throw "����������"
    Pause
}

$fullExtension = -Join (".", $extensioname)
$key = "vscode_" + $extensioname
$fullExtensionPath = Join-Path -Path HKLM:\SOFTWARE\Classes -ChildPath $fullExtension
$keyPath = Join-Path -Path HKLM:\SOFTWARE\Classes -ChildPath $key

RemoveItem -item $fullExtensionPath
RemoveItem -item $keyPath

# �½�.css HKLM:\SOFTWARE\Classes\.css
New-Item -ErrorAction Stop -itemType String $fullExtensionPath -value $key

# �½�vscode_css HKLM:\SOFTWARE\Classes\vscode_css
New-Item -ErrorAction Stop -itemType String $keyPath

# �½�vscode_css����DefaultIcon HKLM:\SOFTWARE\Classes\vscode_css\DefaultIcon
$iconPath = Join-Path -Path $keyPath -ChildPath "DefaultIcon"
New-Item -ErrorAction Stop -itemType String $iconPath -Value  $vsico # "C:\Program Files\Microsoft VS Code\resources\app\resources\win32\css.ico"

# �½�vscode_css����shell HKLM:\SOFTWARE\Classes\vscode_css\shell
$shellPath = Join-Path -Path $keyPath -ChildPath "shell"
New-Item -ErrorAction Stop -itemType String $shellPath

# �½�shell����open HKLM:\SOFTWARE\Classes\vscode_css\open
$openPath = Join-Path -Path $shellPath -ChildPath "open"
New-Item -ErrorAction Stop -itemType String $openPath

# �½�open����command HKLM:\SOFTWARE\Classes\vscode_css\open\command
$cmdPath = Join-Path -Path $openPath -ChildPath "command"
New-Item -ErrorAction Stop -itemType String $cmdPath -Value $vspath # '"C:\Program Files\Microsoft VS Code\Code.exe" "%1"'

# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.css
# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.css\OpenWithList
# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.css\OpenWithProgids
# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.css\UserChoice

Stop-process -name explorer -force

# https://blog.csdn.net/a302549450/article/details/84308175
# .\Change_default_programs.ps1 -extensioname "ps1" -vsico "C:\Program Files\Microsoft VS Code\resources\app\resources\win32\powershell.ico" -vspath '"C:\Program Files\Microsoft VS Code\Code.exe" "%1"'