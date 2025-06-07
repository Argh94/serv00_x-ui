#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Add some basic functions
function LOGD() {
    echo -e "${yellow}[DEBUG] $* ${plain}"
}

function LOGE() {
    echo -e "${red}[ERROR] $* ${plain}"
}

function LOGI() {
    echo -e "${green}[INFO] $* ${plain}"
}

cd ~
uname_output=$(uname -a)
enable_str="nohup \.\/x-ui run"

# Check OS
if echo "$uname_output" | grep -Eqi "freebsd"; then
    release="freebsd"
else
    echo -e "${red}System version not detected, please contact the script author!${plain}\n" && exit 1
fi

arch="none"

if echo "$uname_output" | grep -Eqi 'x86_64|amd64|x64'; then
    arch="amd64"
elif echo "$uname_output" | grep -Eqi 'aarch64|arm64'; then
    arch="arm64"
else
    arch="amd64"
    echo -e "${red}Failed to detect architecture, using default architecture: ${arch}${plain}"
fi

echo "Architecture: ${arch}"

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [default: $2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "Would you like to restart the panel? Restarting the panel will also restart xray" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Press Enter to return to the main menu: ${plain}" && read temp
    show_menu
}

update() {
    confirm "This function will force reinstall the latest version. Data will not be lost. Continue?" "n"
    if [[ $? != 0 ]]; then
        LOGE "Canceled"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    cd ~
    wget -N --no-check-certificate -O x-ui-install.sh https://raw.githubusercontent.com/argh94/serv00_x-ui/main/install.sh
    chmod +x x-ui-install.sh
    ./x-ui-install.sh
    if [[ $? == 0 ]]; then
        LOGI "Update completed, panel has been automatically restarted"
        exit 0
    fi
}

stop_x-ui() {
    # Define the command names for the nohup processes to kill
    xui_com="./x-ui run"
    xray_com="bin/xray-$release-$arch -c bin/config.json"
 
    # Find process ID using pgrep
    PID=$(pgrep -f "$xray_com")
 
    # Check if a process was found
    if [ ! -z "$PID" ]; then
        # Process found, kill it
        kill $PID
    
        # Optional: Check if the process is still running
        if kill -0 $PID > /dev/null 2>&1; then
            kill -9 $PID
        fi
    fi
    # Find process ID for x-ui
    PID=$(pgrep -f "$xui_com")
 
    # Check if a process was found
    if [ ! -z "$PID" ]; then
        # Process found, kill it
        kill $PID
    
        # Optional: Check if the process is still running
        if kill -0 $PID > /dev/null 2>&1; then
            kill -9 $PID
        fi
    fi
}

install() {
    cd ~
    wget -N --no-check-certificate -O x-ui-install.sh https://raw.githubusercontent.com/argh94/serv00_x-ui/main/install.sh
    chmod +x x-ui-install.sh
    ./x-ui-install.sh
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

uninstall() {
    confirm "Are you sure you want to uninstall the panel? xray will also be uninstalled" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    stop_x-ui
    crontab -l > x-ui.cron
    sed -i "" "/x-ui.log/d" x-ui.cron
    crontab x-ui.cron
    rm x-ui.cron
    cd ~
    rm -rf ~/x-ui/

    echo ""
    echo -e "Uninstallation successful. If you want to delete this script, run ${green}rm -f ~/x-ui.sh${plain} after exiting."
    echo ""

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

reset_user() {
    confirm "Are you sure you want to reset the username and password to admin?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    ~/x-ui/x-ui setting -username admin -password admin
    echo -e "Username and password have been reset to ${green}admin${plain}. Please restart the panel now."
    confirm_restart
}

reset_config() {
    confirm "Are you sure you want to reset all panel settings? Account data will not be lost, and username/password will remain unchanged." "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    ~/x-ui/x-ui setting -reset
    echo -e "All panel settings have been reset to default values. Please restart the panel and access it using the default port ${green}54321${plain}."
    confirm_restart
}

check_config() {
    info=$(~/x-ui/x-ui setting -show true)
    if [[ $? != 0 ]]; then
        LOGE "Error retrieving current settings, please check logs"
        show_menu
    fi
    LOGI "${info}"
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

set_port() {
    echo && echo -n -e "Enter port number [1-65535]: " && read -r port
    if [[ -z "${port}" ]]; then
        LOGD "Canceled"
        before_show_menu
    else
        ~/x-ui/x-ui setting -port ${port}
        echo -e "Panel access port set successfully. Please restart the panel and use the new port ${green}${port}${plain} to access it."
        confirm_restart
    fi
}

set_traffic_port() {
    echo && echo -n -e "Enter traffic monitoring port number [1-65535]: " && read -r trafficport
    if [[ -z "${trafficport}" ]]; then
        LOGD "Canceled"
        before_show_menu
    else
        ~/x-ui/x-ui setting -trafficport ${trafficport}
        echo -e "Traffic monitoring port set successfully. Please restart the panel and use the new port ${green}${trafficport}${plain} to access it."
        confirm_restart
    fi
}

start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        LOGI "Panel is already running. No need to start again. Select restart if needed."
    else
        cd ~/x-ui
        nohup ./x-ui run > ./x-ui.log 2>&1 &
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            LOGI "x-ui started successfully"
        else
            LOGE "Panel failed to start, possibly because startup took longer than two seconds. Check logs for details."
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    check_status
    if [[ $? == 1 ]]; then
        echo ""
        LOGI "Panel is already stopped. No need to stop again."
    else
        stop_x-ui
        sleep 2
        check_status
        if [[ $? == 1 ]]; then
            LOGI "x-ui and xray stopped successfully"
        else
            LOGE "Panel failed to stop, possibly because stopping took longer than two seconds. Check logs for details."
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    stop 0
    start 0
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        LOGI "x-ui and xray restarted successfully"
    else
        LOGE "Panel failed to restart, possibly because startup took longer than two seconds. Check logs for details."
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    COMMAND_NAME="./x-ui run"
    PID=$(pgrep -f "$COMMAND_NAME")
 
    # Check if a process was found
    if [ ! -z "$PID" ]; then
        LOGI "x-ui is running"
    else
        LOGI "x-ui is not running"
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    crontab -l > x-ui.cron
    sed -i "" "/$enable_str/d" x-ui.cron
    echo "@reboot cd ~/x-ui && nohup ./x-ui run > ./x-ui.log 2>&1 &" >> x-ui.cron
    crontab x-ui.cron
    rm x-ui.cron
    if [[ $? == 0 ]]; then
        LOGI "x-ui set to start on boot successfully"
    else
        LOGE "Failed to set x-ui to start on boot"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    crontab -l > x-ui.cron
    sed -i "" "/$enable_str/d" x-ui.cron
    crontab x-ui.cron
    rm x-ui.cron
    if [[ $? == 0 ]]; then
        LOGI "x-ui removed from boot startup successfully"
    else
        LOGE "Failed to remove x-ui from boot startup"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

update_shell() {
    wget -O ~/x-ui.sh -N --no-check-certificate https://raw.githubusercontent.com/argh94/serv00_x-ui/main/x-ui.sh
    if [[ $? != 0 ]]; then
        echo ""
        LOGE "Failed to download script. Please check if the machine can connect to GitHub."
        before_show_menu
    else
        chmod +x ~/x-ui.sh
        LOGI "Script updated successfully. Please rerun the script." && exit 0
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f ~/x-ui/x-ui ]]; then
        return 2
    fi
    COMMAND_NAME="./x-ui run"
    PID=$(pgrep -f "$COMMAND_NAME")
 
    # Check if a process was found
    if [ ! -z "$PID" ]; then
        return 0
    else
        return 1
    fi
}

check_enabled() {
    cron_str=$(crontab -l)
 
    # Check grep exit status
    if echo "$cron_str" | grep -Eqi "$enable_str"; then
        return 0
    else
        return 1
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        LOGE "Panel is already installed. Do not install again."
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        LOGE "Please install the panel first."
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

show_status() {
    check_status
    case $? in
    0)
        echo -e "Panel status: ${green}Running${plain}"
        show_enable_status
        ;;
    1)
        echo -e "Panel status: ${yellow}Not running${plain}"
        show_enable_status
        ;;
    2)
        echo -e "Panel status: ${red}Not installed${plain}"
        ;;
    esac
    show_xray_status
}

show_enable_status() {
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "Auto-start on boot: ${green}Yes${plain}"
    else
        echo -e "Auto-start on boot: ${red}No${plain}"
    fi
}

check_xray_status() {
    count=$(ps -aux | grep "xray-${release}" | grep -v "grep" | wc -l)
    if [[ count -ne 0 ]]; then
        return 0
    else
        return 1
    fi
}

show_xray_status() {
    check_xray_status
    if [[ $? == 0 ]]; then
        echo -e "xray status: ${green}Running${plain}"
    else
        echo -e "xray status: ${red}Not running${plain}"
    fi
}

show_usage() {
    echo "x-ui management script usage:"
    echo "------------------------------------------"
    echo "/home/${USER}/x-ui.sh              - Show management menu (more features)"
    echo "/home/${USER}/x-ui.sh start        - Start x-ui panel"
    echo "/home/${USER}/x-ui.sh stop         - Stop x-ui panel"
    echo "/home/${USER}/x-ui.sh restart      - Restart x-ui panel"
    echo "/home/${USER}/x-ui.sh status       - View x-ui status"
    echo "/home/${USER}/x-ui.sh enable       - Enable x-ui auto-start on boot"
    echo "/home/${USER}/x-ui.sh disable      - Disable x-ui auto-start on boot"
    echo "/home/${USER}/x-ui.sh update       - Update x-ui panel"
    echo "/home/${USER}/x-ui.sh install      - Install x-ui panel"
    echo "/home/${USER}/x-ui.sh uninstall    - Uninstall x-ui panel"
    echo "------------------------------------------"
}

show_menu() {
    echo -e "
  ${green}x-ui Panel Management Script${plain}
  ${green}0.${plain} Exit script
————————————————
  ${green}1.${plain} Install x-ui
  ${green}2.${plain} Update x-ui
  ${green}3.${plain} Uninstall x-ui
————————————————
  ${green}4.${plain} Reset username and password
  ${green}5.${plain} Reset panel settings
  ${green}6.${plain} Set panel access port
  ${green}7.${plain} View current panel settings
————————————————
  ${green}8.${plain} Start x-ui
  ${green}9.${plain} Stop x-ui
  ${green}10.${plain} Restart x-ui
  ${green}11.${plain} View x-ui status
  ${green}12.${plain} Set traffic monitoring port
————————————————
  ${green}13.${plain} Enable x-ui auto-start on boot
  ${green}14.${plain} Disable x-ui auto-start on boot
————————————————
 "
    show_status
    echo && read -p "Enter your choice [0-14]: " num

    case "${num}" in
    0)
        exit 0
        ;;
    1)
        check_uninstall && install
        ;;
    2)
        check_install && update
        ;;
    3)
        check_install && uninstall
        ;;
    4)
        check_install && reset_user
        ;;
    5)
        check_install && reset_config
        ;;
    6)
        check_install && set_port
        ;;
    7)
        check_install && check_config
        ;;
    8)
        check_install && start
        ;;
    9)
        check_install && stop
        ;;
    10)
        check_install && restart
        ;;
    11)
        check_install && status
        ;;
    12)
        check_install && set_traffic_port
        ;;
    13)
        check_install && enable
        ;;
    14)
        check_install && disable
        ;;
    *)
        LOGE "Please enter a valid number [0-14]"
        ;;
    esac
}

if [[ $# > 0 ]]; then
    case $1 in
    "start")
        check_install 0 && start 0
        ;;
    "stop")
        check_install 0 && stop 0
        ;;
    "restart")
        check_install 0 && restart 0
        ;;
    "status")
        check_install 0 && status 0
        ;;
    "enable")
        check_install 0 && enable 0
        ;;
    "disable")
        check_install 0 && disable 0
        ;;
    "update")
        check_install 0 && update 0
        ;;
    "install")
        check_uninstall 0 && install 0
        ;;
    "uninstall")
        check_install 0 && uninstall 0
        ;;
    *) show_usage ;;
    esac
else
    show_menu
fi
