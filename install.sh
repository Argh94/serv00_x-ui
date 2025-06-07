#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Logging functions
function LOGD() {
    echo -e "${yellow}[DEBUG] $* ${plain}"
}

function LOGE() {
    echo -e "${red}[ERROR] $* ${plain}"
}

function LOGI() {
    echo -e "${green}[INFO] $* ${plain}"
}

# Check system architecture
arch=$(uname -m)
if [[ $arch == "x86_64" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
else
    arch="amd64"
    LOGE "Architecture detection failed, using default: ${arch}"
fi

LOGI "Detected architecture: ${arch}"

# Check system release
if uname -a | grep -Eqi "freebsd"; then
    release="freebsd"
else
    LOGE "Unsupported system detected. Please contact the script author."
    exit 1
fi

# Set variables
x_ui_dir="$HOME/x-ui"
x_ui_bin="$x_ui_dir/x-ui"
xray_bin="$x_ui_dir/bin/xray-${release}-${arch}"
config_dir="$x_ui_dir/bin"
x_ui_version="0.3.4.8"
xray_version="1.8.23"

# Create directory
if [[ ! -d "$x_ui_dir" ]]; then
    mkdir -p "$x_ui_dir"
    mkdir -p "$config_dir"
fi

cd "$x_ui_dir" || { LOGE "Failed to change directory to $x_ui_dir"; exit 1; }

# Download x-ui binary
LOGI "Downloading x-ui binary..."
wget -q --no-check-certificate -O "$x_ui_bin" "https://github.com/amclubs/am-serv00-x-ui/releases/download/v${x_ui_version}/x-ui-freebsd-${arch}"
if [[ $? -ne 0 ]]; then
    LOGE "Failed to download x-ui binary. Please check your network or the release URL."
    exit 1
fi
chmod +x "$x_ui_bin"

# Download xray binary
LOGI "Downloading xray binary..."
wget -q --no-check-certificate -O "$xray_bin.zip" "https://github.com/XTLS/Xray-core/releases/download/v${xray_version}/Xray-freebsd-${arch}.zip"
if [[ $? -ne 0 ]]; then
    LOGE "Failed to download xray binary. Please check your network or the release URL."
    exit 1
fi

# Unzip xray binary
LOGI "Extracting xray binary..."
unzip -o "$xray_bin.zip" -d "$config_dir" && rm "$xray_bin.zip"
if [[ $? -ne 0 ]]; then
    LOGE "Failed to extract xray binary."
    exit 1
fi
mv "$config_dir/xray" "$xray_bin"
chmod +x "$xray_bin"

# Create default config if not exists
if [[ ! -f "$config_dir/config.json" ]]; then
    LOGI "Creating default configuration file..."
    cat << EOF > "$config_dir/config.json"
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [],
    "outbounds": [],
    "routing": {
        "rules": []
    }
}
EOF
fi

# Create x-ui database directory
if [[ ! -d "$x_ui_dir/db" ]]; then
    mkdir -p "$x_ui_dir/db"
fi

LOGI "Installation completed successfully!"
LOGI "You can now run '~/x-ui.sh' to manage the x-ui panel."
