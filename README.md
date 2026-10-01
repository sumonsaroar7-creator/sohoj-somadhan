# Nizum Enterprise — Multi-category E-commerce Starter

A real Supabase-backed e-commerce application starter for Bangladesh. Includes a customer storefront, shopping cart, server-validated COD checkout, secure admin authentication, product/inventory management, order management, delivery assignment fields, expense tracking and CSV export.

## Important status
This is a deployable full-stack starter that becomes operational after you create and configure a Supabase project and deploy the static frontend. It is **not** a hosted live store yet. You must complete the setup below, use your own credentials, test it, and publish it on HTTPS before taking real customer orders. No payment gateway or courier API is falsely represented as active.

## Included
- `public/index.html`: public shop
- `public/admin.html`: protected admin dashboard
- `public/config.js`: Supabase project URL and anon key configuration
- `public/store.js`, `public/admin.js`: application logic
- `public/styles.css`, `public/admin.css`: responsive styling
- `public/policy.html`: policy starter text
- `supabase/schema.sql`: database, security policies, storage bucket and secure checkout RPC
- `docs/SETUP_BN.md`: step-by-step Bengali setup
- `docs/OPERATIONS_BN.md`: daily business operation and accounting notes

## Quick overview
The public site reads active products from Supabase. Checkout calls the `place_order` database function. The function rechecks prices, locks stock, creates the order and snapshots product cost server-side. The admin site requires Supabase Auth and a `profiles.role='admin'` record. Admin-only database and storage actions are protected by Row Level Security.

## What is not yet connected
- bKash/Nagad/SSLCommerz payment gateway (COD is active after setup)
- Courier provider API (manual courier/parcel fields are available)
- SMS/WhatsApp automated notifications (WhatsApp contact link is provided)
- Customer accounts and customer-facing order tracking page
- VAT/tax/accounting integrations

Do not publish payment options until a merchant account, gateway credentials, callback verification and refund process have been implemented and tested.

## Deploy
Follow `docs/SETUP_BN.md` carefully. Never share the Supabase service-role key or admin password. Only the Supabase anon/public key belongs in `public/config.js`.
