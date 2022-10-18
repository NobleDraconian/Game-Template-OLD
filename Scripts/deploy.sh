export PATH=$HOME/.foreman/bin:$PATH

cd ../
echo "Deplying to environment '$1'..."
mantle deploy -e $1