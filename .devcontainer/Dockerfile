FROM node:20
# Note: Using Node.js as base image to support Claude Code,
# but this is primarily a Python project using poetry for Python environment management

ARG TZ
ENV TZ="$TZ"

# Install basic development tools and iptables/ipset
RUN apt update && apt install -y less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  curl \
  wget \
  bzip2 \
  libglib2.0-0 \
  libxext6 \
  libsm6 \
  libxrender1 \
  ca-certificates \
  python3.11 \
  python3.11-venv \
  python3.11-dev \
  python3-pip

# Set python3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude && \
  # Create a symlink from /app to /workspace for docker-compose compatibility
  rm -rf /app && ln -sf /workspace /app

RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_0.18.2_${ARCH}.deb" && \
  rm "git-delta_0.18.2_${ARCH}.deb"

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH="/home/node/.local/bin:/usr/local/share/npm-global/bin:$PATH"

# Install Claude
RUN npm install -g @anthropic-ai/claude-code

# Configure shell environments for node user
USER root

# Set zsh as the default shell
ENV SHELL /bin/zsh

# Install and configure zsh with powerline10k theme
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Copy and set up scripts
COPY .devcontainer/init-firewall.sh /usr/local/bin/
COPY .devcontainer/init-poetry.sh /usr/local/bin/
COPY .devcontainer/init-git.sh /usr/local/bin/
COPY .devcontainer/init-precommit.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/init-poetry.sh /usr/local/bin/init-git.sh /usr/local/bin/init-precommit.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh, /usr/local/bin/init-poetry.sh, /usr/local/bin/init-git.sh, /usr/local/bin/init-precommit.sh, /bin/bash /workspace/.devcontainer/init-poetry.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall && \
  # Add write permissions to common directories for node user
  mkdir -p /workspace/uploads && \
  chown -R node:node /workspace/uploads

# Install Poetry properly
USER node
RUN curl -sSL https://install.python-poetry.org | python3 -

USER root
RUN ln -s /home/node/.local/bin/poetry /usr/local/bin/poetry
# Finally switch to node user for container runtime
USER node

# Set working directory
WORKDIR /workspace

# Copy pyproject.toml and poetry.lock separately for caching
COPY pyproject.toml poetry.lock* ./
