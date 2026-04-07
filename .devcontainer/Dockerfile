# Use Ubuntu as base image
FROM ubuntu:24.04

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget \
    gnupg \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    fonts-liberation \
    xdg-utils \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Install PWA development tools
RUN npm install -g lighthouse workbox-cli

# Install Flutter
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $FLUTTER_HOME \
    && flutter config --enable-web \
    && flutter precache --web \
    && chown -R 1000:1000 $FLUTTER_HOME

# Create vscode user with proper permissions
RUN if getent passwd 1000 > /dev/null 2>&1; then \
        existing_user=$(getent passwd 1000 | cut -d: -f1); \
        if [ "$existing_user" != "vscode" ]; then \
            usermod -l vscode $existing_user; \
            usermod -d /home/vscode -m vscode; \
        fi; \
    else \
        if ! getent group 1000 > /dev/null 2>&1; then \
            groupadd --gid 1000 vscode; \
        fi; \
        useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home vscode; \
    fi \
    && if getent group 1000 > /dev/null 2>&1; then \
        existing_group=$(getent group 1000 | cut -d: -f1); \
        if [ "$existing_group" != "vscode" ]; then \
            groupmod -n vscode $existing_group; \
        fi; \
    fi \
    && mkdir -p /etc/sudoers.d \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && mkdir -p /workspace \
    && chown -R vscode:vscode /workspace \
    && chmod -R 755 /workspace

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

USER vscode 