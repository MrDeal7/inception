# Inception

A Docker-based WordPress deployment stack built as part of the 42 School curriculum. It sets up a complete, HTTPS-enabled WordPress environment using three containerized services orchestrated with Docker Compose.

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │           Docker Network             │
                    │                                      │
  HTTPS (443) ───► │  [Nginx]  ──►  [WordPress/PHP-FPM]  │
                    │                      │               │
                    │                      ▼               │
                    │                  [MariaDB]           │
                    └─────────────────────────────────────┘
```

| Service   | Image Base      | Role                                      |
|-----------|-----------------|-------------------------------------------|
| **nginx**     | Debian Bookworm | HTTPS reverse proxy with self-signed SSL  |
| **wordpress** | Debian Bookworm | PHP 8.2 FPM application server            |
| **mariadb**   | Debian Bookworm | Relational database backend               |

- All services run on a private Docker bridge network
- Data is persisted via named volumes on the host machine
- Nginx is the only externally exposed service (port 443)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
- `make`
- A host entry mapping your domain to `127.0.0.1` (see [Configuration](#configuration))

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/MrDeal7/inception.git
cd inception
```

### 2. Configure environment variables

Edit `srcs/.env` to set your credentials and domain:

```env
# Domain (replace with your 42 login, e.g. yourlogin.42.fr)
DOMAIN_NAME=yourlogin.42.fr

# MariaDB
MYSQL_ROOT_PASSWORD=<root_password>
MYSQL_DATABASE=wordpress
MYSQL_USER=<db_user>
MYSQL_PASSWORD=<db_password>

# WordPress admin account
WP_ADMIN=<admin_username>
WP_ADMIN_PASSWORD=<admin_password>
WP_ADMIN_EMAIL=<admin_email>

# WordPress regular user
WP_USER=<username>
WP_USER_PASSWORD=<user_password>
WP_USER_EMAIL=<user_email>
```

### 3. Add a local DNS entry

```bash
# Replace <DOMAIN_NAME> with the value set in srcs/.env
echo "127.0.0.1 <DOMAIN_NAME>" | sudo tee -a /etc/hosts
```

### 4. Build and start the stack

```bash
make
```

The site will be available at **https://\<DOMAIN_NAME\>** once all containers are healthy (accept the self-signed certificate warning in your browser).

## Makefile Targets

| Target      | Description                                              |
|-------------|----------------------------------------------------------|
| `make`      | Build images and start all containers in detached mode   |
| `make down` | Stop and remove containers                               |
| `make re`   | Stop, remove, rebuild, and restart everything            |
| `make clean`| Remove containers, volumes, and all built images         |
| `make prune`| Run `docker system prune -f` to free unused Docker data  |

## Project Structure

```
inception/
├── Makefile
└── srcs/
    ├── .env                          # Environment variables
    ├── docker-compose.yml            # Service orchestration
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf       # Nginx server config (TLS 1.2/1.3 only)
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf         # PHP-FPM pool config
        │   └── tools/wordpress.sh    # WordPress auto-setup script
        └── mariadb/
            ├── Dockerfile
            ├── conf/mysql.conf       # MariaDB server config
            └── tools/mariadb.sh      # Database init script
```

## Volumes

| Volume           | Host Path                    | Container Mount  |
|------------------|------------------------------|------------------|
| `wordpress_data` | `$HOME/data/wordpress`       | WordPress files  |
| `mariadb_data`   | `$HOME/data/mysql`           | Database files   |

## Security Notes

- HTTPS is enforced; plain HTTP is not served.
- TLS 1.2 and TLS 1.3 are the only accepted protocols.
- SSL certificates are self-signed and auto-generated at container startup.
- The MariaDB port is not exposed outside the Docker network.
