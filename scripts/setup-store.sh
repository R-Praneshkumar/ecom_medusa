#!/bin/bash
echo "=== Setting up Medusa store ==="

# Get token
TOKEN=$(curl -s -X POST http://localhost:9000/auth/user/emailpass -H "Content-Type: application/json" -d "{\"email\":\"admin@medusa.com\",\"password\":\"supersecret123\"}" | sed 's/.*"token":"\([^"]*\)".*/\1/')
echo "Got auth token"

# Create region
echo "Creating US region..."
curl -s -X POST http://localhost:9000/admin/regions -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"name\":\"United States\",\"currency_code\":\"usd\",\"countries\":[\"us\"],\"payment_providers\":[\"pp_system_default\"]}"
echo ""

# Create sales channel
echo "Creating sales channel..."
curl -s -X POST http://localhost:9000/admin/sales-channels -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"name\":\"Default\",\"description\":\"Default sales channel\"}"
echo ""

echo ""
echo "=== Done! Now restart storefront ==="
echo "Run: docker compose restart storefront"
