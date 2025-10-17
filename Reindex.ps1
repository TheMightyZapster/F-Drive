[CmdletBinding()]param([switch]$Parallel,[int]$Throttle)
& .\rb.ps1 index -parallel:$Parallel -throttle:$Throttle
