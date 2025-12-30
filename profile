# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Configure SSH to use 1Password SSH agent
if [ -S "$HOME/.1password/agent.sock" ]; then
    export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Display system information on login (only runs for login shells)
if [ -n "$BASH_VERSION" ] && [[ $- == *i* ]]; then
    # Function should be available from .bashrc, but define it here if needed
    if ! declare -f display_system_info > /dev/null; then
        display_system_info() {
            # System Information
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS_INFO="$PRETTY_NAME"
            else
                OS_INFO="$(uname -s)"
            fi
            
            # CPU Information
            if [ -f /proc/cpuinfo ]; then
                CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//' | cut -d' ' -f1-4)
                CPU_CORES=$(grep -c "^processor" /proc/cpuinfo)
            fi
            
            # Memory Information
            if [ -f /proc/meminfo ]; then
                TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{printf "%.1f", $2/1024/1024}')
                AVAIL_MEM=$(grep MemAvailable /proc/meminfo | awk '{printf "%.1f", $2/1024/1024}')
                USED_MEM=$(echo "$TOTAL_MEM - $AVAIL_MEM" | bc)
                PERCENT_MEM=$(echo "scale=0; ($USED_MEM / $TOTAL_MEM) * 100" | bc)
            fi
            
            # Disk Usage
            DISK_INFO=$(df -h / | awk 'NR==2 {printf "%s/%s (%s)", $3, $2, $5}')
            HOME_USAGE=$(du -sh "$HOME" 2>/dev/null | cut -f1)
            UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || uptime | awk '{print $3,$4}' | sed 's/,//')
            
            # Battery Status
            BATTERY_INFO=""
            if [ -d /sys/class/power_supply/BAT0 ]; then
                BAT_STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
                BAT_CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
                if [ -n "$BAT_CAPACITY" ]; then
                    BATTERY_INFO=" | Battery: ${BAT_CAPACITY}% ($BAT_STATUS)"
                fi
            fi
            
            echo ""
            echo -e "\033[1;36m═══════════════════════════════════════════════════════\033[0m"
            echo -e "\033[1;36mSystem:\033[0m $OS_INFO | Kernel: $(uname -r) | Arch: $(uname -m)$BATTERY_INFO"
            echo -e "\033[1;36mCPU:\033[0m $CPU_MODEL ($CPU_CORES cores)"
            echo -e "\033[1;36mMemory:\033[0m ${USED_MEM}GB/${TOTAL_MEM}GB used (${PERCENT_MEM}%) | Available: ${AVAIL_MEM}GB"
            echo -e "\033[1;36mDisk:\033[0m Root: $DISK_INFO | Home: $HOME_USAGE"
            echo -e "\033[1;36mUptime:\033[0m $UPTIME | User: $(whoami)@$(hostname) | $(date '+%Y-%m-%d %H:%M:%S')"
            echo -e "\033[1;36m═══════════════════════════════════════════════════════\033[0m"
            echo ""
        }
    fi
    display_system_info  # Commented out - function available but won't auto-run
fi
. "$HOME/.cargo/env"
