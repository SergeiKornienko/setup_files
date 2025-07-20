#!/data/data/com.termux/files/usr/bin/bash

# Обновление репозиториев
pkg update -y && pkg upgrade -y

# Установка основных пакетов
pkg install -y git curl wget zsh python openssh vim tmux fzf command-not-found termux-api

# Установка Oh My Zsh (опционально)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# установка плагинов ohmyzsh
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting

# Клонирование конфигов (например, .bashrc или .zshrc)
if [ ! -f ~/.zshrc ]; then
     curl -o ~/.zshrc https://example.com/path/to/your/zshrc
fi

# Установка дополнительных утилит (например, rclone, ffmpeg и т. д.)
# pkg install -y ffmpeg rclone

# Настройка SSH (если нужно)
if [ ! -f ~/.ssh/id_ed25519 ]; then
     ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
       fi

         echo "Установка завершена!"


