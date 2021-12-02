#Install Dein.vim
echo Install Dein.vim
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
# For example, we just use `~/.cache/dein` as installation directory
sh ./installer.sh ~/.cache/dein
echo Clone neovim config
git clone https://github.com/Paomiantong/nvim.git ~/.config/nvim
echo Done
echo pip3 install neovim
echo npm install neovim
