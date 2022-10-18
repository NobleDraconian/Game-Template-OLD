@echo off
pushd %~dp0

wsl ./build.sh %1

popd