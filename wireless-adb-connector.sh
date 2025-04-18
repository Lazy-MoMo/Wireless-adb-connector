#!/bin/bash

# Wireless ADB Connection Script
# This script automatically connects to an Android device via wireless debugging

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DEVICE_NAME="Mi Note 10 Lite" # Change this to a unique identifier for your device
CONFIG_FILE="$HOME/.wireless_adb_config"
PORT="5555" # Default ADB wireless debugging port

echo -e "${BLUE}Wireless ADB Connection Tool${NC}"

# Check if ADB is installed
if ! command -v adb &>/dev/null; then
  echo -e "${RED}Error: ADB is not installed.${NC}"
  echo "Install ADB with:"
  echo "  sudo apt install adb    # For Debian/Ubuntu"
  echo "  sudo pacman -S android-tools  # For Arch"
  echo "  sudo dnf install android-tools  # For Fedora"
  exit 1
fi

# Function to save device IP to config file
save_device_ip() {
  local device_ip=$1
  echo "DEVICE_IP=$device_ip" >"$CONFIG_FILE"
  echo -e "${GREEN}Device IP saved: $device_ip${NC}"
}

# Check if device is already connected via USB
check_usb_connection() {
  echo -e "${YELLOW}Checking USB connection...${NC}"
  local devices=$(adb devices | grep -v "List" | grep -v "^$")
  if [ -z "$devices" ]; then
    echo -e "${RED}No devices connected via USB.${NC}"
    return 1
  else
    echo -e "${GREEN}Device connected via USB:${NC}"
    echo "$devices"
    return 0
  fi
}

# Get device IP address when connected via USB
get_device_ip() {
  echo -e "${YELLOW}Getting device IP address...${NC}"
  local ip=$(adb shell ip addr show wlan0 | grep "inet\s" | awk '{print $2}' | awk -F'/' '{print $1}')
  if [ -z "$ip" ]; then
    sleep 2 # Add retry delay
    ip=$(adb shell ip addr show | grep -A2 wlan | grep "inet\s" | awk '{print $2}' | awk -F'/' '{print $1}')
  fi

  if [ -z "$ip" ]; then
    echo -e "${RED}Failed to retrieve device IP address.${NC}"
    return 1
  else
    echo -e "${GREEN}Device IP: $ip${NC}"
    save_device_ip "$ip"
    return 0
  fi
}

# Connect to device wirelessly
connect_wireless() {
  local device_ip=$1

  # Check if device is already connected wirelessly
  local connected=$(adb devices | grep "$device_ip")
  if [ ! -z "$connected" ]; then
    echo -e "${GREEN}Device already connected wirelessly.${NC}"
    return 0
  fi

  echo -e "${YELLOW}Connecting to device at $device_ip:$PORT...${NC}"
  adb connect "$device_ip:$PORT"

  # Verify connection
  connected=$(adb devices | grep "$device_ip")
  if [ -z "$connected" ]; then
    echo -e "${RED}Failed to connect wirelessly.${NC}"
    return 1
  else
    echo -e "${GREEN}Successfully connected to $device_ip:$PORT${NC}"
    return 0
  fi
}

# Setup wireless debugging if connected via USB
setup_wireless() {
  echo -e "${YELLOW}Setting up wireless debugging...${NC}"

  # Check if tcpip is already enabled
  echo -e "${YELLOW}Enabling TCP/IP mode on port $PORT...${NC}"
  local retries=3
  while [ $retries -gt 0 ]; do
    adb tcpip "$PORT" && break
    retries=$((retries - 1))
    echo -e "${YELLOW}Retrying to enable TCP/IP mode... ($retries retries left)${NC}"
    sleep 3
  done

  if [ $retries -eq 0 ]; then
    echo -e "${RED}Failed to set up TCP/IP on port $PORT.${NC}"
    return 1
  fi

  echo -e "${GREEN}TCP/IP enabled on port $PORT.${NC}"
  sleep 5 # Add delay to allow device to restart in TCP mode
  return 0
}

# Main script

# First, try to read saved IP from config file
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
  echo -e "${BLUE}Found saved device IP: $DEVICE_IP${NC}"

  # Try to connect with saved IP
  connect_wireless "$DEVICE_IP"

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Connection established with saved IP.${NC}"
    exit 0
  else
    echo -e "${YELLOW}Failed to connect with saved IP. Trying USB connection...${NC}"
  fi
fi

# If no saved IP or connection failed, try USB
if check_usb_connection; then
  setup_wireless
  if [ $? -eq 0 ]; then
    if get_device_ip; then
      # Disconnect USB (optional - uncomment if needed)
      # echo -e "${YELLOW}You can now disconnect the USB cable.${NC}"
      sleep 2
      connect_wireless "$DEVICE_IP"
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}Wireless debugging setup complete!${NC}"
        exit 0
      fi
    fi
  fi
fi

# If we get here, all attempts failed
echo -e "${RED}Failed to establish wireless debugging connection.${NC}"
echo -e "${YELLOW}Troubleshooting tips:${NC}"
echo "1. Ensure USB debugging is enabled on your device"
echo "2. Make sure your device and computer are on the same network"
echo "3. Try reconnecting the USB cable and running this script again"
echo "4. Verify that wireless debugging is enabled in developer options"
exit 1
