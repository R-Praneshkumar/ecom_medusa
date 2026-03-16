import { ExecArgs } from "@medusajs/framework/types"
import {
  createProductCategoriesWorkflow,
  createProductsWorkflow,
  createRegionsWorkflow,
  createSalesChannelsWorkflow,
  createShippingOptionsWorkflow,
  createShippingProfilesWorkflow,
  createStockLocationsWorkflow,
  createTaxRegionsWorkflow,
  linkSalesChannelsToStockLocationWorkflow,
  updateStoresWorkflow,
} from "@medusajs/medusa/core-flows"
import { Modules } from "@medusajs/framework/utils"

export default async function seed({ container }: ExecArgs) {
  const logger = container.resolve("logger")

  logger.info("Seeding store data...")

  // Update store
  const storeModuleService = container.resolve(Modules.STORE)
  const [store] = await storeModuleService.listStores()

  await updateStoresWorkflow(container).run({
    input: {
      selector: { id: store.id },
      update: {
        name: "Medusa Store",
        supported_currencies: [
          { currency_code: "usd", is_default: true },
          { currency_code: "eur" },
        ],
      },
    },
  })

  logger.info("Store updated")

  // Create sales channel
  const { result: salesChannelResult } = await createSalesChannelsWorkflow(container).run({
    input: {
      salesChannelsData: [
        { name: "Default Sales Channel", description: "Online storefront" },
      ],
    },
  })
  const salesChannel = salesChannelResult[0]
  logger.info("Sales channel created")

  // Create stock location
  const { result: stockLocationResult } = await createStockLocationsWorkflow(container).run({
    input: {
      locations: [
        {
          name: "Default Warehouse",
          address: {
            address_1: "123 Main St",
            city: "Los Angeles",
            country_code: "us",
            postal_code: "90001",
          },
        },
      ],
    },
  })

  await linkSalesChannelsToStockLocationWorkflow(container).run({
    input: {
      id: stockLocationResult[0].id,
      add: [salesChannel.id],
    },
  })
  logger.info("Stock location created")

  // Create shipping profile
  const { result: shippingProfileResult } = await createShippingProfilesWorkflow(container).run({
    input: {
      data: [{ name: "Default", type: "default" }],
    },
  })
  logger.info("Shipping profile created")

  // Create region
  const { result: regionResult } = await createRegionsWorkflow(container).run({
    input: {
      regions: [
        {
          name: "United States",
          currency_code: "usd",
          countries: ["us"],
          payment_providers: ["pp_system_default"],
        },
      ],
    },
  })
  logger.info("Region created")

  // Create tax region
  await createTaxRegionsWorkflow(container).run({
    input: [
      {
        country_code: "us",
      },
    ],
  })
  logger.info("Tax region created")

  // Create categories
  const { result: categoryResult } = await createProductCategoriesWorkflow(container).run({
    input: {
      product_categories: [
        { name: "Clothing", is_active: true },
        { name: "Accessories", is_active: true },
        { name: "Electronics", is_active: true },
        { name: "Footwear", is_active: true },
      ],
    },
  })
  logger.info("Categories created")

  // Create products
  const { result: productResult } = await createProductsWorkflow(container).run({
    input: {
      products: [
        {
          title: "Classic White T-Shirt",
          description: "Premium cotton white t-shirt. Comfortable and breathable.",
          handle: "classic-white-tshirt",
          category_ids: [categoryResult[0].id],
          thumbnail: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600",
          images: [
            { url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600" },
            { url: "https://images.unsplash.com/photo-1622445275576-721325763afe?w=600" },
          ],
          sales_channels: [{ id: salesChannel.id }],
          options: [{ title: "Size", values: ["S", "M", "L", "XL"] }],
          variants: [
            { title: "S", prices: [{ amount: 1999, currency_code: "usd" }], options: { Size: "S" }, manage_inventory: false },
            { title: "M", prices: [{ amount: 1999, currency_code: "usd" }], options: { Size: "M" }, manage_inventory: false },
            { title: "L", prices: [{ amount: 1999, currency_code: "usd" }], options: { Size: "L" }, manage_inventory: false },
            { title: "XL", prices: [{ amount: 2199, currency_code: "usd" }], options: { Size: "XL" }, manage_inventory: false },
          ],
          status: "published",
        },
        {
          title: "Black Leather Jacket",
          description: "Stylish black leather jacket for casual and semi-formal wear.",
          handle: "black-leather-jacket",
          category_ids: [categoryResult[0].id],
          thumbnail: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600",
          images: [{ url: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600" }],
          sales_channels: [{ id: salesChannel.id }],
          options: [{ title: "Size", values: ["S", "M", "L", "XL"] }],
          variants: [
            { title: "S", prices: [{ amount: 12999, currency_code: "usd" }], options: { Size: "S" }, manage_inventory: false },
            { title: "M", prices: [{ amount: 12999, currency_code: "usd" }], options: { Size: "M" }, manage_inventory: false },
            { title: "L", prices: [{ amount: 12999, currency_code: "usd" }], options: { Size: "L" }, manage_inventory: false },
          ],
          status: "published",
        },
        {
          title: "Running Sneakers",
          description: "Lightweight running sneakers with cushioned sole.",
          handle: "running-sneakers",
          category_ids: [categoryResult[3].id],
          thumbnail: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600",
          images: [
            { url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600" },
            { url: "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600" },
          ],
          sales_channels: [{ id: salesChannel.id }],
          options: [{ title: "Size", values: ["8", "9", "10", "11"] }],
          variants: [
            { title: "8", prices: [{ amount: 8999, currency_code: "usd" }], options: { Size: "8" }, manage_inventory: false },
            { title: "9", prices: [{ amount: 8999, currency_code: "usd" }], options: { Size: "9" }, manage_inventory: false },
            { title: "10", prices: [{ amount: 8999, currency_code: "usd" }], options: { Size: "10" }, manage_inventory: false },
            { title: "11", prices: [{ amount: 9499, currency_code: "usd" }], options: { Size: "11" }, manage_inventory: false },
          ],
          status: "published",
        },
        {
          title: "Denim Jeans - Slim Fit",
          description: "Classic slim-fit denim jeans. Durable and modern.",
          handle: "denim-jeans-slim",
          category_ids: [categoryResult[0].id],
          thumbnail: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=600",
          images: [{ url: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=600" }],
          sales_channels: [{ id: salesChannel.id }],
          options: [{ title: "Size", values: ["30", "32", "34", "36"] }],
          variants: [
            { title: "30", prices: [{ amount: 5999, currency_code: "usd" }], options: { Size: "30" }, manage_inventory: false },
            { title: "32", prices: [{ amount: 5999, currency_code: "usd" }], options: { Size: "32" }, manage_inventory: false },
            { title: "34", prices: [{ amount: 5999, currency_code: "usd" }], options: { Size: "34" }, manage_inventory: false },
            { title: "36", prices: [{ amount: 6499, currency_code: "usd" }], options: { Size: "36" }, manage_inventory: false },
          ],
          status: "published",
        },
        {
          title: "Wireless Headphones",
          description: "Premium wireless headphones with noise cancellation. 30hr battery.",
          handle: "wireless-headphones",
          category_ids: [categoryResult[2].id],
          thumbnail: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600",
          images: [
            { url: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600" },
            { url: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=600" },
          ],
          sales_channels: [{ id: salesChannel.id }],
          options: [{ title: "Color", values: ["Black", "White", "Silver"] }],
          variants: [
            { title: "Black", prices: [{ amount: 14999, currency_code: "usd" }], options: { Color: "Black" }, manage_inventory: false },
            { title: "White", prices: [{ amount: 14999, currency_code: "usd" }], options: { Color: "White" }, manage_inventory: false },
            { title: "Silver", prices: [{ amount: 15999, currency_code: "usd" }], options: { Color: "Silver" }, manage_inventory: false },
          ],
          status: "published",
        },
        {
          title: "Canvas Backpack",
          description: "Spacious canvas backpack with multiple compartments.",
          handle: "canvas-backpack",
          category_ids: [categoryResult[1].id],
          thumbnail: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600",
          images: [{ url: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600" }],
          sales_channels: [{ id: salesChannel.id }],
          options: [{ title: "Color", values: ["Olive", "Black", "Navy"] }],
          variants: [
            { title: "Olive", prices: [{ amount: 4999, currency_code: "usd" }], options: { Color: "Olive" }, manage_inventory: false },
            { title: "Black", prices: [{ amount: 4999, currency_code: "usd" }], options: { Color: "Black" }, manage_inventory: false },
            { title: "Navy", prices: [{ amount: 4999, currency_code: "usd" }], options: { Color: "Navy" }, manage_inventory: false },
          ],
          status: "published",
        },
        {
          title: "Stainless Steel Watch",
          description: "Elegant minimalist watch. Water-resistant up to 50m.",
          handle: "stainless-steel-watch",
          category_ids: [categoryResult[1].id],
          thumbnail: "https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=600",
          images: [{ url: "https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=600" }],
          sales_channels: [{ id: salesChannel.id }],
          options: [{ title: "Color", values: ["Silver", "Gold", "Rose Gold"] }],
          variants: [
            { title: "Silver", prices: [{ amount: 19999, currency_code: "usd" }], options: { Color: "Silver" }, manage_inventory: false },
            { title: "Gold", prices: [{ amount: 22999, currency_code: "usd" }], options: { Color: "Gold" }, manage_inventory: false },
            { title: "Rose Gold", prices: [{ amount: 22999, currency_code: "usd" }], options: { Color: "Rose Gold" }, manage_inventory: false },
          ],
          status: "published",
        },
        {
          title: "Aviator Sunglasses",
          description: "Classic aviator sunglasses with UV400 protection.",
          handle: "aviator-sunglasses",
          category_ids: [categoryResult[1].id],
          thumbnail: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600",
          images: [{ url: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600" }],
          sales_channels: [{ id: salesChannel.id }],
          options: [{ title: "Lens", values: ["Black", "Brown", "Green"] }],
          variants: [
            { title: "Black", prices: [{ amount: 3999, currency_code: "usd" }], options: { Lens: "Black" }, manage_inventory: false },
            { title: "Brown", prices: [{ amount: 3999, currency_code: "usd" }], options: { Lens: "Brown" }, manage_inventory: false },
            { title: "Green", prices: [{ amount: 4499, currency_code: "usd" }], options: { Lens: "Green" }, manage_inventory: false },
          ],
          status: "published",
        },
      ],
    },
  })

  logger.info(`Seeded ${productResult.length} products!`)
  logger.info("Seeding complete!")
}
