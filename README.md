# Cloudflare DDNS Update

## Description:
Cloudflare DDNS Update is a dynamic DNS (DDNS) updater script that automatically updates Cloudflare DNS records based on changes to the public IP address. This script is designed to run as a service, continuously monitoring for IP changes and updating DNS records accordingly.

## Features:
- Automatically detects changes in the public IP address.
- Updates Cloudflare DNS records for specified domains.
- Runs as a background service for continuous monitoring.
- Configurable via a JSON configuration file.

## Usage:
1. Clone this repository to your local machine.
2. Customize the `config.json` file with your Cloudflare authentication details and DNS records.
3. Make sure the `cloudflare-ddns-update.sh` script is executable:
   ```bash
   chmod +x cloudflare-ddns-update.sh
   ```
4. Run the `cloudflare-ddns-update.sh` script to start the DDNS updater service.

## Installation:
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/Cloudflare-DDNS-Update.git
   ```
2. Navigate to the project directory:
   ```bash
   cd Cloudflare-DDNS-Update
   ```
3. Customize the configuration file:
   - Open `config.json` in a text editor.
   - Fill in your Cloudflare authentication details and DNS records for each domain.
   - To edit `config.json`, you can use any text editor such as `nano` or `vim`. For example:
     ```bash
     nano config.json
     ```
   - Replace the placeholders with your actual Cloudflare authentication details and DNS records.
   - Save and close the file after editing.
   - Here's how `config.json` looks like:
     ```json
     {
       "cloudflare": {
         "auth_email": "your-email@example.com",
         "auth_method": "token",
         "auth_key": "your-authentication-key"
       },
       "websites": [
         {
           "domain": "example.com",
           "record_name": "example.com",
           "sitename": "Example Website",
           "subdomain": "subdomain.example.com",
           "zone_identifier": "your-zone-identifier",
           "ttl": 3600,
           "proxy": false
         },
         // Add more websites as needed
       ]
     }
     ```

4. Make sure the `cloudflare-ddns-update.sh` script is executable:
   ```bash
   chmod +x cloudflare-ddns-update.sh
   ```
5. Start the DDNS updater service manually:
   ```bash
   sudo ./cloudflare-ddns-update.sh
   ```
6. To run the service in the background and ensure it starts automatically on system boot, create a systemd service file:
   ```bash
   sudo nano /etc/systemd/system/ddns-update.service
   ```
   Paste the following configuration into the file:
   ```plaintext
   [Unit]
   Description=Cloudflare DDNS Update Service
   After=network.target

   [Service]
   Type=simple
   ExecStart=/bin/bash /path/to/Cloudflare-DDNS-Update/cloudflare-ddns-update.sh
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```
   Replace `/path/to/Cloudflare-DDNS-Update/cloudflare-ddns-update.sh` with the actual path to your `cloudflare-ddns-update.sh` script.

7. Save and close the file.
8. Reload systemd to apply changes:
   ```bash
   sudo systemctl daemon-reload
   ```
9. Start the DDNS updater service:
   ```bash
   sudo systemctl start ddns-update
   ```
10. Enable the service to start on boot:
    ```bash
    sudo systemctl enable ddns-update
    ```

Now the DDNS updater service will run in the background, automatically updating Cloudflare DNS records based on changes to the public IP address.

## Managing the Service:
You can manage the service using the following commands:

- To restart the service:
  ```bash
  sudo systemctl restart ddns-update
  ```

- To stop the service:
  ```bash
  sudo systemctl stop ddns-update
  ```

- To check the status of the service:
  ```bash
  sudo systemctl status ddns-update
  ```

## License:
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributions:
Contributions are welcome! Please feel free to open issues or submit pull requests.

## Authors:
- Soufiane Hmiad (@soufianehmiad)

## Acknowledgments:
- Special thanks to Cloudflare for providing an excellent DNS management platform.
