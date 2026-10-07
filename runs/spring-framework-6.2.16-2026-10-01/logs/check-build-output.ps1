$ErrorActionPreference = "Stop"
$modules = @("spring-aop","spring-aspects","spring-beans","spring-context","spring-context-indexer","spring-context-support","spring-core","spring-core-test","spring-expression","spring-instrument","spring-jcl","spring-jdbc","spring-jms","spring-messaging","spring-orm","spring-oxm","spring-r2dbc","spring-test","spring-tx","spring-web","spring-webflux","spring-webmvc","spring-websocket")
$total = 0
foreach ($m in $modules) {
    $p = "sources/spring-framework-6.2.16/$m/build/classes/java/main"
    if (Test-Path $p) {
        $c = (Get-ChildItem -Path $p -Recurse -Filter "*.class" | Measure-Object).Count
    } else { $c = 0 }
    $total += $c
    Write-Output ("{0,6} : {1}" -f $c, $m)
}
Write-Output "TOTAL=$total"
