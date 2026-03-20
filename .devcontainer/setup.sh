#!/bin/bash
set -e

echo "Installing Bun..."
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

echo "Installing Ruby gems..."
bundle install

echo "Installing JS packages with Bun..."
bun install

echo "Writing .env.local..."
cat > /workspace/.env.local << EOF
PGHOST=db
PGPORT=5432
PGUSER=postgres
PGPASSWORD=postgres
DATABASE_URL=postgres://postgres:postgres@db:5432/pmp_idam_development
PRINT_MARKET_PLACE_KEYCLOAK_URL=http://keycloak:8080
BUN_INSTALL=/root/.bun
PATH=/root/.bun/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EOF

echo "Precompiling assets..."
SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

echo "Setting up database..."
bundle exec rails db:create db:migrate

echo "Setup complete! Run 'bin/dev' to start the app on port 3000."
echo "Keycloak is available at http://localhost:8080 (admin/admin)"