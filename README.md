# Syslog Event Generator

This PowerShell script generates simulated syslog events and sends them to a specified syslog server. It's designed to help test and validate syslog server configurations, SIEM (Security Information and Event Management) systems, or any other log analysis tools that consume syslog data.

## Features

- Generates a variety of syslog messages simulating different system events
- Configurable syslog server address and port
- Randomized message selection for realistic log generation
- Configurable delay between messages to simulate various traffic patterns

## Prerequisites

- PowerShell 5.1 or later
- Network access to the target syslog server

## Installation

1. Clone this repository or download the `eventsgen.ps1` script to your local machine.
2. Ensure that PowerShell execution policy allows running scripts. You may need to run the following command as an administrator:
   ```powershell
   Set-ExecutionPolicy RemoteSigned
   ```

## Configuration

Before running the script, you need to configure the syslog server details:

1. Open the `eventsgen.ps1` file in a text editor.
2. Locate the `Send-SyslogMessage` function.
3. Update the `$SYSLOG_SERVER` and `$SYSLOG_PORT` variables with your syslog server's IP address and port:
   ```powershell
   $SYSLOG_SERVER = '192.168.0.117'  # Replace with your syslog server IP
   $SYSLOG_PORT = 514                # Replace with your syslog server port if different
   ```

## Usage

To run the script, open a PowerShell window and navigate to the directory containing the script. Then execute:

```powershell
.\eventsgen.ps1
```

The script will start generating and sending syslog messages to the configured server. You will see debug output for each message sent.

To stop the script, press `Ctrl+C`.

## Customizing Log Messages

The script comes with a predefined set of log messages. To customize these:

1. Open the `eventsgen.ps1` file in a text editor.
2. Locate the `$special_logs` array in the `Generate-TestLogs` function.
3. Modify, add, or remove entries as needed. Each entry is a hashtable with `Program` and `Message` keys.

Example of adding a new log message:

```powershell
@{Program="custom_app"; Message="Application started successfully"},
```

## Troubleshooting

If you encounter issues:

1. Ensure your firewall allows outbound connections to the syslog server.
2. Verify that the syslog server is running and configured to accept messages.
3. Check the script's debug output for any error messages.

## Contributing

Contributions to improve the script are welcome. Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Disclaimer

This script is for testing and educational purposes only. Ensure you have permission to send data to the target syslog server before using this script.
