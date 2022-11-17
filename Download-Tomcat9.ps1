#requires -version 5

function Get-WebContent {
  param(
    [String]
    $url
  )
  (Invoke-WebRequest $url -UseBasicParsing |
    Select-Object -ExpandProperty Content) -split "`n"
}

function Get-DownloadURL {
  param(
    [String]
    $url
  )
  $webContent = Get-WebContent $url
  if ( $null -ne $webContent ) {
    $webContent | Select-String '<a href="([^"]+)"[^>]+>.+windows zip' | ForEach-Object {
      $_.Matches[0].Groups[1].Value
    }
  }
}

function Get-RemoteFileHash {
  param(
    [String]
    $url
  )
  Get-WebContent ("{0}.sha512" -f $url) | Select-String '^(\S+)' | ForEach-Object {
    $_.Matches[0].Groups[1].Value
  } | Select-Object -First 1
}

function Get-RemoteFile {
  param(
    [String]
    $url,

    [String]
    $localFileName,

    [String]
    $remoteHash
  )
  Write-Verbose "Download: $url" -Verbose
  Invoke-WebRequest $url -OutFile $localFileName
  if ( $? ) {
    if ( (Get-FileHash $localFileName -Algorithm SHA512).Hash -ne $remoteHash ) {
      Write-Warning "File hash mismatch after download: $localFileName"
    }
  }
}

$DownloadURLs = Get-DownloadURL "https://tomcat.apache.org/download-90.cgi"
foreach ( $DownloadURL in $DownloadURLs ) {
  $RemoteHash = Get-RemoteFileHash $DownloadURL
  if ( $null -ne $RemoteHash ) {
    $LocalFileName = Split-Path $DownloadURL -Leaf
    if ( -not (Test-Path $LocalFileName) ) {
      Get-RemoteFile $DownloadURL $LocalFileName $RemoteHash
    }
    else {
      if ( (Get-FileHash $LocalFileName -Algorithm SHA512).Hash -ne $RemoteHash ) {
        Write-Warning "File hash mismatch before download: $LocalFileName"
        Get-RemoteFile $DownloadURL $LocalFileName $RemoteHash
      }
    }
  }
  else {
    Write-Warning "Unable to get remote file hash: $DownloadURL"
  }
}
