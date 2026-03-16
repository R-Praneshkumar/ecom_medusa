/**
 * Medusa v2 - Seed Script with Dummy Products
 * Run: npx medusa exec ./scripts/seed-products.ts
 *
 * Creates sample products with free online images
 */

import { ExecArgs } from "@medusajs/framework/types"
import { createProductsWorkflow } from "@medusajs/medusa/core-flows"
import { Modules } from "@medusajs/framework/utils"

// Dummy product data with free Unsplash images
const PRODUCTS = [
  {
    title: "Classic White T-Shirt",
    description: "Premium cotton white t-shirt. Comfortable and breathable for everyday wear.",
    handle: "classic-white-tshirt",
    thumbnail: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800",
    images: [
      { url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800" },
      { url: "https://images.unsplash.com/photo-1622445275576-721325763afe?w=800" },
    ],
    options: [
      { title: "Size", values: ["S", "M", "L", "XL"] },
    ],
    variants: [
      { title: "S", prices: [{ amount: 1999, currency_code: "usd" }], options: { Size: "S" }, manage_inventory: false },
      { title: "M", prices: [{ amount: 1999, currency_code: "usd" }], options: { Size: "M" }, manage_inventory: false },
      { title: "L", prices: [{ amount: 1999, currency_code: "usd" }], options: { Size: "L" }, manage_inventory: false },
      { title: "XL", prices: [{ amount: 2199, currency_code: "usd" }], options: { Size: "XL" }, manage_inventory: false },
    ],
    status: "published" as const,
  },
  {
    title: "Black Leather Jacket",
    description: "Stylish black leather jacket. Perfect for casual and semi-formal occasions.",
    handle: "black-leather-jacket",
    thumbnail: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800",
    images: [
      { url: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800" },
    ],
    options: [
      { title: "Size", values: ["S", "M", "L", "XL"] },
    ],
    variants: [
      { title: "S", prices: [{ amount: 12999, currency_code: "usd" }], options: { Size: "S" }, manage_inventory: false },
      { title: "M", prices: [{ amount: 12999, currency_code: "usd" }], options: { Size: "M" }, manage_inventory: false },
      { title: "L", prices: [{ amount: 12999, currency_code: "usd" }], options: { Size: "L" }, manage_inventory: false },
      { title: "XL", prices: [{ amount: 13999, currency_code: "usd" }], options: { Size: "XL" }, manage_inventory: false },
    ],
    status: "published" as const,
  },
  {
    title: "Running Sneakers",
    description: "Lightweight running sneakers with cushioned sole. Great for daily runs and workouts.",
    handle: "running-sneakers",
    thumbnail: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800",
    images: [
      { url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800" },
      { url: "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800" },
    ],
    options: [
      { title: "Size", values: ["8", "9", "10", "11", "12"] },
    ],
    variants: [
      { title: "8", prices: [{ amount: 8999, currency_code: "usd" }], options: { Size: "8" }, manage_inventory: false },
      { title: "9", prices: [{ amount: 8999, currency_code: "usd" }], options: { Size: "9" }, manage_inventory: false },
      { title: "10", prices: [{ amount: 8999, currency_code: "usd" }], options: { Size: "10" }, manage_inventory: false },
      { title: "11", prices: [{ amount: 8999, currency_code: "usd" }], options: { Size: "11" }, manage_inventory: false },
      { title: "12", prices: [{ amount: 9499, currency_code: "usd" }], options: { Size: "12" }, manage_inventory: false },
    ],
    status: "published" as const,
  },
  {
    title: "Denim Jeans - Slim Fit",
    description: "Classic slim-fit denim jeans. Durable and comfortable with a modern look.",
    handle: "denim-jeans-slim",
    thumbnail: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=800",
    images: [
      { url: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=800" },
    ],
    options: [
      { title: "Size", values: ["28", "30", "32", "34", "36"] },
    ],
    variants: [
      { title: "28", prices: [{ amount: 5999, currency_code: "usd" }], options: { Size: "28" }, manage_inventory: false },
      { title: "30", prices: [{ amount: 5999, currency_code: "usd" }], options: { Size: "30" }, manage_inventory: false },
      { title: "32", prices: [{ amount: 5999, currency_code: "usd" }], options: { Size: "32" }, manage_inventory: false },
      { title: "34", prices: [{ amount: 5999, currency_code: "usd" }], options: { Size: "34" }, manage_inventory: false },
      { title: "36", prices: [{ amount: 6499, currency_code: "usd" }], options: { Size: "36" }, manage_inventory: false },
    ],
    status: "published" as const,
  },
  {
    title: "Canvas Backpack",
    description: "Spacious canvas backpack with multiple compartments. Perfect for work and travel.",
    handle: "canvas-backpack",
    thumbnail: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800",
    images: [
      { url: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800" },
    ],
    options: [
      { title: "Color", values: ["Olive", "Black", "Navy"] },
    ],
    variants: [
      { title: "Olive", prices: [{ amount: 4999, currency_code: "usd" }], options: { Color: "Olive" }, manage_inventory: false },
      { title: "Black", prices: [{ amount: 4999, currency_code: "usd" }], options: { Color: "Black" }, manage_inventory: false },
      { title: "Navy", prices: [{ amount: 4999, currency_code: "usd" }], options: { Color: "Navy" }, manage_inventory: false },
    ],
    status: "published" as const,
  },
  {
    title: "Wireless Headphones",
    description: "Premium wireless headphones with noise cancellation. 30-hour battery life.",
    handle: "wireless-headphones",
    thumbnail: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800",
    images: [
      { url: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800" },
      { url: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=800" },
    ],
    options: [
      { title: "Color", values: ["Black", "White", "Silver"] },
    ],
    variants: [
      { title: "Black", prices: [{ amount: 14999, currency_code: "usd" }], options: { Color: "Black" }, manage_inventory: false },
      { title: "White", prices: [{ amount: 14999, currency_code: "usd" }], options: { Color: "White" }, manage_inventory: false },
      { title: "Silver", prices: [{ amount: 15999, currency_code: "usd" }], options: { Color: "Silver" }, manage_inventory: false },
    ],
    status: "published" as const,
  },
  {
    title: "Stainless Steel Watch",
    description: "Elegant stainless steel watch with minimalist design. Water-resistant up to 50m.",
    handle: "stainless-steel-watch",
    thumbnail: "https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=800",
    images: [
      { url: "https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=800" },
    ],
    options: [
      { title: "Color", values: ["Silver", "Gold", "Rose Gold"] },
    ],
    variants: [
      { title: "Silver", prices: [{ amount: 19999, currency_code: "usd" }], options: { Color: "Silver" }, manage_inventory: false },
      { title: "Gold", prices: [{ amount: 22999, currency_code: "usd" }], options: { Color: "Gold" }, manage_inventory: false },
      { title: "Rose Gold", prices: [{ amount: 22999, currency_code: "usd" }], options: { Color: "Rose Gold" }, manage_inventory: false },
    ],
    status: "published" as const,
  },
  {
    title: "Sunglasses - Aviator",
    description: "Classic aviator sunglasses with UV400 protection. Timeless style for any occasion.",
    handle: "aviator-sunglasses",
    thumbnail: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800",
    images: [
      { url: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800" },
    ],
    options: [
      { title: "Lens", values: ["Black", "Brown", "Green"] },
    ],
    variants: [
      { title: "Black", prices: [{ amount: 3999, currency_code: "usd" }], options: { Lens: "Black" }, manage_inventory: false },
      { title: "Brown", prices: [{ amount: 3999, currency_code: "usd" }], options: { Lens: "Brown" }, manage_inventory: false },
      { title: "Green", prices: [{ amount: 4499, currency_code: "usd" }], options: { Lens: "Green" }, manage_inventory: false },
    ],
    status: "published" as const,
  },
]

export default async function seedProducts({ container }: ExecArgs) {
  const logger = container.resolve("logger")

  logger.info("Starting product seed...")

  // Get default sales channel
  const salesChannelService = container.resolve(Modules.SALES_CHANNEL)
  const [salesChannel] = await salesChannelService.listSalesChannels({}, { take: 1 })

  if (!salesChannel) {
    logger.error("No sales channel found. Please create one first via the admin dashboard.")
    return
  }

  // Add sales channel to each product
  const productsWithChannel = PRODUCTS.map((p) => ({
    ...p,
    sales_channels: [{ id: salesChannel.id }],
  }))

  // Create products
  const { result } = await createProductsWorkflow(container).run({
    input: { products: productsWithChannel },
  })

  logger.info(`Seeded ${result.length} products successfully!`)
  logger.info("Products: " + result.map((p: any) => p.title).join(", "))
}
