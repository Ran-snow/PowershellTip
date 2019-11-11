Get-ChildItem '.' SN.* -Recurse | Rename-Item -NewName { $_.Name -replace 'SN.','CP.' }
