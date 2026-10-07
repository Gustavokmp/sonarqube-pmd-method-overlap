# Normalizacao (secao 13/14), passo 2: monta dedup-input a partir da
# associacao (apenas eligible_method, por definicao de A/B - secao 15),
# zipando posicionalmente com os raw_alert_id originais (mesma ordem de
# geracao das occurrences), e roda o Deduplicator (chave
# tool+project+smell+method_id).

$ErrorActionPreference = "Stop"
$runDir = "runs/spring-framework-6.2.16-2026-10-01"
$inv = "$runDir/inventories"
$project = "spring-framework-6.2.16"

function Rule-To-Smell($label) {
    if ($label -match 'S138$' -or $label -match 'NcssCount$') { return 'long_method' }
    if ($label -match 'S107$' -or $label -match 'ExcessiveParameterList$') { return 'long_parameter_list' }
    throw "regra desconhecida: $label"
}

# Constroi a linha JSON manualmente (NAO usar ConvertTo-Json: escapa '<'/'>'
# como \u003c/\u003e e o parser minimo do Deduplicator.java nao desfaz
# \uXXXX - corromperia method_id de metodos genericos). Mesma convencao de
# escape do Associator.java (apenas " \ \n \r \t).
function Json-Escape($s) {
    $s = $s -replace '\\', '\\\\'
    $s = $s -replace '"', '\"'
    $s = $s -replace "`r", '\r'
    $s = $s -replace "`n", '\n'
    $s = $s -replace "`t", '\t'
    return $s
}

function Build-DedupInput($tool, $assocFile, $alertIdsFile, $outFile) {
    $assoc = Get-Content $assocFile | ForEach-Object { $_ | ConvertFrom-Json }
    $alertIds = Get-Content $alertIdsFile
    if ($assoc.Count -ne $alertIds.Count) {
        throw "$tool : contagem de associacao ($($assoc.Count)) != contagem de raw_alert_id ($($alertIds.Count))"
    }
    $lines = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $assoc.Count; $i++) {
        $a = $assoc[$i]
        if ($a.status -ne 'eligible_method') { continue }
        $smell = Rule-To-Smell $a.label
        $json = '{"tool":"' + (Json-Escape $tool) + '","project":"' + (Json-Escape $project) + '","smell":"' + (Json-Escape $smell) + '","method_id":"' + (Json-Escape ([string]$a.method_id)) + '","raw_alert_id":"' + (Json-Escape ([string]$alertIds[$i])) + '"}'
        $lines.Add($json)
    }
    Set-Content -Path $outFile -Value $lines -Encoding UTF8
    return $lines.Count
}

$nSq = Build-DedupInput "sonarqube" "$inv/association-sonarqube.jsonl" "$runDir/logs/raw-alert-ids-sonarqube.txt" "$inv/dedup-input-sonarqube.jsonl"
$nPmd = Build-DedupInput "pmd" "$inv/association-pmd.jsonl" "$runDir/logs/raw-alert-ids-pmd.txt" "$inv/dedup-input-pmd.jsonl"
Write-Output "DEDUP_INPUT_SONARQUBE=$nSq"
Write-Output "DEDUP_INPUT_PMD=$nPmd"

Get-Content "$inv/dedup-input-sonarqube.jsonl","$inv/dedup-input-pmd.jsonl" | Set-Content -Path "$inv/dedup-input-all.jsonl" -Encoding UTF8
Write-Output "DEDUP_INPUT_ALL=$((Get-Content "$inv/dedup-input-all.jsonl" | Measure-Object -Line).Lines)"

Push-Location scripts/method-inventory
try {
    & java -cp "out;lib/javaparser-core-3.28.2.jar" Deduplicator `
        --in "../../$inv/dedup-input-all.jsonl" `
        --out "../../$inv/dedup-results.jsonl"
} finally {
    Pop-Location
}
