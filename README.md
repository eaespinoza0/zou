![Kitsu Logo](https://zou.cg-wire.com/kitsu.png)

# Zou, the Kitsu API is the memory of your animation production

The Kitsu API allows to store and manage the data of your animation/VFX
production. Through it, you can link all the tools of your pipeline and make
sure they are all synchronized.

A dedicated Python client, [Gazu](https://gazu.cg-wire.com), allows users to
integrate Zou into the tools.

[![CI badge](https://github.com/cgwire/zou/actions/workflows/ci.yml/badge.svg)](https://github.com/cgwire/zou/actions/workflows/ci.yml) [![Downloads badge](https://static.pepy.tech/personalized-badge/zou?period=total&units=international_system&left_color=grey&right_color=orange&left_text=Downloads)](https://pepy.tech/project/zou) [![Discord badge](https://badgen.net/badge/icon/discord?icon=discord&label)](https://discord.com/invite/VbCxtKN)

## Features

Zou can:

- Store production data, such as projects, shots, assets, tasks, and file metadata.
- Track the progress of your artists
- Store preview files and version them
- Provide folder and file paths for any task
- Import and Export data to CSV files
- Publish an event stream of changes

## Quick Start (Docker)

### 1. Setup secrets

```bash
mkdir -p secrets

# Required
openssl rand -hex 32 > secrets/secret_key.txt
echo "your-db-password" > secrets/db_password.txt

# Optional (create empty if not using)
touch secrets/mail_password.txt

# For Meilisearch (must be at least 16 bytes)
openssl rand -base64 32 > secrets/indexer_key.txt

chmod 600 secrets/*.txt
```

See [SECRETS.md](SECRETS.md) for detailed secret management.

### 2. Start services

```bash
docker compose up -d
```

### 3. Initialize database (first time only)

```bash
docker compose --profile init up zou-init
```

### 4. Create admin user

```bash
docker compose exec zou /app/entrypoint.sh zou create-admin admin@example.com --password 'your-password'
```

### 5. Access API

```bash
curl http://localhost:5000/
# {"api":"Zou","version":"1.0.3"}
```

## Services

| Service     | Description                  | Port     |
|-------------|------------------------------|----------|
| zou         | Main API server              | 5000     |
| zou-events  | WebSocket events (optional)  | 5001     |
| postgres    | Database                     | internal |
| redis       | Cache                        | internal |
| meilisearch | Search (optional)            | 7700     |

## Optional Components

```bash
# WebSocket events server
docker compose --profile events up -d

# Full-text search (set INDEXER_KEY first)
docker compose --profile search up -d

# Both
docker compose --profile events --profile search up -d
```

## Building Images

```bash
# Build locally
docker compose build

# Build and tag for registry
docker build -t your-registry.com/zou:v1.0.0 .
docker push your-registry.com/zou:v1.0.0
```

### Multiplatform Builds

Build for both AMD64 (Intel/AMD) and ARM64 (Apple Silicon, AWS Graviton):

```bash
# Create builder (one-time setup)
docker buildx create --name multiplatform --use

# Build and push multiplatform image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t your-registry.com/zou:v1.0.0 \
  --push .
```

To build locally for a specific platform (without pushing):

```bash
# Build for ARM64 (e.g., on Apple Silicon)
docker buildx build --platform linux/arm64 -t zou:latest --load .

# Build for AMD64
docker buildx build --platform linux/amd64 -t zou:latest --load .
```

## Using Pre-built Images

Set `ZOU_IMAGE` in `.env`:

```bash
echo "ZOU_IMAGE=your-registry.com/zou:v1.0.0" >> .env
docker compose up -d
```

## Commands

```bash
# View logs
docker compose logs -f zou

# Check status
docker compose ps

# Stop services
docker compose down

# Stop and remove data
docker compose down -v
```

## Configuration

Environment variables can be set in `.env`. See `env.sample` for options.

Key settings:

- `ZOU_PORT` - API port (default: 5000)
- `ZOU_EVENTS_PORT` - Events port (default: 5001)
- `DOMAIN_NAME` - Your domain for email links
- `MAIL_*` - Email configuration

## Storage (Custom Paths)

By default, data is stored in Docker named volumes. To use custom paths (e.g., separate disks), set these in `.env`:

```bash
# PostgreSQL data (use fast SSD)
POSTGRES_DATA_PATH=/mnt/ssd/postgres-data

# Preview files (use large storage)
PREVIEWS_PATH=/mnt/storage/zou-previews

# Temporary files
TMP_PATH=/mnt/fast/zou-tmp

# Plugins
PLUGINS_PATH=/path/to/plugins
```

**Setup directories before starting:**

```bash
# Create directories
mkdir -p /mnt/ssd/postgres-data /mnt/storage/zou-previews

# Set ownership (postgres UID=999, zou UID=1000)
chown -R 999:999 /mnt/ssd/postgres-data
chown -R 1000:1000 /mnt/storage/zou-previews /mnt/fast/zou-tmp
```

## SAML/SSO (Optional)

Zou supports SAML 2.0 for Single Sign-On with identity providers like Google Workspace, Okta, or Azure AD.

### 1. Get your IdP metadata URL

From your Identity Provider's admin console, find the SAML metadata URL:

- **Google Workspace**: `https://accounts.google.com/o/saml2/metadata?idpid=YOUR_IDP_ID`
- **Okta**: `https://your-domain.okta.com/app/YOUR_APP_ID/sso/saml/metadata`
- **Azure AD**: `https://login.microsoftonline.com/TENANT_ID/federationmetadata/2007-06/federationmetadata.xml`

### 2. Configure environment

Add to your `.env`:

```bash
SAML_ENABLED=true
SAML_METADATA_URL=https://accounts.google.com/o/saml2/metadata?idpid=YOUR_IDP_ID
SAML_IDP_NAME=Google
```

### 3. Restart Zou

```bash
docker compose restart zou
```

Users will see a "Login with Google" (or your `SAML_IDP_NAME`) button on the login page.

## Documentation

- API Docs: https://zou.cg-wire.com/
- API Spec: https://api-docs.kitsu.cloud/
- Python Client: [Gazu](https://gazu.cg-wire.com)

## Contributing

Contributions are welcomed so long as the [C4 contract](https://rfc.zeromq.org/spec:42/C4) is respected.

Zou is based on Python and the [Flask](http://flask.pocoo.org/) framework.

You can use the pre-commit hook for Black (a Python code formatter) before committing:

```bash
pip install pre-commit
pre-commit install
```

Instructions for setting up a development environment are available in
[the documentation](https://zou.cg-wire.com/development/)

## Contributors

* @aboellinger (Xilam/Spa)
* @BigRoy (Colorbleed)
* @EvanBldy (CGWire) - *maintainer*
* @ex5 (Blender Studio)
* @flablog (Les Fées Spéciales)
* @frankrousseau (CGWire) - *maintainer*
* @kaamaurice (Tchak)
* @g-Lul (TNZPV)
* @pilou (Freelancer)
* @LedruRollin (Cube-Xilam)
* @mathbou (Zag)
* @manuelrais (TNZPV)
* @NehmatH (CGWire)
* @pcharmoille (Unit Image)
* @Tilix4 (Normaal)

## About authors

Kitsu is written by CGWire, a company based in France. We help with animation and
VFX studios to collaborate better through efficient tooling. We already work
with more than 70 studios around the world.

Visit [cg-wire.com](https://cg-wire.com) for more information.

[![CGWire Logo](https://zou.cg-wire.com/cgwire.png)](https://cgwire.com)

