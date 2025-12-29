# Managing Secrets

Zou uses Docker secrets for sensitive credentials. Secrets are stored as files in the `secrets/` directory and mounted into containers at runtime.

## Required Secrets

1. **secret_key.txt** - JWT token signing key
2. **db_password.txt** - PostgreSQL database password

## Optional Secrets

3. **mail_password.txt** - SMTP password (if using email)
4. **indexer_key.txt** - Meilisearch master key (if using search profile)
5. **saml_idp_certificate.pem** - SAML Identity Provider certificate (if using SSO)

## Setup

1. Create the secrets directory:
```bash
mkdir -p secrets
```

2. Generate and create required secrets:

```bash
# Secret key (JWT signing) - REQUIRED
openssl rand -hex 32 > secrets/secret_key.txt

# Database password - REQUIRED
echo "your-secure-db-password" > secrets/db_password.txt

# Optional: Mail password (if using email)
# Create empty file if not using email, or set password if using
touch secrets/mail_password.txt
# OR: echo "your-smtp-password" > secrets/mail_password.txt

# Optional: Meilisearch key (if using search profile)
# Create empty file if not using search, or set key if using
touch secrets/indexer_key.txt
# OR: openssl rand -hex 32 > secrets/indexer_key.txt

# Optional: SAML IdP certificate (if using SSO)
# Create empty file if not using SSO, or copy your IdP certificate
touch secrets/saml_idp_certificate.pem
# OR: cp /path/to/your-idp-certificate.pem secrets/saml_idp_certificate.pem
```

3. Set proper permissions:
```bash
chmod 600 secrets/*.txt secrets/*.pem
```

**Note:** Docker Compose requires all secret files to exist. Create empty files (`touch`) for optional secrets you're not using.

## Security Notes

- **Never commit secrets to git** - The `secrets/` directory is gitignored
- Secrets are mounted read-only into containers at `/run/secrets/`
- Secrets are only accessible to services that declare them
- Use strong, randomly generated passwords
- Rotate secrets regularly in production

## Using Docker Swarm Secrets

If you're using Docker Swarm, you can create secrets directly:

```bash
# Initialize swarm (if not already)
docker swarm init

# Create secrets
echo "your-secret-key" | docker secret create secret_key -
echo "your-db-password" | docker secret create db_password -
echo "your-mail-password" | docker secret create mail_password -
echo "your-indexer-key" | docker secret create indexer_key -
```

Then update `docker-compose.yml` to use external secrets:

```yaml
secrets:
  secret_key:
    external: true
  db_password:
    external: true
  # ... etc
```

## Rotating Secrets

To rotate a secret:

1. Update the secret file:
```bash
echo "new-secret-value" > secrets/secret_key.txt
```

2. Restart affected services:
```bash
docker compose restart zou zou-events
```

For database password changes, you'll also need to update the postgres service and restart it.

