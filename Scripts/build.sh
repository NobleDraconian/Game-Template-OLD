LatestCommitHash=$(git log --pretty=format:%h -n 1)
LatestReleaseVersion=$(git describe --tags --abbrev=0)

export PATH=$HOME/.foreman/bin:$PATH

cd ../
echo "Building to environment '$1'..."
echo -n $LatestReleaseVersion@$LatestCommitHash > Env/GameVersion.txt
echo -n $1 > Env/EnvironmentName.txt
mantle outputs -e $1 -o Env/EnvironmentIDs.txt
rojo build default.project.json --output Temp/CurrentBuild.rbxl