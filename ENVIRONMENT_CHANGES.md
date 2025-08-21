# Terminal Environment Changes

## Extension: GitHub.copilot-chat

Enables use of the `copilot-debug` command in the terminal.

- `PATH=${env:PATH}:/home/pin2/.config/Code/User/globalStorage/github.copilot-chat/debugCommand`

## Extension: vscode.git

Enables the following features: git auth provider

- `GIT_ASKPASS=/usr/share/code/resources/app/extensions/git/dist/askpass.sh`
- `VSCODE_GIT_ASKPASS_NODE=/usr/share/code/code`
- `VSCODE_GIT_ASKPASS_EXTRA_ARGS=`
- `VSCODE_GIT_ASKPASS_MAIN=/usr/share/code/resources/app/extensions/git/dist/askpass-main.js`
- `VSCODE_GIT_IPC_HANDLE=/run/user/1000/vscode-git-dc6b9dd63a.sock`
