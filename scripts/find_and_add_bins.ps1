$found = @{}
$candidates = @( 'C:\Program Files\Graphviz\bin\dot.exe', 'C:\Program Files (x86)\Graphviz\bin\dot.exe', 'C:\Program Files\Graphviz2.38\bin\dot.exe', 'C:\Program Files\Graphviz2.38\bin\dot.exe', 'C:\Program Files\Pandoc\pandoc.exe', "C:\Users\$env:USERNAME\AppData\Local\Pandoc\pandoc.exe", "C:\Users\$env:USERNAME\AppData\Local\Programs\Pandoc\pandoc.exe", 'C:\Program Files\MiKTeX\miktex\bin\x64\xelatex.exe', 'C:\Program Files\MiKTeX\miktex\bin\xelatex.exe' )
foreach ($p in $candidates) { if (Test-Path $p) { $found[$p] = Split-Path $p -Parent } }
$texRoots = Get-ChildItem 'C:\texlive' -Directory -ErrorAction SilentlyContinue
foreach ($r in $texRoots) { $p = Join-Path $r.FullName 'bin\win32\xelatex.exe'; if (Test-Path $p) { $found[$p] = Split-Path $p -Parent } }
if ($found.Count -eq 0) { Write-Output 'No common-installation paths found.' } else { Write-Output 'Found executables:'; $found.GetEnumerator() | ForEach-Object { Write-Output ("{0} -> {1}" -f $_.Key, $_.Value) } }
$added = @()
foreach ($exe in $found.Keys) {
 $dir = $found[$exe]
 if (-not ($env:Path -split ';' | Where-Object { $_ -eq $dir })) {
   Write-Output ("Adding $dir to user PATH and current session")
   [Environment]::SetEnvironmentVariable('Path', $env:Path + ';' + $dir, 'User')
   $env:Path = $env:Path + ';' + $dir
   $added += $dir
 } else { Write-Output ("$dir already in PATH") }
}
if ($added.Count -gt 0) { Write-Output 'Added directories:'; $added | ForEach-Object { Write-Output $_ } }
Write-Output 'where.exe results after modifications (may reflect current session PATH):'
where.exe dot 2>$null; where.exe pandoc 2>$null; where.exe xelatex 2>$null
