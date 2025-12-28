# Zou Docker Setup

This repository contains the Zou backend API. The Kitsu frontend runs in a separate repository.

## Building Images

### Build locally

```bash
docker build -t zou:latest .
```

### Build and tag for registry

```bash
# Tag for your registry
docker build -t registry.example.com/zou:v1.0.0 .
docker build -t registry.example.com/zou:latest .

# Push to registry
docker push registry.example.com/zou:v1.0.0
docker push registry.example.com/zou:latest
```

## Running Zou

### Setup

1. Create secrets directory and files:
```bash
mkdir -p secrets

# Generate required secrets
openssl rand -hex 32 > secrets/secret_key.txt
echo "your-secure-db-password" > secrets/db_password.txt

# Set permissions
chmod 600 secrets/*.txt
```

See [SECRETS.md](SECRETS.md) for detailed secret management instructions.

2. Copy environment template (for non-secret config):
```bash
cp env.sample .env
```

3. Edit `.env` and set non-secret values (domain, ports, etc.)

4. Initialize database (first time only):
```bash
docker compose --profile init up zou-init
```

4. Start services:
```bash
docker compose up -d
```

5. Create admin user:
```bash
docker compose exec zou zou create-admin admin@example.com --password 'your-secure-password'
```

### Using Pre-built Images

If you're using images from a registry, set `ZOU_IMAGE` in `.env`:

```bash
ZOU_IMAGE=registry.example.com/zou:v1.0.0
```

Then start without building:
```bash
docker compose up -d
```

### Optional Components

**WebSocket Events Server:**
```bash
docker compose --profile events up -d
```

**Full-text Search (Meilisearch):**
```bash
# Set INDEXER_KEY in .env first
docker compose --profile search up -d
```

**Both:**
```bash
docker compose --profile events --profile search up -d
```

## Services

- **zou** - Main API server (port 5000)
- **zou-events** - WebSocket event stream (port 5001, optional)
- **postgres** - Database (internal network only)
- **redis** - Cache/key-value store (internal network only)
- **meilisearch** - Full-text search (optional)

## Health Checks

All services include health checks. Check status:

```bash
docker compose ps
```

## Logs

View logs:
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f zou
```

## Stopping

```bash
docker compose down

# Remove volumes (WARNING: deletes data)
docker compose down -v
```

