#requires -version 2

# requires 7z.exe
$programFilesPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)
$sevenZip = Join-Path (Join-Path $programFilesPath "7-Zip") "7z.exe"
if ( -not (Test-Path $sevenZip) ) {
  throw "Can't find '$sevenZip'."
}

# Get names of zip files (don't rename files downloaded from tomcat.apache.org)
$archives = Get-ChildItem "apache-tomcat-*-windows-x*.zip" -ErrorAction Stop | Select-Object -ExpandProperty FullName

# Need an array if there's only 1 file
if ( ($archives | Measure-Object).Count -eq 1 ) {
  $archives = @($archives)
}

# each zip file contains a root directory whose name matches the start of the zip file's name
$rootDirName = [Regex]::Match((Split-Path $archives[0] -Leaf),'(apache-tomcat-([\d\.])+)').Groups[1].Value

if ( Test-Path $rootDirName ) {
  throw "Extraction path already exists."
}

# extract the zip files (skip existing files) except for some files
foreach ( $archive in $archives ) {
  & $sevenZip "x" "-aos" "-xr0!*.dll" "-xr0!*.exe" "-xr0!*.sh" "-xr!safeToDelete.tmp" $archive
}

# extract Windows binaries (*.dll and *.exe) and rename to .x64 or .x86 depending on platform
foreach ( $archive in $archives ) {
  & $sevenZip "x" "-ir0!*.dll" "-ir0!*.exe" $archive
  $platform = [Regex]::Match($archive,'-(x\d{2})\.zip$').Groups[1].Value
  $binDir = Join-Path $rootDirName "bin"
  $binaries = Get-ChildItem (Join-Path $binDir "*") -Include "*.dll","*.exe"
  foreach ( $binary in $binaries ) {
    $newName = "{0}.{1}" -f $binary.Name,$platform
    Rename-Item $binary.FullName $newName
  }
}
