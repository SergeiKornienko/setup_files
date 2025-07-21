#!/bin/bash

# Пути к конфигурационным файлам
CONFIG_REPO="$HOME/setup_files"
CONFIG_FILES=(".zshrc" ".vimrc" ".tmux.conf")

# Определение ОС
if [ -x "$(command -v termux-setup-storage)" ]; then
    OS="termux"
    PACKAGE_MANAGER="pkg"
    INSTALL_CMD="install -y"
else
    OS="ubuntu"
    PACKAGE_MANAGER="sudo apt-get"
    INSTALL_CMD="install -y"
    $PACKAGE_MANAGER update
fi

# Функция для установки пакетов
install_packages() {
    for pkg in "$@"; do
        if ! command -v $pkg &> /dev/null; then
            echo "📦 Устанавливаем $pkg..."
            $PACKAGE_MANAGER $INSTALL_CMD $pkg || echo "❌ Не удалось установить $pkg"
        else
            echo "✓ $pkg уже установлен"
        fi
    done
}

# Основные пакеты
BASE_PACKAGES="git curl wget zsh python3 vim tmux fzf"
install_packages $BASE_PACKAGES

# Специфичные пакеты
if [ "$OS" = "termux" ]; then
    install_packages openssh command-not-found termux-api
    termux-setup-storage
else
    install_packages ssh command-not-found zsh-syntax-highlighting zsh-autosuggestions
    [ ! -x "$(command -v sudo)" ] && apt-get install -y sudo
fi

# Работа с конфигурационными файлами
manage_configs() {
    if [ -d "$CONFIG_REPO" ]; then
        echo "🔍 Найден локальный репозиторий конфигов: $CONFIG_REPO"
        
        for config in "${CONFIG_FILES[@]}"; do
            if [ -f "$CONFIG_REPO/$config" ]; then
                cp -v "$CONFIG_REPO/$config" ~/
                # Специальная обработка для tmux.conf
                if [ "$config" = ".tmux.conf" ] && [ "$OS" = "termux" ]; then
                    sed -i 's/^set -g default-terminal.*/# &/' ~/.tmux.conf
                    echo "🛠️ Адаптировал .tmux.conf для Termux"
                fi
            else
                echo "⚠️ Файл $config не найден в репозитории"
            fi
        done
    else
        echo "🌐 Клонируем репозиторий конфигов..."
        git clone https://github.com/SergeiKornienko/setup_files.git $CONFIG_REPO
        if [ -d "$CONFIG_REPO" ]; then
            for config in "${CONFIG_FILES[@]}"; do
                [ -f "$CONFIG_REPO/$config" ] && cp -v "$CONFIG_REPO/$config" ~/
            done
        fi
    fi
}

manage_configs

# Установка Oh My Zsh
if command -v zsh &> /dev/null && [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🚀 Устанавливаем Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    echo "🔌 Устанавливаем плагины Zsh..."
    plugins=(
        "https://github.com/zsh-users/zsh-completions"
        "https://github.com/zsh-users/zsh-autosuggestions"
        "https://github.com/zdharma-continuum/fast-syntax-highlighting"
    )
    
    for plugin in "${plugins[@]}"; do
        git clone $plugin ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$(basename $plugin)
    done
fi

# Настройка Vim
if command -v vim &> /dev/null; then
    echo "✍️ Настраиваем Vim..."
    mkdir -p ~/.vim/{autoload,swap}
    
    if [ ! -f ~/.vim/autoload/plug.vim ]; then
        echo "⬇️ Устанавливаем vim-plug..."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    
    echo "🔌 Устанавливаем плагины Vim..."
    vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"
fi

# Настройка Tmux
if command -v tmux &> /dev/null && [ -f ~/.tmux.conf ]; then
    echo "💻 Настраиваем Tmux..."
    if [ "$OS" = "termux" ]; then
        echo "🖥️ Для применения настроек Tmux в Termux可能需要:"
        echo "1. Запустить tmux"
        echo "2. Нажать Ctrl+B, затем :source-file ~/.tmux.conf"
    fi
fi

# Настройка SSH
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "🔑 Генерируем SSH-ключ..."
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
    echo -e "\n🔒 Публичный ключ (добавьте его на GitHub и др. сервисы):"
    cat ~/.ssh/id_ed25519.pub
fi

echo -e "\n🎉 Установка завершена!"
echo "Для применения изменений выполните:"
echo "source ~/.zshrc && tmux source-file ~/.tmux.conf"
