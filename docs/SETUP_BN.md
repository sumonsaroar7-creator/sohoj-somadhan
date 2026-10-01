# নিজুম এন্টারপ্রাইজ — সেটআপ গাইড (বাংলা)

এই প্যাকেজটি অনলাইনে কার্যকর করতে একটি Supabase backend এবং static hosting লাগবে। একবার সেটআপ করার পর পণ্য/অর্ডার অনলাইনে database-এ থাকবে—একই browser-এর localStorage-এ নয়।

## ধাপ ১: Supabase project খুলুন
1. https://supabase.com এ গিয়ে account খুলুন।
2. New project নির্বাচন করুন।
3. Project name দিন `nizum-enterprise`।
4. শক্তিশালী database password দিন এবং নিরাপদে সংরক্ষণ করুন।
5. Project তৈরি হলে Project URL এবং anon/public key সংগ্রহ করুন: Project Settings → API।

## ধাপ ২: Database তৈরি করুন
1. Supabase Dashboard → SQL Editor খুলুন।
2. `supabase/schema.sql` ফাইলের সম্পূর্ণ SQL কপি করুন।
3. SQL Editor-এ paste করে Run করুন।
4. সফল হলে Table Editor-এ `products`, `orders`, `order_items`, `expenses`, `profiles` টেবিল দেখুন।

## ধাপ ৩: Admin account তৈরি ও অনুমতি দিন
1. Supabase → Authentication → Users → Add user নির্বাচন করুন।
2. নিজের ইমেইল ও শক্তিশালী পাসওয়ার্ড দিয়ে user তৈরি করুন (প্রয়োজনে email confirm করুন)।
3. SQL Editor-এ নিচের query চালান; YOUR-ADMIN-EMAIL নিজের email দিয়ে বদলাবেন:

```sql
update public.profiles
set role = 'admin'
where id = (select id from auth.users where email = 'YOUR-ADMIN-EMAIL');
```

4. Table Editor → profiles-এ নিজের user-এর role `admin` হয়েছে কি না দেখুন।
5. অন্য কাউকে admin করবেন না, যতক্ষণ না প্রয়োজন এবং বিশ্বাসযোগ্য।

## ধাপ ৪: Website config করুন
1. `public/config.js` খুলুন।
2. `SUPABASE_URL`-এ আপনার Project URL বসান।
3. `SUPABASE_ANON_KEY`-এ Supabase anon/public key বসান।
4. `WHATSAPP_NUMBER`-এ country code সহ আপনার WhatsApp নম্বর দিন, যেমন `8801XXXXXXXXX`।
5. Supabase service_role key কখনোই frontend config-এ দেবেন না।

## ধাপ ৫: Local test
1. `public` folder-টি VS Code-এ খুলুন।
2. VS Code Live Server extension দিয়ে `index.html` চালু করুন; সরাসরি file:// দিয়ে চালালে কিছু browser API সীমাবদ্ধ হতে পারে।
3. Store page খুলে Admin page-এ যান।
4. নিজের Supabase admin email/password দিয়ে login করুন।
5. প্রথম পণ্য add করুন—নাম, category, price, cost, stock দিন।
6. Storefront refresh করে পণ্য দেখা যাচ্ছে কি না দেখুন।
7. নিজের test phone/address দিয়ে একটি test COD order দিন।
8. Admin → Orders-এ অর্ডার দেখা, stock কমা এবং status update হচ্ছে কি না যাচাই করুন।
9. Admin → Expenses-এ test expense যোগ করে Reports দেখুন।

## ধাপ ৬: Hosting / Domain
যে কোনো static hosting (যেমন Netlify, Cloudflare Pages, Vercel static deployment) ব্যবহার করা যাবে।
1. `public` folder-এর ভেতরের ফাইলগুলো hosting-এ deploy করুন।
2. Custom domain যুক্ত করুন।
3. HTTPS/SSL চালু আছে নিশ্চিত করুন।
4. Supabase Authentication → URL Configuration-এ production site URL এবং redirect URL সেট করুন।
5. production URL-এ গিয়ে public order এবং admin login পুনরায় পরীক্ষা করুন।

## Security checks before launch
- Admin login ছাড়া `/admin.html` dashboard access হয় না।
- Supabase `profiles`-এ শুধু আপনার account-এ admin role আছে।
- RLS enabled আছে।
- service_role key frontend-এ নেই।
- Product/stock/order checkout database function দিয়ে validate হয়।
- Test order-এ real customer information ব্যবহার করবেন না।
- Database backup/PITR সুবিধা ও recovery process পর্যালোচনা করুন।
- Privacy, delivery, return/refund policy আপনার বাস্তব ব্যবসার নিয়ম অনুযায়ী সম্পাদনা করুন।
