@echo off
pushd %~dp0

echo Installing linux environment...
wsl --install --distribution Ubuntu

popd