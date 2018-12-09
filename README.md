# PowershellTip
一些常用的脚本。

## 1. 文件默认打开方式关联VSCODE
### 文件名称：  
```Change_default_programs.ps1```
### 描述：
至少在Windows10 （1803）中，即使设置文件默认打开方式也存在一些文件无法关联到指定的程序里，所以本脚本采用注册表操作，修复此问题。  
### 使用方式：
```
.\Powershell_reg.ps1 `
-extensioname "ps1" `
-vsico "C:\Program Files\Microsoft VS Code\resources\app\resources\win32\powershell.ico" `
-vspath '"C:\Program Files\Microsoft VS Code\Code.exe" "%1"'
```
### 参数列表
|名称|描述|示例|注意事项|
|:-:|:-:|:-:|:-:|
|extensioname|文件扩展名|css|不包含"."|
|vsico|文件图标|C:\\...\powershell.ico|推荐使用VSCode的自带图标|
|vspath|文件默认打开程序|"C:\\...\Code.exe" "%1"|**参数值里面是有（"）的！**|
### 已知问题
由于笔者对注册表了解不深，存在一些情况即使运行脚本，也有不生效的情况。出现此问题时，请检查
`` HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.css ``
### 注意事项
此脚本未经严格认证，会修改注册表，请慎重使用。