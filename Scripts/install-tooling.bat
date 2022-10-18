@echo off
pushd %~dp0

echo Installing tooling...
cd ../Temp
wsl sudo apt install unzip
wsl wget https://github.com/Roblox/foreman/releases/latest/download/foreman-linux.zip
wsl unzip -o foreman-linux.zip
wsl mv foreman ~
wsl chmod +x ~/foreman
cd ../
wsl ~/foreman install
wsl bash -c "printf '\nexport PATH=''\$HOME/.foreman/bin:\$PATH' >> ~/.bashrc"
echo Tooling installed!

echo Storing AWS credentials for mantle (Windows)...
mkdir %USERPROFILE%\.aws
echo [default] > %USERPROFILE%/.aws/credentials
echo aws_access_key_id = ACCES_KEY_ID >> %USERPROFILE%/.aws/credentials
echo aws_secret_access_key = SECRET_ACCESS_KEY >> %USERPROFILE%/.aws/credentials

echo Storing AWS credentials for mantle (*nix)...
wsl bash -c "mkdir $HOME/.aws"
wsl bash -c "printf '[default]\n' > $HOME/.aws/credentials"
wsl bash -c "printf 'aws_access_key_id = ACCESS_KEY_ID\n' >> $HOME/.aws/credentials"
wsl bash -c "printf 'aws_secret_access_key = SECRET_ACCESS_KEY\n' >> $HOME/.aws/credentials"

popd