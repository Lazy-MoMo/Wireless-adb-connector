j# Wireless ADB Connector

A simple Bash script to automate the process of connecting to an Android device via wireless debugging. This script helps you set up wireless ADB (Android Debug Bridge) by retrieving the device's IP address and establishing a connection.

## Features

- Automatically detects if ADB is installed.
- Checks for USB connection to the Android device.
- Retrieves the device's IP address when connected via USB.
- Saves the device's IP address for future use.
- Establishes a wireless ADB connection.
- Provides troubleshooting tips if the connection fails.

## Requirements

- **ADB (Android Debug Bridge)** must be installed on your system.
  - Install ADB using:
    - Debian/Ubuntu: `sudo apt install adb`
    - Arch Linux: `sudo pacman -S android-tools`
    - Fedora: `sudo dnf install android-tools`
- Your Android device and computer must be on the same Wi-Fi network.
- USB debugging must be enabled on your Android device.

## Installation

1. Clone this repository or download the script:

   ```bash
   git clone https://github.com/Lazy-MoMo/wireless-adb-connector.git
   cd wireless-adb-connector
   ```

2. Make the script executable:

   ```bash
   chmod +x wireless-adb-connector.sh
   ```

## Usage

1. Connect your Android device to your computer via USB.
2. Run the script:

   ```bash
   ./wireless-adb-connector.sh
   ```

3. Follow the on-screen instructions. The script will:

   - Check for USB connection.
   - Retrieve the device's IP address.
   - Enable wireless debugging.
   - Establish a wireless ADB connection.

4. Once connected, you can disconnect the USB cable and continue debugging wirelessly.

## Configuration

The script saves the device's IP address in a configuration file located at:

```
~/.wireless_adb_config
```

This allows the script to reconnect to the device in future runs without requiring a USB connection.

## Troubleshooting

If the script fails to establish a wireless connection, try the following:

1. Ensure USB debugging is enabled on your device.
2. Verify that your device and computer are on the same Wi-Fi network.
3. Reconnect the USB cable and run the script again.
4. Check that wireless debugging is enabled in the developer options on your device.
5. Run in terminal
   
   ```
   adb kill-server
   ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to improve the script.

## Acknowledgments

- Inspired by the need for a simple and automated way to set up wireless ADB connections.
- Thanks to the Android developer community for their helpful resources.

---

Enjoy wireless debugging with ease!
