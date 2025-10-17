 <#
  Install-Poppler.ps1
  PURPOSE : Attempt a winget install of Poppler and re-probe
  USAGE   : .\Install-Poppler.ps1 [-Quiet]
 #>
 [CmdletBinding()]param([switch]$Quiet)
 $ErrorActionPreference = 'Stop'
 function Msg($t,$c='Gray'){ if(-not $Quiet){ Write-Host $t-ForegroundColor
 $c } }
 # Try winget package (community): oschwartz10612.Poppler
 $wing = Get-Command winget-ErrorAction SilentlyContinue
 if(-not $wing){ Msg "winget not available; skipping install." 'Yellow'; exit 2 }
 try{
 Msg "Installing Poppler via winget ..." 'Cyan'
 winget install--id oschwartz10612.Poppler-e--silent--accept-package
agreements--accept-source-agreements | Out-Null
 }catch{ Msg "winget failed: $($_.Exception.Message)" 'Yellow' }
 # Re-probe
 $here = Join-Path (Split-Path-Parent $PSCommandPath) 'Find-Poppler.ps1'
 if(Test-Path $here){ $path = & $here-Quiet } else { $path = $null }
 if($path){ Msg "Found: $path" 'Green'; $path } else { Msg "Poppler not found 
after install." 'Yellow'; exit 1 }