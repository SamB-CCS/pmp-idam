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

echo "Setting up database..."
bundle exec rails db:create db:migrate db:seed 2>/dev/null || bundle exec rails db:migrate

echo "Installing i18n-tasks..."
gem install i18n-tasks

echo "Setup complete! Run 'bin/dev' to start the app on port 3000."
echo "Keycloak is available at http://localhost:8080 (admin/admin)"