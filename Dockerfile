FROM python:3.12-slim-bookworm

# Install runtime dependencies only (no build tools needed - pip uses wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    curl \
    ca-certificates \
    xmlsec1 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash zou

WORKDIR /app

# Copy package files
COPY setup.cfg setup.py pyproject.toml README.rst LICENSE ./
COPY zou/__init__.py zou/__init__.py

# Install Python dependencies (uses binary wheels, no compilation needed)
RUN pip install --no-cache-dir -e .[prod]

# Copy application code
COPY --chown=zou:zou zou/ zou/
COPY --chown=zou:zou entrypoint.sh /app/entrypoint.sh

RUN mkdir -p /app/previews /app/tmp /app/plugins \
    && chown -R zou:zou /app \
    && chmod +x /app/entrypoint.sh

USER zou

ENV PREVIEW_FOLDER=/app/previews \
    TMP_DIR=/app/tmp \
    PLUGIN_FOLDER=/app/plugins \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["gunicorn", \
    "--bind", "0.0.0.0:5000", \
    "--workers", "4", \
    "--worker-class", "gevent", \
    "--timeout", "120", \
    "--keep-alive", "5", \
    "--max-requests", "1000", \
    "--max-requests-jitter", "50", \
    "--access-logfile", "-", \
    "--error-logfile", "-", \
    "--capture-output", \
    "zou.app:app"]
