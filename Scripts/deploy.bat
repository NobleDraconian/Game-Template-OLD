@echo off
pushd %~dp0\..\

echo Deplying to environment '%1'...
mantle deploy -e %1

popd