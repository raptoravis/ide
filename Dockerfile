# FROM ls12styler/dind:19.03.9
FROM ubuntu:20.04 

ENV DEBIAN_FRONTEND=noninteractive

# Install basics (HAVE to install bash for tpm to work)
RUN apt-get update && apt-get install -y --force-yes \
    bash zsh git neovim vim-gtk tmux less curl \
    man build-essential openssh-client 
    
RUN apt-get install -y --force-yes \
    gpg unzip rsync htop shellcheck ripgrep pass python3-pip

RUN apt-get install -y --force-yes \
    autoconf bison build-essential libssl-dev libyaml-dev \ 
    zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev 

RUN apt-get install -y --force-yes \
    libncurses5-dev \
    libgtk2.0-dev libatk1.0-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
    python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev ctags \
    git curl make cmake gcc clang openssh-server

# Set Timezone
ENV TZ=Asia/Shanghai
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone 

ENV HOME /home/me

# Install tmux
# COPY --from=ls12styler/tmux:3.1b /usr/local/bin/tmux /usr/local/bin/tmux

# Install jQ!
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O /bin/jq && chmod +x /bin/jq

# Configure text editor - vim!
# RUN curl -fLo ${HOME}/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN curl -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Consult the vimrc file to see what's installed
COPY .vimrc ${HOME}/.vimrc

# RUN vim +PlugInstall +q +q
# RUN timeout 20m vim +PlugInstall +qall || true

# In the entrypoint, we'll create a user called `me`
WORKDIR ${HOME}

# Setup my $SHELL
ENV SHELL /bin/zsh
# Install oh-my-zsh
RUN wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - | zsh || true
# RUN wget https://gist.githubusercontent.com/xfanwu/18fd7c24360c68bab884/raw/f09340ac2b0ca790b6059695de0873da8ca0c5e5/xxf.zsh-theme -O ${HOME}/.oh-my-zsh/custom/themes/xxf.zsh-theme
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.oh-my-zsh/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting

# Install FZF (fuzzy finder on the terminal and used by a Vim plugin).
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf 
RUN ${HOME}/.fzf/install || true

# Copy ZSh config
COPY .zshrc ${HOME}/.zshrc

COPY .profile ${HOME}/.profile
COPY .bashrc ${HOME}/.bashrc
COPY .aliases ${HOME}/.aliases
COPY .gemrc ${HOME}/.gemrc
COPY ./etc/wsl.conf /etc/wsl.conf

# Install TMUX
COPY .tmux.conf ${HOME}/.tmux.conf
RUN git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm

# Copy git config over
COPY .gitconfig ${HOME}/.gitconfig
COPY .gitconfig.user ${HOME}/.gitconfig.user


# Install ASDF (version manager which I use for non-Dockerized apps).
RUN git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v0.7.8
# RUN bash -c "source ${$HOME}/.asdf/asdf.sh"
# RUN ${$HOME}/.asdf/asdf.sh
# RUN bash . ${$HOME}/.asdf/asdf.sh

# Install Node through ASDF.
# RUN asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
# RUN bash ${HOME}/.asdf/plugins/nodejs/bin/import-release-team-keyring
# RUN asdf install nodejs 12.17.0
# RUN asdf global nodejs 12.17.0

# Install Ruby through ASDF.
# RUN asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
# RUN asdf install ruby 2.7.1
# RUN asdf global ruby 2.7.1

# Install Ansible.
# RUN pip3 install --user ansible

# Entrypoint script creates a user called `me` and `chown`s everything
COPY entrypoint.sh /bin/entrypoint.sh

# Set working directory to /workspace
WORKDIR /workspace

# Default entrypoint, can be overridden
CMD ["/bin/entrypoint.sh"]
