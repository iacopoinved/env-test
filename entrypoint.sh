#!/bin/sh
set -e

DIST=/app/dist

# ---------------------------------------------------------------------------
# Runtime env injection
#
# Variables listed here are read from the container environment at startup
# and written into /env-config.js so the React app can access them via
# window.__ENV__ regardless of whether they were set during build.
#
# This is the KEY mechanism to support Railway env vars that are set AFTER
# the image is built (e.g. shared variables, secrets rotated at deploy time).
# ---------------------------------------------------------------------------

echo "Injecting runtime env vars into ${DIST}/env-config.js ..."

cat > "${DIST}/env-config.js" << EOF
window.__ENV__ = {
  VITE_TEST_BUILDTIME: "${VITE_TEST_BUILDTIME:-}",
  VITE_TEST_RUNTIME: "${VITE_TEST_RUNTIME:-}",
  VITE_APP_URL: "${VITE_APP_URL:-}",
};
EOF

echo "env-config.js written:"
cat "${DIST}/env-config.js"


PORT=${PORT:-8080}
echo "Starting nginx on port ${PORT}..."

# Write nginx config inline so we don't depend on the file being copied
mkdir -p /var/log/nginx /var/run
cat > /tmp/nginx.conf << NGINXEOF
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/javascript;
    server {
        listen ${PORT};
        root /app/dist;
        index index.html;
        location = /env-config.js {
            add_header Cache-Control "no-store, no-cache, must-revalidate";
        }
        location / {
            try_files \$uri \$uri/ /index.html;
            add_header Cache-Control "no-store";
        }
    }
}
NGINXEOF

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
echo "nginx binary: $(which nginx 2>/dev/null || echo NOT FOUND, trying /usr/sbin/nginx)"
exec /usr/sbin/nginx -g 'daemon off;' -c /tmp/nginx.conf
