#!/bin/bash
set -e

echo "🔑 Checking secrets are available..."
if [ -z "$COGNITO_CLIENT_ID" ]; then
  echo "WARNING: COGNITO_CLIENT_ID is not set - did you add Codespaces secrets?"
else
  echo "Secrets are available"
fi

echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=postgres psql -h db -U postgres -c '\q' 2>/dev/null; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done
echo "PostgreSQL is ready!"

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
COGNITO_CLIENT_ID=${COGNITO_CLIENT_ID}
COGNITO_CLIENT_SECRET=${COGNITO_CLIENT_SECRET}
COGNITO_USER_POOL_ID=${COGNITO_USER_POOL_ID}
COGNITO_AWS_REGION=${COGNITO_AWS_REGION}
AWS_ACCESS_KEY=${AWS_ACCESS_KEY}
AWS_SECRET_KEY=${AWS_SECRET_KEY}
AUTH_USER_API_TOKEN=${AUTH_USER_API_TOKEN}
EOF
echo ".env.local written"

echo "Precompiling assets..."
SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
echo "Assets precompiled"

echo "Setting up database..."
bundle exec rails db:create db:migrate
echo "Database ready"

echo ""
echo "================================================"
echo "Setup complete!"
echo "================================================"
echo "Run 'bin/dev' to start the app on port 3000"
echo "Keycloak available at http://localhost:8080"
echo "   Login: admin / admin"
echo "================================================"