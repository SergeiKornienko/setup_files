#!/bin/bash

# Определяем, работает ли скрипт в Termux или Ubuntu
if [ -x "$(command -v termux-setup-storage)" ]; then
    OS="termux"
    PACKAGE_MANAGER="pkg"
    INSTALL_CMD="install -y"
else
    OS="ubuntu"
    PACKAGE_MANAGER="sudo apt-get"
    INSTALL_CMD="install -y"
    # Обновляем список пакетов для Ubuntu
    $PACKAGE_MANAGER update
fi

# Функция для установки пакетов с проверкой
install_packages() {
    for pkg in "$@"; do
        if ! command -v $pkg &> /dev/null; then
            echo "Устанавливаем $pkg..."
            $PACKAGE_MANAGER $INSTALL_CMD $pkg || echo "Не удалось установить $pkg"
        else
            echo "$pkg уже установлен, пропускаем..."
        fi
    done
}

# Общие пакеты для обеих систем
COMMON_PACKAGES="curl wget zsh python3 vim tmux fzf"

# Установка общих пакетов
install_packages $COMMON_PACKAGES

# Установка специфичных пакетов
if [ "$OS" = "termux" ]; then
    # Пакеты только для Termux
    TERMUX_PACKAGES="openssh command-not-found termux-api"
    install_packages $TERMUX_PACKAGES
    
    # Termux-specific setup
    termux-setup-storage
else
    # Пакеты только для Ubuntu
    UBUNTU_PACKAGES="ssh command-not-found zsh-syntax-highlighting zsh-autosuggestions"
    install_packages $UBUNTU_PACKAGES
    
    # Установка sudo, если его нет (например, в docker-образе)
    if ! command -v sudo &> /dev/null; then
        apt-get install -y sudo
    fi
fi




# Установка Oh My Zsh (если zsh установлен)
if command -v zsh &> /dev/null && [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Устанавливаем Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Установка плагинов ohmyzsh
    echo "Устанавливаем плагины Oh My Zsh..."
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
fi

# Настройка Vim с плагинами
if command -v vim &> /dev/null; then
    echo "Настраиваем Vim..."
    
    # Установка менеджера плагинов vim-plug
    if [ ! -f ~/.vim/autoload/plug.vim ]; then
        echo "Устанавливаем vim-plug..."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    
    # Создаем директорию для swap файлов, если её нет
    mkdir -p ~/.vim/swap
    
    # Установка плагинов Vim
    echo "Устанавливаем плагины Vim..."
    vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"
fi

# Настройка SSH (если нужно)
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Генерируем SSH-ключ..."
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
    echo "SSH-ключ сгенерирован: ~/.ssh/id_ed25519"
    echo "Публичный ключ:"
    cat ~/.ssh/id_ed25519.pub
fi

echo "Установка завершена успешно!"
echo "Для применения изменений выполните:"
echo "source ~/.zshrc"
