$ErrorActionPreference = "Stop"
$xml = [xml](Get-Content runs/spring-framework-6.2.16-2026-10-01/raw/pmd-output.xml -Raw)
$violations = $xml.pmd.file.violation
$byRule = $violations | Group-Object rule | Select-Object Name, Count
$byRule | ForEach-Object { "{0,6} : {1}" -f $_.Count, $_.Name }
Write-Output "TOTAL=$($violations.Count)"
$errorNodes = $xml.pmd.error
Write-Output "PROCESSING_ERRORS=$($errorNodes.Count)"
