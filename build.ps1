$ScriptDir = Split-Path $MyInvocation.MyCommand.Source -Parent -Resolve
$SrcDir = Join-Path $ScriptDir "src"
$BuildDir = Join-Path $ScriptDir "build"
$InstallDir = Join-Path $ScriptDir "..\llvm\install" -Resolve
$Url = "https://github.com/include-what-you-use/include-what-you-use.git"
$Branch = "origin/clang_11"
$CMakeArgs = @(
    "-D", "CMAKE_PREFIX_PATH=`"$InstallDir`"",
    "-D", "CMAKE_INSTALL_PREFIX=`"$InstallDir`"",
    "$SrcDir"
)

if (-not (Test-Path $SrcDir -PathType Container)) {
    git clone $Url $SrcDir
} else {
    git -C $SrcDir fetch
}

git -C $SrcDir checkout $Branch

if (-not (Test-Path $BuildDir -PathType Container)) {
    New-Item $BuildDir -ItemType Directory
} else {
    Remove-Item "$BuildDir\*" -Recurse
}

Push-Location $BuildDir

cmake -G"Visual Studio 16 2019" -T"ClangCL,host=x64" -A"x64" @CMakeArgs

cmake --build . --config Release -- /p:CL_MPCount=16 /m:8

cmake --install . --config Release

Pop-Location

Write-Output "Done!"
