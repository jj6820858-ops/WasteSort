param([string]$QtRoot = 'D:\Qt', [switch]$Deploy)
$ErrorActionPreference = 'Stop'
$projectDir = $PSScriptRoot
$qtKit = Join-Path $QtRoot '6.8.3\mingw_64'
$cmake = Join-Path $QtRoot 'Tools\CMake_64\bin\cmake.exe'
$ninja = Join-Path $QtRoot 'Tools\Ninja\ninja.exe'
$compiler = Join-Path $QtRoot 'Tools\mingw1310_64\bin'
$env:PATH = "$qtKit\bin;$compiler;$env:PATH"
& $cmake -S $projectDir -B "$projectDir\build" -G Ninja "-DCMAKE_MAKE_PROGRAM=$ninja" "-DCMAKE_CXX_COMPILER=$compiler\g++.exe" "-DCMAKE_PREFIX_PATH=$qtKit" -DCMAKE_BUILD_TYPE=Release
if ($LASTEXITCODE) { throw 'CMake configure failed' }
& $cmake --build "$projectDir\build" --parallel 4
if ($LASTEXITCODE) { throw 'Build failed' }
& "$QtRoot\Tools\CMake_64\bin\ctest.exe" --test-dir "$projectDir\build" --output-on-failure
if ($LASTEXITCODE) { throw 'Tests failed' }
if ($Deploy) {
    New-Item -ItemType Directory -Force "$projectDir\dist\WasteSort" | Out-Null
    Copy-Item -LiteralPath "$projectDir\build\WasteSort.exe" -Destination "$projectDir\dist\WasteSort\WasteSort.exe" -Force
    & "$qtKit\bin\windeployqt.exe" --release --qmldir "$projectDir\qml" --no-translations "$projectDir\dist\WasteSort\WasteSort.exe"
    if ($LASTEXITCODE) { throw 'Deployment failed' }
}
