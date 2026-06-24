#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║           Eric Tun Installer - HopingBoyz Edition            ║
# ║                  Created by: HopingBoyz                      ║
# ║            YouTube: https://www.youtube.com/@hopingboyz      ║
# ╚══════════════════════════════════════════════════════════════╝

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
SERVICE_DIR="/etc/init.d"
FXTUNNEL_BIN=""

# Helper: map service name to init.d script path
service_file_path() {
    echo "${SERVICE_DIR}/$1"
}

# Helper: check if a service is active via service command
service_is_active() {
    service "$1" status > /dev/null 2>&1
    return $?
}

# Helper: get service status string
service_status_str() {
    if service "$1" status > /dev/null 2>&1; then
        echo "active"
    else
        echo "inactive"
    fi
}

# Function to find fxtunnel binary
find_fxtunnel() {
    if [ -f "/usr/local/bin/fxtunnel" ]; then
        FXTUNNEL_BIN="/usr/local/bin/fxtunnel"
    elif [ -f "/root/.local/bin/fxtunnel" ]; then
        FXTUNNEL_BIN="/root/.local/bin/fxtunnel"
    elif command -v fxtunnel &> /dev/null; then
        FXTUNNEL_BIN=$(command -v fxtunnel)
    else
        FXTUNNEL_BIN=""
    fi
}

# Function to list all fxtunnel init.d services
list_fxtunnel_services() {
    find "$SERVICE_DIR" -maxdepth 1 -name 'fxtunnel-*' -type f 2>/dev/null \
        | xargs -I{} basename {} 2>/dev/null
}

# Write an init.d service script for fxtunnel
write_service_file() {
    local service_name="$1"
    local port="$2"
    local token="$3"
    local bin="$4"
    local file="${SERVICE_DIR}/${service_name}"

    cat > "$file" << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          ${service_name}
# Required-Start:    \$network \$remote_fs
# Required-Stop:     \$network \$remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Eric Tun SSH Tunnel - ${service_name}
### END INIT INFO

DAEMON=${bin}
ARGS="tcp ${port} -t ${token}"
PIDFILE=/var/run/${service_name}.pid
NAME=${service_name}

export HOME=/root
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.local/bin

case "\$1" in
  start)
    echo "Starting \$NAME..."
    start-stop-daemon --start --background --make-pidfile --pidfile \$PIDFILE \\
      --exec \$DAEMON -- \$ARGS
    ;;
  stop)
    echo "Stopping \$NAME..."
    start-stop-daemon --stop --pidfile \$PIDFILE --retry 10
    rm -f \$PIDFILE
    ;;
  restart)
    \$0 stop
    sleep 2
    \$0 start
    ;;
  status)
    if [ -f \$PIDFILE ] && kill -0 \$(cat \$PIDFILE) 2>/dev/null; then
      echo "\$NAME is running (PID \$(cat \$PIDFILE))"
      exit 0
    else
      echo "\$NAME is not running"
      exit 1
    fi
    ;;
  *)
    echo "Usage: \$0 {start|stop|restart|status}"
    exit 1
    ;;
esac
EOF
    chmod +x "$file"
}

# Enable service on boot (update-rc.d or chkconfig)
enable_service_boot() {
    local service_name="$1"
    if command -v update-rc.d &>/dev/null; then
        update-rc.d "$service_name" defaults 2>/dev/null
    elif command -v chkconfig &>/dev/null; then
        chkconfig --add "$service_name" 2>/dev/null
        chkconfig "$service_name" on 2>/dev/null
    fi
}

# Disable service on boot
disable_service_boot() {
    local service_name="$1"
    if command -v update-rc.d &>/dev/null; then
        update-rc.d "$service_name" remove 2>/dev/null
    elif command -v chkconfig &>/dev/null; then
        chkconfig "$service_name" off 2>/dev/null
        chkconfig --del "$service_name" 2>/dev/null
    fi
}

# Function to print banner
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║         ██╗  ██╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗     ║"
    echo "║         ██║  ██║██╔═══██╗██╔══██╗██║████╗  ██║██╔════╝     ║"
    echo "║         ███████║██║   ██║██████╔╝██║██╔██╗ ██║██║  ███╗    ║"
    echo "║         ██╔══██║██║   ██║██╔═══╝ ██║██║╚██╗██║██║   ██║    ║"
    echo "║         ██║  ██║╚██████╔╝██║     ██║██║ ╚████║╚██████╔╝    ║"
    echo "║         ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝     ║"
    echo "║                                                              ║"
    echo "║              ██████╗  ██████╗ ██╗   ██╗███████╗              ║"
    echo "║              ██╔══██╗██╔═══██╗╚██╗ ██╔╝╚══███╔╝              ║"
    echo "║              ██████╔╝██║   ██║ ╚████╔╝   ███╔╝               ║"
    echo "║              ██╔══██╗██║   ██║  ╚██╔╝   ███╔╝                ║"
    echo "║              ██████╔╝╚██████╔╝   ██║   ███████╗              ║"
    echo "║              ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝              ║"
    echo "║                                                              ║"
    echo "║                   Eric Tun Manager v1.0                      ║"
    echo "║           YouTube: https://www.youtube.com/@hopingboyz       ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to print section headers
print_section() {
    echo ""
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}${BOLD}  $1${NC}"
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print info messages
print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}✗ This script must be run as root!${NC}"
        echo -e "${BLUE}ℹ Please run: sudo bash $0${NC}"
        exit 1
    fi
}

# Fix stuck services
fix_stuck_services() {
    print_section "Checking & Fixing Services"

    local stuck_services=""
    while IFS= read -r svc; do
        [ -z "$svc" ] && continue
        if ! service_is_active "$svc"; then
            stuck_services="${stuck_services}${svc}\n"
        fi
    done <<< "$(list_fxtunnel_services)"

    if [ -n "$stuck_services" ]; then
        print_warning "Found services that are not active"
        echo ""

        echo -e "$stuck_services" | while IFS= read -r service; do
            [ -z "$service" ] && continue
            print_info "Fixing: $service"

            service "$service" stop 2>/dev/null
            pkill -f "fxtunnel" 2>/dev/null || true
            sleep 2

            local service_file="${SERVICE_DIR}/${service}"

            if [ -f "$service_file" ]; then
                find_fxtunnel
                if [ -n "$FXTUNNEL_BIN" ]; then
                    local port=$(grep "ARGS=" "$service_file" | grep -oP 'tcp \K[0-9]+' | head -1)
                    local token=$(grep "ARGS=" "$service_file" | grep -oP '-t \K[^\s]+' | head -1)
                    write_service_file "$service" "${port:-22}" "$token" "$FXTUNNEL_BIN"
                    print_success "Updated service file for $service"
                fi
            fi

            service "$service" start 2>/dev/null
            sleep 5

            if service_is_active "$service"; then
                print_success "$service is now ACTIVE ✓"
            else
                print_error "$service still failing - check: service $service status"
            fi
            echo ""
        done
    else
        print_success "No stuck services found"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# Install Eric Tun
install_fxtunnel() {
    print_section "Installing Eric Tun"

    find_fxtunnel
    if [ -n "$FXTUNNEL_BIN" ]; then
        print_info "Eric Tun is already installed at: $FXTUNNEL_BIN"
        read -p "Do you want to reinstall? (y/n): " reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            return
        fi
        rm -f "$FXTUNNEL_BIN"
    fi

    print_info "Downloading and installing Eric Tun..."

    curl -fsSL https://fxtun.dev/install.sh | sh

    if [ $? -eq 0 ]; then
        print_success "Eric Tun installed successfully!"

        find_fxtunnel
        if [ -n "$FXTUNNEL_BIN" ]; then
            print_success "Binary location: $FXTUNNEL_BIN"
        else
            if [ -f "/root/.local/bin/fxtunnel" ]; then
                FXTUNNEL_BIN="/root/.local/bin/fxtunnel"
                chmod +x "$FXTUNNEL_BIN"
            fi
        fi

        print_section "Configuring PATH Environment"
        print_info "Adding /root/.local/bin to PATH..."

        if ! grep -q "/root/.local/bin" /root/.bashrc 2>/dev/null; then
            echo 'export PATH=$PATH:/root/.local/bin' >> /root/.bashrc
            print_success "Added to /root/.bashrc"
        fi

        if ! grep -q "/root/.local/bin" /etc/profile 2>/dev/null; then
            echo 'export PATH=$PATH:/root/.local/bin' >> /etc/profile
        fi

        export PATH=$PATH:/root/.local/bin
        source /root/.bashrc 2>/dev/null || true

        print_success "PATH configured successfully!"

        if [ -x "$FXTUNNEL_BIN" ]; then
            print_success "fxtunnel is executable"
            echo -e "${CYAN}Location: ${YELLOW}$FXTUNNEL_BIN${NC}"
            local version=$("$FXTUNNEL_BIN" --version 2>&1 || echo "version check skipped")
            echo -e "${CYAN}Version: ${YELLOW}$version${NC}"
        else
            print_warning "fxtunnel found but not executable, fixing permissions..."
            chmod +x "$FXTUNNEL_BIN" 2>/dev/null || true
        fi
    else
        print_error "Failed to install Eric Tun"
        print_info "Please check your internet connection and try again"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# Test fxtunnel with token
test_fxtunnel() {
    print_section "Test Eric Tun Connection"

    find_fxtunnel
    if [ -z "$FXTUNNEL_BIN" ]; then
        print_error "Eric Tun not installed!"
        print_info "Please install Eric Tun first (Option 1)"
        sleep 2
        return
    fi

    read -p "Enter token to test: " test_token
    if [ -z "$test_token" ]; then
        print_error "Token cannot be empty!"
        return
    fi

    read -p "Enter port to test (default: 22): " test_port
    test_port=${test_port:-22}

    print_info "Testing connection..."
    print_info "Command: $FXTUNNEL_BIN tcp $test_port -t $test_token"
    echo ""

    timeout 10 "$FXTUNNEL_BIN" tcp "$test_port" -t "$test_token" 2>&1 &
    local pid=$!

    sleep 8

    if kill -0 $pid 2>/dev/null; then
        print_success "Connection test successful! Eric Tun is running"
        kill $pid 2>/dev/null
    else
        print_warning "Connection test completed or failed"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# List all existing services
list_services() {
    print_section "Existing Eric Tun Services"

    local services
    services=$(list_fxtunnel_services)

    if [ -z "$services" ]; then
        print_info "No Eric Tun services found"
    else
        echo -e "${CYAN}${BOLD}Current services:${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────${NC}"

        while IFS= read -r service; do
            [ -z "$service" ] && continue

            local status
            status=$(service_status_str "$service")

            case $status in
                active)
                    status_color="${GREEN}● ACTIVE${NC}"
                    ;;
                *)
                    status_color="${RED}● INACTIVE${NC}"
                    ;;
            esac

            local service_file="${SERVICE_DIR}/${service}"
            local port=$(grep "ARGS=" "$service_file" 2>/dev/null | grep -oP 'tcp \K[0-9]+' | head -1)
            [ -z "$port" ] && port="N/A"

            local token=$(grep "ARGS=" "$service_file" 2>/dev/null | grep -oP '-t \K[^\s]+' | head -1)
            [ -z "$token" ] && token="N/A"

            echo -e "  ${YELLOW}Service:${NC} $service"
            echo -e "  ${YELLOW}Status:${NC}  $status_color"
            echo -e "  ${YELLOW}Port:${NC}    $port"
            echo -e "  ${YELLOW}Token:${NC}   ${token:0:20}..."
            echo -e "${WHITE}────────────────────────────────────────────────────────────${NC}"
        done <<< "$services"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# Create new service
create_service() {
    print_section "Create New Eric Tun Service"

    find_fxtunnel
    if [ -z "$FXTUNNEL_BIN" ]; then
        print_error "Eric Tun not installed!"
        print_info "Please install Eric Tun first (Option 1)"
        sleep 2
        return
    fi

    while true; do
        read -p "Enter service name (e.g., ssh-tunnel): " service_name
        if [[ -z "$service_name" ]]; then
            print_error "Service name cannot be empty"
        elif [[ ! "$service_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_error "Service name can only contain letters, numbers, hyphens and underscores"
        elif [ -f "${SERVICE_DIR}/fxtunnel-${service_name}" ]; then
            print_error "Service name already exists! Please choose another name."
        else
            break
        fi
    done

    while true; do
        read -p "Enter port number to tunnel (default: 22): " port
        port=${port:-22}
        if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
            print_error "Invalid port number! Please enter a number between 1-65535"
        else
            break
        fi
    done

    while true; do
        read -p "Enter your Eric Tun token: " token
        if [[ -z "$token" ]]; then
            print_error "Token cannot be empty"
        else
            break
        fi
    done

    local full_service_name="fxtunnel-${service_name}"

    print_info "Creating service: $full_service_name"
    print_info "Binary: $FXTUNNEL_BIN"
    print_info "Port: $port"
    print_info "Token: ${token:0:10}..."

    write_service_file "$full_service_name" "$port" "$token" "$FXTUNNEL_BIN"

    service "$full_service_name" stop 2>/dev/null
    pkill -f "fxtunnel" 2>/dev/null || true
    sleep 2

    enable_service_boot "$full_service_name"
    service "$full_service_name" start 2>/dev/null

    print_info "Waiting for service to start..."
    sleep 5

    if service_is_active "$full_service_name"; then
        print_success "Service created and running successfully! 🚀"
        echo ""
        echo -e "${GREEN}${BOLD}Service Details:${NC}"
        echo -e "  ${YELLOW}Name:${NC}   $full_service_name"
        echo -e "  ${YELLOW}Port:${NC}   $port"
        echo -e "  ${YELLOW}Token:${NC}  $token"
        echo -e "  ${YELLOW}Status:${NC} ${GREEN}ACTIVE ✓${NC}"
        echo -e "  ${YELLOW}Command:${NC} service $full_service_name status"
    else
        print_error "Service failed to start."
        print_info "Check: service $full_service_name status"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# Edit existing service
edit_service() {
    print_section "Edit Eric Tun Service"

    local services
    services=$(list_fxtunnel_services)

    if [ -z "$services" ]; then
        print_error "No Eric Tun services found!"
        sleep 2
        return
    fi

    echo -e "${CYAN}Available services:${NC}"
    echo ""

    local i=1
    local service_array=()
    while IFS= read -r service; do
        [ -z "$service" ] && continue
        local status
        status=$(service_status_str "$service")
        echo -e "  ${YELLOW}$i)${NC} $service (${status})"
        service_array+=("$service")
        ((i++))
    done <<< "$services"

    echo ""
    read -p "Select service to edit (1-${#service_array[@]}): " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#service_array[@]} ]; then
        print_error "Invalid selection!"
        sleep 2
        return
    fi

    local selected_service="${service_array[$selection-1]}"
    local service_file="${SERVICE_DIR}/${selected_service}"

    print_info "Editing: $selected_service"
    echo ""

    local current_port=$(grep "ARGS=" "$service_file" | grep -oP 'tcp \K[0-9]+' | head -1)
    local current_token=$(grep "ARGS=" "$service_file" | grep -oP '-t \K[^\s]+' | head -1)

    echo -e "${CYAN}Current configuration:${NC}"
    echo -e "  Port: ${YELLOW}$current_port${NC}"
    echo -e "  Token: ${YELLOW}${current_token:0:15}...${NC}"
    echo ""

    read -p "Enter new port number (leave blank to keep $current_port): " new_port
    read -p "Enter new token (leave blank to keep current): " new_token

    new_port=${new_port:-$current_port}
    new_token=${new_token:-$current_token}

    print_info "Stopping service..."
    service "$selected_service" stop 2>/dev/null
    pkill -f "fxtunnel" 2>/dev/null || true
    sleep 2

    find_fxtunnel
    if [ -n "$FXTUNNEL_BIN" ]; then
        write_service_file "$selected_service" "$new_port" "$new_token" "$FXTUNNEL_BIN"
    fi

    service "$selected_service" start 2>/dev/null
    sleep 5

    if service_is_active "$selected_service"; then
        print_success "Service updated and running! ✓"
    else
        print_warning "Service updated but may not be running"
        print_info "Check: service $selected_service status"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# Delete service
delete_service() {
    print_section "Delete Eric Tun Service"

    local services
    services=$(list_fxtunnel_services)

    if [ -z "$services" ]; then
        print_error "No Eric Tun services found!"
        sleep 2
        return
    fi

    echo -e "${CYAN}Available services:${NC}"
    echo ""

    local i=1
    local service_array=()
    while IFS= read -r service; do
        [ -z "$service" ] && continue
        local status
        status=$(service_status_str "$service")
        echo -e "  ${YELLOW}$i)${NC} $service (${status})"
        service_array+=("$service")
        ((i++))
    done <<< "$services"

    echo ""
    read -p "Select service to delete (1-${#service_array[@]}): " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#service_array[@]} ]; then
        print_error "Invalid selection!"
        sleep 2
        return
    fi

    local selected_service="${service_array[$selection-1]}"

    echo ""
    read -p "$(echo -e ${RED}"DELETE $selected_service? This cannot be undone! (y/n): "${NC})" confirm

    if [[ $confirm =~ ^[Yy]$ ]]; then
        print_info "Stopping and removing $selected_service..."

        service "$selected_service" stop 2>/dev/null
        pkill -f "fxtunnel" 2>/dev/null || true
        disable_service_boot "$selected_service"

        rm -f "${SERVICE_DIR}/${selected_service}"
        rm -f "/var/run/${selected_service}.pid"

        print_success "Service deleted permanently! ✓"
    else
        print_info "Deletion cancelled"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# View service logs
view_logs() {
    print_section "View Eric Tun Service Logs"

    local services
    services=$(list_fxtunnel_services)

    if [ -z "$services" ]; then
        print_error "No Eric Tun services found!"
        sleep 2
        return
    fi

    echo -e "${CYAN}Available services:${NC}"
    echo ""

    local i=1
    local service_array=()
    while IFS= read -r service; do
        [ -z "$service" ] && continue
        echo -e "  ${YELLOW}$i)${NC} $service"
        service_array+=("$service")
        ((i++))
    done <<< "$services"

    echo ""
    read -p "Select service for logs (1-${#service_array[@]}): " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#service_array[@]} ]; then
        print_error "Invalid selection!"
        sleep 2
        return
    fi

    local selected_service="${service_array[$selection-1]}"

    echo ""
    echo -e "${CYAN}${BOLD}Logs for: ${YELLOW}$selected_service${NC}"
    echo -e "${PURPLE}Press Ctrl+C to exit log view${NC}"
    echo ""
    sleep 1

    # Use /var/log/syslog or /var/log/messages depending on distro
    local logfile=""
    if [ -f /var/log/syslog ]; then
        logfile="/var/log/syslog"
    elif [ -f /var/log/messages ]; then
        logfile="/var/log/messages"
    fi

    if [ -n "$logfile" ]; then
        tail -f "$logfile" | grep --line-buffered "$selected_service"
    else
        print_warning "No suitable log file found. Showing service status:"
        service "$selected_service" status
    fi
}

# Manage service (Start/Stop/Restart)
manage_service() {
    print_section "Service Management"

    local services
    services=$(list_fxtunnel_services)

    if [ -z "$services" ]; then
        print_error "No Eric Tun services found!"
        sleep 2
        return
    fi

    echo -e "${CYAN}Available services:${NC}"
    echo ""

    local i=1
    local service_array=()
    while IFS= read -r service; do
        [ -z "$service" ] && continue
        local status
        status=$(service_status_str "$service")
        if [ "$status" = "active" ]; then
            status_color="${GREEN}$status${NC}"
        else
            status_color="${RED}$status${NC}"
        fi
        echo -e "  ${YELLOW}$i)${NC} $service (${status_color})"
        service_array+=("$service")
        ((i++))
    done <<< "$services"

    echo ""
    read -p "Select service (1-${#service_array[@]}): " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#service_array[@]} ]; then
        print_error "Invalid selection!"
        sleep 2
        return
    fi

    local selected_service="${service_array[$selection-1]}"

    echo ""
    echo -e "${CYAN}Manage: ${YELLOW}$selected_service${NC}"
    echo -e "${WHITE}────────────────────────${NC}"
    echo -e "  ${YELLOW}1)${NC} Start"
    echo -e "  ${YELLOW}2)${NC} Stop"
    echo -e "  ${YELLOW}3)${NC} Restart"
    echo -e "  ${YELLOW}4)${NC} Enable on boot"
    echo -e "  ${YELLOW}5)${NC} Disable on boot"
    echo -e "  ${YELLOW}6)${NC} Show status"
    echo ""
    read -p "Select action (1-6): " action

    case $action in
        1)
            service "$selected_service" stop 2>/dev/null
            pkill -f "fxtunnel" 2>/dev/null || true
            sleep 1
            service "$selected_service" start
            sleep 3
            if service_is_active "$selected_service"; then
                print_success "Started successfully ✓"
            else
                print_error "Failed to start"
            fi
            ;;
        2)
            service "$selected_service" stop 2>/dev/null
            pkill -f "fxtunnel" 2>/dev/null || true
            sleep 1
            print_success "Stopped ✓"
            ;;
        3)
            service "$selected_service" restart
            sleep 3
            if service_is_active "$selected_service"; then
                print_success "Restarted successfully ✓"
            else
                print_error "Failed to restart"
            fi
            ;;
        4)
            enable_service_boot "$selected_service"
            print_success "Enabled on boot ✓"
            ;;
        5)
            disable_service_boot "$selected_service"
            print_success "Disabled on boot ✓"
            ;;
        6)
            service "$selected_service" status
            ;;
        *)
            print_error "Invalid action!"
            ;;
    esac

    echo ""
    read -p "Press Enter to continue..."
}

# Show Eric Tun servers
show_servers() {
    print_section "Eric Tun Available Servers"

    echo -e "${CYAN}${BOLD}Global Server Regions:${NC}"
    echo ""
    echo -e "${WHITE}────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${GREEN}●${NC} ${WHITE}US East (N. Virginia)${NC}      ${YELLOW}us-east-1.fxtun.dev${NC}"
    echo -e "  ${GREEN}●${NC} ${WHITE}US West (Oregon)${NC}           ${YELLOW}us-west-2.fxtun.dev${NC}"
    echo -e "  ${GREEN}●${NC} ${WHITE}Europe (Ireland)${NC}           ${YELLOW}eu-west-1.fxtun.dev${NC}"
    echo -e "  ${GREEN}●${NC} ${WHITE}Europe (Frankfurt)${NC}         ${YELLOW}eu-central-1.fxtun.dev${NC}"
    echo -e "  ${GREEN}●${NC} ${WHITE}Asia Pacific (Singapore)${NC}   ${YELLOW}ap-southeast-1.fxtun.dev${NC}"
    echo -e "  ${GREEN}●${NC} ${WHITE}Asia Pacific (Tokyo)${NC}       ${YELLOW}ap-northeast-1.fxtun.dev${NC}"
    echo -e "  ${GREEN}●${NC} ${WHITE}South America (Sao Paulo)${NC}  ${YELLOW}sa-east-1.fxtun.dev${NC}"
    echo -e "${WHITE}────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${CYAN}Connection Formats:${NC}"
    echo -e "  ${YELLOW}TCP:${NC}   tcp://{region}.fxtun.dev:{port}"
    echo -e "  ${YELLOW}HTTP:${NC}  https://{region}.fxtun.dev"
    echo -e "  ${YELLOW}UDP:${NC}   udp://{region}.fxtun.dev:{port}"
    echo ""
    echo -e "${CYAN}Example:${NC}"
    echo -e "  fxtunnel tcp 22 -t YOUR_TOKEN"

    echo ""
    read -p "Press Enter to continue..."
}

# Create bulk services
create_bulk_services() {
    print_section "Create Multiple Services (Bulk)"

    find_fxtunnel
    if [ -z "$FXTUNNEL_BIN" ]; then
        print_error "Eric Tun not installed!"
        print_info "Please install Eric Tun first (Option 1)"
        return
    fi

    read -p "Enter token for all services: " token
    if [ -z "$token" ]; then
        print_error "Token cannot be empty!"
        return
    fi

    read -p "Enter starting port number: " start_port
    read -p "Enter ending port number: " end_port

    if ! [[ "$start_port" =~ ^[0-9]+$ ]] || ! [[ "$end_port" =~ ^[0-9]+$ ]]; then
        print_error "Ports must be numbers!"
        return
    fi

    if [ "$start_port" -gt "$end_port" ]; then
        print_error "Start port must be less than end port!"
        return
    fi

    read -p "Enter base service name (default: tunnel): " base_name
    base_name=${base_name:-tunnel}

    local total=$((end_port - start_port + 1))
    echo ""
    echo -e "${CYAN}Creating $total services from port $start_port to $end_port...${NC}"
    echo ""

    local success_count=0
    local fail_count=0

    for port in $(seq "$start_port" "$end_port"); do
        local service_name="fxtunnel-${base_name}-${port}"

        write_service_file "$service_name" "$port" "$token" "$FXTUNNEL_BIN"

        enable_service_boot "$service_name"
        service "$service_name" start 2>/dev/null

        sleep 1

        if service_is_active "$service_name"; then
            echo -e "  ${GREEN}✓${NC} $service_name (Port: $port) - ACTIVE"
            ((success_count++))
        else
            echo -e "  ${RED}✗${NC} $service_name (Port: $port) - Check: service $service_name status"
            ((fail_count++))
        fi
    done

    echo ""
    echo -e "${GREEN}${BOLD}Success: $success_count services${NC}"
    if [ $fail_count -gt 0 ]; then
        echo -e "${RED}${BOLD}Failed: $fail_count services${NC}"
        echo -e "${CYAN}Use Option 10 to fix failed services${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# One-click fix for all services
fix_all_services() {
    print_section "Fix All Eric Tun Services"

    find_fxtunnel
    if [ -z "$FXTUNNEL_BIN" ]; then
        print_error "Eric Tun not installed! Cannot fix services."
        print_info "Please install Eric Tun first (Option 1)"
        sleep 2
        return
    fi

    print_info "Using fxtunnel binary: $FXTUNNEL_BIN"
    echo ""

    local services
    services=$(list_fxtunnel_services)

    if [ -z "$services" ]; then
        print_error "No Eric Tun services found to fix!"
        sleep 2
        return
    fi

    print_info "Fixing all services..."
    echo ""

    while IFS= read -r service; do
        [ -z "$service" ] && continue
        print_info "Processing: $service"

        service "$service" stop 2>/dev/null
        pkill -f "fxtunnel" 2>/dev/null || true
        sleep 2

        local service_file="${SERVICE_DIR}/${service}"

        if [ -f "$service_file" ]; then
            local port=$(grep "ARGS=" "$service_file" | grep -oP 'tcp \K[0-9]+' | head -1)
            local token=$(grep "ARGS=" "$service_file" | grep -oP '-t \K[^\s]+' | head -1)
            [ -z "$port" ] && port=22

            write_service_file "$service" "$port" "$token" "$FXTUNNEL_BIN"
            print_success "Updated config for $service"
        fi

        enable_service_boot "$service"
        service "$service" start 2>/dev/null &

        sleep 3

        if service_is_active "$service"; then
            echo -e "  ${GREEN}✓ $service - ACTIVE${NC}"
        else
            echo -e "  ${RED}✗ $service - INACTIVE${NC}"
            print_info "  Check: service $service status"
        fi
        echo ""
    done <<< "$services"

    echo ""
    print_success "All services processed!"
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu
main_menu() {
    while true; do
        print_banner

        find_fxtunnel
        if [ -n "$FXTUNNEL_BIN" ]; then
            echo -e "  ${GREEN}● Eric Tun: Installed (${FXTUNNEL_BIN})${NC}"
        else
            echo -e "  ${RED}● Eric Tun: Not Installed${NC}"
        fi

        local service_count
        service_count=$(list_fxtunnel_services | grep -c . || echo "0")
        echo -e "  ${CYAN}● Active Services: $service_count${NC}"
        echo ""

        echo -e "${CYAN}${BOLD}Main Menu:${NC}"
        echo -e "${WHITE}────────────────────────────────────────────────────────────${NC}"
        echo -e "  ${YELLOW}1)${NC}  Install/Update Eric Tun"
        echo -e "  ${YELLOW}2)${NC}  Create New Service"
        echo -e "  ${YELLOW}3)${NC}  List All Services"
        echo -e "  ${YELLOW}4)${NC}  Edit Service"
        echo -e "  ${YELLOW}5)${NC}  Delete Service"
        echo -e "  ${YELLOW}6)${NC}  Manage Services (Start/Stop/Restart)"
        echo -e "  ${YELLOW}7)${NC}  View Service Logs (Live)"
        echo -e "  ${YELLOW}8)${NC}  Show Available Servers"
        echo -e "  ${YELLOW}9)${NC}  Create Bulk Services"
        echo -e "  ${YELLOW}10)${NC} Fix All Services (Repair)"
        echo -e "  ${YELLOW}11)${NC} Test Eric Tun Connection"
        echo -e "  ${YELLOW}0)${NC}  Exit"
        echo -e "${WHITE}────────────────────────────────────────────────────────────${NC}"
        echo ""
        read -p "$(echo -e ${CYAN}"Enter choice [0-11]: "${NC})" choice

        case $choice in
            1) install_fxtunnel ;;
            2) create_service ;;
            3) list_services ;;
            4) edit_service ;;
            5) delete_service ;;
            6) manage_service ;;
            7) view_logs ;;
            8) show_servers ;;
            9) create_bulk_services ;;
            10) fix_all_services ;;
            11) test_fxtunnel ;;
            0)
                print_banner
                echo -e "${GREEN}${BOLD}Thank you for using HopingBoyz Eric Tun Manager!${NC}"
                echo -e "${CYAN}YouTube: https://www.youtube.com/@hopingboyz${NC}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option! Please select 0-11"
                sleep 2
                ;;
        esac
    done
}

# Main execution
check_root
main_menu
