$ErrorActionPreference = "Stop"
$excluded = Get-Content runs/spring-framework-6.2.16-2026-10-01/inventories/arquivos-excluidos.txt
$cat = @{}
foreach ($f in $excluded) {
    if ($f -match "^spring-[^/]+/src/test/") { $k = "spring-*/src/test" }
    elseif ($f -match "^spring-[^/]+/src/testFixtures/") { $k = "spring-*/src/testFixtures" }
    elseif ($f -match "^spring-[^/]+/src/jmh/") { $k = "spring-*/src/jmh (benchmarks)" }
    elseif ($f -match "^spring-[^/]+/src/main/kotlin/") { $k = "spring-*/src/main/kotlin" }
    elseif ($f -match "^spring-[^/]+/src/main/resources/") { $k = "spring-*/src/main/resources" }
    elseif ($f -match "^spring-[^/]+/") { $k = "spring-*/(outros: build files, docs do modulo)" }
    elseif ($f -match "^framework-api/") { $k = "framework-api (java-platform, sem .java)" }
    elseif ($f -match "^framework-bom/") { $k = "framework-bom (java-platform, sem .java)" }
    elseif ($f -match "^framework-platform/") { $k = "framework-platform (java-platform, sem .java)" }
    elseif ($f -match "^framework-docs/") { $k = "framework-docs (snippets de documentacao, jar/javadoc desabilitados)" }
    elseif ($f -match "^integration-tests/") { $k = "integration-tests (somente src/test)" }
    elseif ($f -match "^buildSrc/") { $k = "buildSrc (tooling interno de build Gradle)" }
    elseif ($f -match "^gradle/") { $k = "gradle/ (wrapper e scripts de build)" }
    elseif ($f -match "^\.github/") { $k = ".github (CI)" }
    elseif ($f -match "^\.idea/") { $k = ".idea (config de IDE)" }
    else { $k = "raiz do repositorio (README/LICENSE/etc.)" }
    if (-not $cat.ContainsKey($k)) { $cat[$k] = 0 }
    $cat[$k]++
}
$cat.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object { "{0,6} : {1}" -f $_.Value, $_.Key }
