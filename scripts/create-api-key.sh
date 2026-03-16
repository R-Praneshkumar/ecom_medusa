#!/bin/bash
TOKEN=$(curl -s -X POST http://localhost:9000/auth/user/emailpass -H "Content-Type: application/json" -d "{\"email\":\"admin@medusa.com\",\"password\":\"supersecret123\"}" | sed 's/.*"token":"\([^"]*\)".*/\1/')
echo "Token: $TOKEN"
RESULT=$(curl -s -X POST http://localhost:9000/admin/api-keys -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Storefront\",\"type\":\"publishable\"}")
echo "Result: $RESULT"
KEY=$(echo $RESULT | sed 's/.*"token":"\([^"]*\)".*/\1/')
echo ""
echo "==============================="
echo "Your publishable key: $KEY"
echo "==============================="
echo ""
echo "Now update .env with this key and restart storefront:"
echo "  sed -i \"s/NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=.*/NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=$KEY/\" /root/medusa/.env"
echo "  cd /root/medusa && docker compose up -d --build storefront"
