#!/usr/bin/env bash
mkdir -p $HOME/.local/state/zsh
pushd $HOME/.local/state/zsh

if [ ! -d zsh-autosuggestions ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions
fi

if [ ! -d zsh-syntax-highlighting ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting
fi

if [ ! -d zsh-history-substring-search ]; then
  git clone https://github.com/zsh-users/zsh-history-substring-search
fi

if [ ! -d gradle-completion ]; then
  git clone https://github.com/gradle/gradle-completion
fi

popd
