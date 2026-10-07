$d = Get-Content "runs/hibernate-orm-7.2.6.Final-2026-10-01/inventories/dedup-results.jsonl" | ForEach-Object { $_ | ConvertFrom-Json }
$sqLM = ($d | Where-Object { $_.tool -eq 'sonarqube' -and $_.smell -eq 'long_method' }).Count
$sqLP = ($d | Where-Object { $_.tool -eq 'sonarqube' -and $_.smell -eq 'long_parameter_list' }).Count
$pmdLM = ($d | Where-Object { $_.tool -eq 'pmd' -and $_.smell -eq 'long_method' }).Count
$pmdLP = ($d | Where-Object { $_.tool -eq 'pmd' -and $_.smell -eq 'long_parameter_list' }).Count
$lines = @(
    "SONARQUBE_LONG_METHOD=$sqLM",
    "SONARQUBE_LONG_PARAMETER_LIST=$sqLP",
    "PMD_LONG_METHOD=$pmdLM",
    "PMD_LONG_PARAMETER_LIST=$pmdLP"
)
Set-Content -Path "runs/hibernate-orm-7.2.6.Final-2026-10-01/logs/dedup-breakdown.txt" -Value $lines -Encoding utf8
