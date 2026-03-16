#!/bin/bash
echo "=== Adding products to Medusa store ==="

TOKEN=$(curl -s -X POST http://localhost:9000/auth/user/emailpass -H "Content-Type: application/json" -d "{\"email\":\"admin@medusa.com\",\"password\":\"supersecret123\"}" | sed 's/.*"token":"\([^"]*\)".*/\1/')
echo "Got token"

# Get sales channel
echo "Getting sales channel..."
SC=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:9000/admin/sales-channels | sed 's/.*"id":"\([^"]*\)".*/\1/')
echo "Sales channel: $SC"

# Get region
echo "Getting region..."
REG=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:9000/admin/regions | sed 's/.*"id":"\([^"]*\)".*/\1/')
echo "Region: $REG"

# Create product category
echo "Creating categories..."
curl -s -X POST http://localhost:9000/admin/product-categories -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"name\":\"Clothing\",\"is_active\":true}" > /dev/null
curl -s -X POST http://localhost:9000/admin/product-categories -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"name\":\"Accessories\",\"is_active\":true}" > /dev/null
curl -s -X POST http://localhost:9000/admin/product-categories -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"name\":\"Electronics\",\"is_active\":true}" > /dev/null
echo "Categories created"

# Create products
echo "Creating products..."

curl -s -X POST http://localhost:9000/admin/products -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Classic White T-Shirt\",\"description\":\"Premium cotton white t-shirt. Comfortable and breathable.\",\"handle\":\"classic-white-tshirt\",\"thumbnail\":\"https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600\",\"images\":[{\"url\":\"https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600\"}],\"status\":\"published\",\"sales_channels\":[{\"id\":\"$SC\"}],\"options\":[{\"title\":\"Size\",\"values\":[\"S\",\"M\",\"L\",\"XL\"]}],\"variants\":[{\"title\":\"S\",\"prices\":[{\"amount\":1999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"S\"},\"manage_inventory\":false},{\"title\":\"M\",\"prices\":[{\"amount\":1999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"M\"},\"manage_inventory\":false},{\"title\":\"L\",\"prices\":[{\"amount\":1999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"L\"},\"manage_inventory\":false}]}" > /dev/null
echo "1. Classic White T-Shirt"

curl -s -X POST http://localhost:9000/admin/products -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Black Leather Jacket\",\"description\":\"Stylish black leather jacket for casual and semi-formal wear.\",\"handle\":\"black-leather-jacket\",\"thumbnail\":\"https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600\",\"images\":[{\"url\":\"https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600\"}],\"status\":\"published\",\"sales_channels\":[{\"id\":\"$SC\"}],\"options\":[{\"title\":\"Size\",\"values\":[\"S\",\"M\",\"L\"]}],\"variants\":[{\"title\":\"S\",\"prices\":[{\"amount\":12999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"S\"},\"manage_inventory\":false},{\"title\":\"M\",\"prices\":[{\"amount\":12999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"M\"},\"manage_inventory\":false},{\"title\":\"L\",\"prices\":[{\"amount\":12999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"L\"},\"manage_inventory\":false}]}" > /dev/null
echo "2. Black Leather Jacket"

curl -s -X POST http://localhost:9000/admin/products -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Running Sneakers\",\"description\":\"Lightweight running sneakers with cushioned sole.\",\"handle\":\"running-sneakers\",\"thumbnail\":\"https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600\",\"images\":[{\"url\":\"https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600\"}],\"status\":\"published\",\"sales_channels\":[{\"id\":\"$SC\"}],\"options\":[{\"title\":\"Size\",\"values\":[\"8\",\"9\",\"10\",\"11\"]}],\"variants\":[{\"title\":\"8\",\"prices\":[{\"amount\":8999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"8\"},\"manage_inventory\":false},{\"title\":\"9\",\"prices\":[{\"amount\":8999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"9\"},\"manage_inventory\":false},{\"title\":\"10\",\"prices\":[{\"amount\":8999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"10\"},\"manage_inventory\":false}]}" > /dev/null
echo "3. Running Sneakers"

curl -s -X POST http://localhost:9000/admin/products -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Wireless Headphones\",\"description\":\"Premium wireless headphones with noise cancellation. 30hr battery.\",\"handle\":\"wireless-headphones\",\"thumbnail\":\"https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600\",\"images\":[{\"url\":\"https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600\"}],\"status\":\"published\",\"sales_channels\":[{\"id\":\"$SC\"}],\"options\":[{\"title\":\"Color\",\"values\":[\"Black\",\"White\",\"Silver\"]}],\"variants\":[{\"title\":\"Black\",\"prices\":[{\"amount\":14999,\"currency_code\":\"usd\"}],\"options\":{\"Color\":\"Black\"},\"manage_inventory\":false},{\"title\":\"White\",\"prices\":[{\"amount\":14999,\"currency_code\":\"usd\"}],\"options\":{\"Color\":\"White\"},\"manage_inventory\":false}]}" > /dev/null
echo "4. Wireless Headphones"

curl -s -X POST http://localhost:9000/admin/products -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Canvas Backpack\",\"description\":\"Spacious canvas backpack with multiple compartments.\",\"handle\":\"canvas-backpack\",\"thumbnail\":\"https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600\",\"images\":[{\"url\":\"https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600\"}],\"status\":\"published\",\"sales_channels\":[{\"id\":\"$SC\"}],\"options\":[{\"title\":\"Color\",\"values\":[\"Olive\",\"Black\",\"Navy\"]}],\"variants\":[{\"title\":\"Olive\",\"prices\":[{\"amount\":4999,\"currency_code\":\"usd\"}],\"options\":{\"Color\":\"Olive\"},\"manage_inventory\":false},{\"title\":\"Black\",\"prices\":[{\"amount\":4999,\"currency_code\":\"usd\"}],\"options\":{\"Color\":\"Black\"},\"manage_inventory\":false}]}" > /dev/null
echo "5. Canvas Backpack"

curl -s -X POST http://localhost:9000/admin/products -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Stainless Steel Watch\",\"description\":\"Elegant minimalist watch. Water-resistant up to 50m.\",\"handle\":\"stainless-steel-watch\",\"thumbnail\":\"https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=600\",\"images\":[{\"url\":\"https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=600\"}],\"status\":\"published\",\"sales_channels\":[{\"id\":\"$SC\"}],\"options\":[{\"title\":\"Color\",\"values\":[\"Silver\",\"Gold\"]}],\"variants\":[{\"title\":\"Silver\",\"prices\":[{\"amount\":19999,\"currency_code\":\"usd\"}],\"options\":{\"Color\":\"Silver\"},\"manage_inventory\":false},{\"title\":\"Gold\",\"prices\":[{\"amount\":22999,\"currency_code\":\"usd\"}],\"options\":{\"Color\":\"Gold\"},\"manage_inventory\":false}]}" > /dev/null
echo "6. Stainless Steel Watch"

curl -s -X POST http://localhost:9000/admin/products -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Aviator Sunglasses\",\"description\":\"Classic aviator sunglasses with UV400 protection.\",\"handle\":\"aviator-sunglasses\",\"thumbnail\":\"https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600\",\"images\":[{\"url\":\"https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600\"}],\"status\":\"published\",\"sales_channels\":[{\"id\":\"$SC\"}],\"options\":[{\"title\":\"Lens\",\"values\":[\"Black\",\"Brown\"]}],\"variants\":[{\"title\":\"Black\",\"prices\":[{\"amount\":3999,\"currency_code\":\"usd\"}],\"options\":{\"Lens\":\"Black\"},\"manage_inventory\":false},{\"title\":\"Brown\",\"prices\":[{\"amount\":3999,\"currency_code\":\"usd\"}],\"options\":{\"Lens\":\"Brown\"},\"manage_inventory\":false}]}" > /dev/null
echo "7. Aviator Sunglasses"

curl -s -X POST http://localhost:9000/admin/products -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"title\":\"Denim Jeans - Slim Fit\",\"description\":\"Classic slim-fit denim jeans. Durable and modern.\",\"handle\":\"denim-jeans-slim\",\"thumbnail\":\"https://images.unsplash.com/photo-1542272604-787c3835535d?w=600\",\"images\":[{\"url\":\"https://images.unsplash.com/photo-1542272604-787c3835535d?w=600\"}],\"status\":\"published\",\"sales_channels\":[{\"id\":\"$SC\"}],\"options\":[{\"title\":\"Size\",\"values\":[\"30\",\"32\",\"34\"]}],\"variants\":[{\"title\":\"30\",\"prices\":[{\"amount\":5999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"30\"},\"manage_inventory\":false},{\"title\":\"32\",\"prices\":[{\"amount\":5999,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"32\"},\"manage_inventory\":false},{\"title\":\"34\",\"prices\":[{\"amount\":6499,\"currency_code\":\"usd\"}],\"options\":{\"Size\":\"34\"},\"manage_inventory\":false}]}" > /dev/null
echo "8. Denim Jeans"

echo ""
echo "=== All 8 products created! ==="
echo "Visit: http://72.60.195.123/us/store"
