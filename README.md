[![Lua linting](https://github.com/NobleDraconian/Project-Walljump/actions/workflows/lua-lint.yml/badge.svg)](https://github.com/NobleDraconian/Project-Walljump/actions/workflows/lua-lint.yml)

# USING THIS TEMPLATE
1) Create a new github repository using github's templates feature, from this repository
2) Set `project-url` in `.github/workflows/add-to-project.yml` to the URL of the repository's associated project
3) Configure your S3 bucket configs in `mantle.yml`. This is where the mantle state file will be hosted.
4) Configure your S3 bucket access keys in `Scripts/install-tooling.bat`.
5) Remove the "USING THIS TEMPLATE" instructions from this README.

# Project-CODENAME
Soon(TM)

## Setting up developer environment

Compiling builds of this project requires the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install) (WSL).
For convenience, this repository includes scripts that will automatically install & configure WSL on your machine when ran.

To set up the environment, follow these steps in the commandline from the root of the repository:
1) Run `scripts\install-environment.bat`. WSL should begin installing the latest ubuntu distribution. After installation, it will prompt you for a username & password for your linux user account. Input your desired username & password! Once this is done, simply run the `logout` command to close the linux terminal.
2) Run `scripts\install-tooling.bat`. This will fetch & install any relevant tooling needed to build the project.
3) You're all set!

## Building the project

To build the project, you simply need to run the build script & specify the name of the environment you want to target. **NOTE : If you are targeting an environment that does not exist yet in `mantle.yml`, you will need to follow the DEPLOY instructions first!**
1) Run `scripts\build.bat` with the name of the environment you want to target as a parameter. For example, `scripts\build DEV_ND`.

You can open the place file from there! All of the relevant gamepass IDs, place IDs, etc will be automatically used in the game.

## Deploying the project

To deploy the project to one of the environments, you need to run the deployment script & specify the name of the environment you want to deploy to. If you want to create a new environment, you can specify it in `mantle.yml`.
1) Run `scripts\deploy.bat` with the name of the environment you want to deploy to as a parameter. For example, `scripts\deploy DEV_ND` would deploy the current place file to the universe `DEV_ND` on Roblox.