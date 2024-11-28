# VSFTPD Docker Container

## Introduction

This repository provides a Dockerized setup for running VSFTPD (Very Secure FTP Daemon) in a container using Docker and Docker Compose. VSFTPD is a popular FTP server software that offers secure and efficient file transfer capabilities.

The goal of this project is to simplify the process of setting up a VSFTPD server by encapsulating it within a Docker container. By using Docker and Docker Compose, you can easily deploy and manage the VSFTPD server in any environment that supports Docker.

<!-- TOC -->

- [VSFTPD Docker Container](#vsftpd-docker-container)
  - [Introduction](#introduction)
  - [TL;DR](#tldr)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
      - [Step-by-Step Guide](#step-by-step-guide)
  - [Accessing the VSFTPD server](#accessing-the-vsftpd-server)
  - [Accessing VSFTP Server from Mac using ncftp client](#accessing-vsftp-server-from-mac-using-ncftp-client)
  - [Using VSFTPD with Traefik](#using-vsftpd-with-traefik)
    - [Example Traefik Configuration](#example-traefik-configuration)
    - [Steps to Enable Traefik Integration](#steps-to-enable-traefik-integration)
  - [Accessing the VSFTPD server using your Printer](#accessing-the-vsftpd-server-using-your-printer)
    - [Brother printer MFC-J6930DW](#brother-printer-mfc-j6930dw)
      - [Setting up your Brother Printer](#setting-up-your-brother-printer)
  - [Contributing](#contributing)
  - [Licenses](#licenses)

<!-- /TOC -->

## TL;DR

To quickly get started, follow these steps:

1. Install Docker and Docker Compose on your system.
2. Clone this repository: git clone https://github.com/sophophilix/docker-vsftpd-container
3. Navigate to the repository's directory: cd `docker-vsftpd-container`
4. Create a `.env` file based on the provided `.env-template` file and configure the necessary environment variables.
5. Build and run the VSFTPD container: `docker-compose up -d`
6. The VSFTPD server should now be up and running.

For detailed instructions and configuration options, please refer to the "Getting Started" section below.

## Getting Started

### Prerequisites

Before proceeding, ensure that you have the following prerequisites installed on your system:

    Docker: Install Docker
    Docker Compose: Install Docker Compose

#### Step-by-Step Guide

To set up and run the VSFTPD server using Docker and Docker Compose, follow these steps:

- Clone this repository to your local machine:

`git clone https://github.com/sophophilix/docker-vsftpd-container`

- Navigate to the repository's directory:

`cd docker-vsftpd-container`

- Create a .env file based on the provided .env-template file. The .env file allows you to configure environment variables for the VSFTPD server. Open the .env-template file and configure the necessary variables. Save the file as .env.

`cp .env-template .env`

- Build and run the VSFTPD container::

  `docker-compose up -d`

  This command will build the Docker image and start the container in detached mode.

- The VSFTPD server is now up and running. You can connect to it using an FTP client and the specified IP address and ports.

## Accessing the VSFTPD server

- You can now access the VSFTPD server by connecting to ftp://localhost using an FTP client.
- The VSFTPD server will also be available at {IP_ADDRESS} from your [env](./.env-template)
- The data volume will be mounted at ${FTP_DATA_PATH} on the host machine.
  For more advanced configuration options and customization, please refer to the VSFTPD documentation.

## Accessing VSFTP Server from Mac using ncftp client

- `brew install ncftp`
- `ncftp -u {FTP_USER} -p {FTP_PASS} {IP_ADDRESS of your VSFTP Server}` all variable values from [env](./.env-template)
- use all regular ftp commands such as put to transfer a file from your mac to the VSFTPD Server, the files will be located at data volume mounted at {FTP_DATA_PATH} on your host machine.

## Using VSFTPD with Traefik

`NOTE`: You need Traefik container setup and running in your environment with certs, e.g letsencrypt 

To use Traefik as a reverse proxy for your VSFTPD server, we have updated the `docker-compose.yml` file with appropriate labels for Traefik. These labels allow Traefik to route HTTP/HTTPS requests to the VSFTPD container.

### Example Traefik Configuration

Ensure your `docker-compose.yml` includes the following labels under the VSFTPD service:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.vsftpd.entrypoints=http"
  - "traefik.http.routers.vsftpd.rule=Host(`vsftpd.local.<your-domain-name>.org`)"
  - "traefik.http.middlewares.vsftpd-https-redirect.redirectscheme.scheme=https"
  - "traefik.http.routers.vsftpd.middlewares=vsftpd-https-redirect"
  - "traefik.http.routers.vsftpd-secure.entrypoints=https"
  - "traefik.http.routers.vsftpd-secure.rule=Host(`vsftpd.local.<your-domain-name>.org`)"
  - "traefik.http.routers.vsftpd-secure.tls=true"
  - "traefik.http.routers.vsftpd-secure.service=vsftpd"
  - "traefik.http.services.vsftpd.loadbalancer.server.port=80"
  - "traefik.docker.network=proxy"
```
### Steps to Enable Traefik Integration

- Network Configuration: Ensure that both the Traefik and VSFTPD containers are connected to the same Docker network, for example, proxy. Define this network in your docker-compose.yml:
```yaml
networks:
  proxy:
    external: true

```
- Update the Domain Name: Replace <your-domain-name> with your actual domain name. Ensure the domain name is correctly configured in your DNS or /etc/hosts for local development.
- Restart Services: Run the following command to restart the VSFTPD container and apply the Traefik configuration:
```bash
docker-compose up -d

```
- Access the VSFTPD Server:
```bash
HTTP: http://<Your_local_IP>.local.<your-domain-name>.org 
If you have a local DNS then you can also access it via the local traefik dns name example if the Local IP of the host points to traefik-dashboard ,we can access it as
```http://traefik-dashboard.local.<your-domain-name>.org``` it will automatically get redirected to https , ensure the lets encrypt certs are configured on traefik.
HTTPS: https://<YOUR_LOCAL_IP>.local.<your-domain-name>.org
```https://traefik-dashboard.local.<your-domain-name>.org``` 
Traefik will handle SSL termination and redirect HTTP traffic to HTTPS automatically.  
```

## Accessing the VSFTPD server using your Printer

### Brother printer MFC-J6930DW

#### Setting up your Brother Printer

- Navigate to your Brother printers IPAddress [http://{Brother-printer-IP}/scan/netscan.html](http://192.168.1.113/scan/netscan.html)
  Example: [http://192.168.1.113/scan/netscan.html](http://192.168.1.113/scan/netscan.html)
- Scan to FTP​/​Network Profile
  ```bash
  Profile Name: SomeName
  Host Address: Your VSFTPD Server IPAddress
  Port Number: 21
  Username: {FTP_USER} from [env](./.env-template)
  Password: {FTP_PASS} from [env](./.env-template)
  SSL/TSL : None ( unless you have enabled it)
  Store Directory: /
  Rest of the settings: As per your needs
  ```

## Contributing

If you find any issues with the Docker image or have suggestions for improvement, feel free to open an issue or submit a pull request. We welcome any contributions that can help make this project better.

## Licenses

This project is licensed under the MIT License. Please see the LICENSE file for more details.

Thank you for choosing the VSFTPD Docker Container! If you have any questions or need further assistance, please don't hesitate to reach out.

Repository: https://github.com/sophophilix/docker-vsftpd-container
