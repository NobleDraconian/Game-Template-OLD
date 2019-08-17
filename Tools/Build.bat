@echo off
pushd %~dp0
<nul set/p=Compiling game with 
.\rojo --version
.\rojo build ..\ --output ..\CurrentBuild.rbxlx
echo Game compiled.
popd