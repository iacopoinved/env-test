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
  VITE_GOOGLE_MAPS_API_KEY: "${VITE_GOOGLE_MAPS_API_KEY:-}",
  VITE_TYPEFORM_URL: "${VITE_TYPEFORM_URL:-}",
  VITE_TYPEFORM_ID: "${VITE_TYPEFORM_ID:-}",
  VITE_APP_SUPERADMIN_EMAIL: "${VITE_APP_SUPERADMIN_EMAIL:-}",
  VITE_HOCUSPOCUS_TOKEN: "${VITE_HOCUSPOCUS_TOKEN:-}",
  VITE_HOCUSPOCUS_CLIENT_TOKEN: "${VITE_HOCUSPOCUS_CLIENT_TOKEN:-}",
};
EOF

echo "env-config.js written:"
cat "${DIST}/env-config.js"


echo "Starting nginx..."
exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
