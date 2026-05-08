# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.
# new laptop setup process
sudo apt update
sudo apt install git neovim curl build-essential clangd cmake make ripgrep fd-find

nvim --version
clangd --version
g++ --version

git clone https://github.com/wuharu999/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
:Lazy
