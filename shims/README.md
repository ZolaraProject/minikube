ZSH completion scripts
This folder contains completion scripts for ZSH completion system. It uses shims as commands to trigger completion.

## Usage
Add the following lines to your .zshrc file:
```
export PATH=$PATH:/homedir/workspace/zolara/minikube/scripts/shims
fpath=(/homedir/workspace/zolara/minikube/scripts/completion $fpath)
autoload -U compinit; compinit
```
Scripts can now be called using their names in `shims` folder to trigger completion