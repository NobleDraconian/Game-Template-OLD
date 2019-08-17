@echo off

where /q rojo
if %ERRORLEVEL% neq 0 (
	echo Rojo does not appear to be installed on your system.
	echo In order to compile the game, you will need rojo 0.5.0-alpha.13 installed.
	exit /b
) else (
	pushd %~dp0
	<nul set/p=Compiling game with 
	rojo --version
	rojo build ..\ --output ..\CurrentBuild.rbxlx
	echo Game compiled.
	popd
)