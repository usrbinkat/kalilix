# syntax=docker/dockerfile:1
FROM docker.io/library/debian:13

# Copy sudoers configuration
COPY rootfs/etc/sudoers.d/debian /etc/sudoers.d/debian

# Copy skeleton files for user creation
COPY rootfs/etc/skel/.bashrc /etc/skel/.bashrc

# Also configure root's environment for Nix
RUN echo 'export PATH="/nix/var/nix/profiles/default/bin:$PATH"' >> /root/.bashrc
COPY rootfs/etc/skel/.profile /etc/skel/.profile
COPY rootfs/etc/skel/.zshrc /etc/skel/.zshrc
# Create fish config directory in skel, then copy config
RUN mkdir -p /etc/skel/.config/fish
COPY rootfs/etc/skel/.config/fish/config.fish /etc/skel/.config/fish/config.fish

# Environment variables for mise
ENV MISE_DATA_DIR="/home/debian/.local/share/mise" \
    MISE_CONFIG_DIR="/home/debian/.config/mise" \
    MISE_CACHE_DIR="/home/debian/.cache/mise" \
    MISE_STATE_DIR="/home/debian/.local/state/mise" \
    MISE_INSTALL_PATH="/home/debian/.local/bin/mise" \
    MISE_EXPERIMENTAL=1 \
    MISE_TRUSTED_CONFIG_PATHS="/workspace"

# Install essential packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo curl wget git ca-certificates xz-utils \
    build-essential cmake pkg-config libssl-dev \
    python3-full python3-pip python3-venv pipx \
    bash bash-completion fish zsh vim nano \
    jq unzip zip gpg locales \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Configure locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Fix sudoers permissions
RUN chmod 0440 /etc/sudoers.d/debian

# Create debian user with sudo privileges (skel will provide configs)
RUN useradd -m -s /bin/bash debian

# Install Nix using Determinate Systems installer (as root for container)
# Note: With --init none, only root can run Nix commands directly
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux \
    --init none \
    --extra-conf "sandbox = false" \
    --extra-conf "experimental-features = nix-command flakes" \
    --extra-conf "trusted-users = root debian" \
    --extra-conf "max-jobs = auto" \
    --extra-conf "cores = 0" \
    --no-confirm

# Add Nix to system PATH
ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"

# Ensure root also has Nix in PATH when using sudo
RUN echo 'Defaults secure_path="/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' > /etc/sudoers.d/nix-path && \
    chmod 0440 /etc/sudoers.d/nix-path

# Switch to debian user
USER debian
WORKDIR /home/debian

# Create necessary directories for mise
RUN mkdir -p \
    ~/.local/bin \
    ~/.local/share/mise/shims \
    ~/.config/mise \
    ~/.cache/mise \
    ~/.local/state/mise \
    ~/.local/share/bash-completion/completions \
    ~/.local/share/zsh/site-functions \
    ~/.config/fish/completions

# Install mise as debian user
RUN curl https://mise.run | sh

# Update PATH for mise
ENV PATH="/home/debian/.local/share/mise/shims:/home/debian/.local/bin:${PATH}"

# Generate shell completions for mise
RUN ~/.local/bin/mise completion bash > ~/.local/share/bash-completion/completions/mise && \
    ~/.local/bin/mise completion zsh > ~/.local/share/zsh/site-functions/_mise && \
    ~/.local/bin/mise completion fish > ~/.config/fish/completions/mise.fish

# Create workspace directory
RUN sudo mkdir -p /workspace && sudo chown -R debian:debian /workspace
WORKDIR /workspace

# Verify installations (run as root since we're still root here)
RUN ~/.local/bin/mise --version && \
    nix --version && \
    echo "✅ Mise and Nix installed successfully"

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Use sleep infinity for devcontainer compatibility
CMD ["sleep", "infinity"]
