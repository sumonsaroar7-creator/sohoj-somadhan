# দৈনন্দিন পরিচালনা ও হিসাব

## পণ্য যোগ করা
Admin → Products → Add a product:
- Product name ও category দিন।
- Selling price = গ্রাহকের কাছ থেকে নেওয়া পণ্যের মূল্য।
- Compare-at price = আগের/দেখানোর জন্য reference price (বাস্তব হলে তবেই ব্যবহার করুন)।
- Purchase cost = পণ্য কেনার একক খরচ।
- Stock = বিক্রির জন্য হাতে থাকা পরিমাণ।
- Images = সর্বোচ্চ ৫টি ছবি।
- Visible in store টিক দিয়ে Save করুন।

## অর্ডার
Admin → Orders-এ নতুন অর্ডার দেখা যাবে। ফোনে গ্রাহকের সঙ্গে কথা বলে নিশ্চিত করুন। তারপর status New → Confirmed → Processing → Shipped → Delivered করুন। বাতিল হলে Cancelled, ফেরত এলে Returned দিন। Status পরিবর্তনের আগে বাস্তব অবস্থা নিশ্চিত করুন।

## ডেলিভারি
Admin → Delivery-তে courier name, tracking number, delivery person ও phone লিখে Save করুন। বর্তমানে এটি manual record; courier API integration নয়।

## খরচ ও লাভ
Admin → Expenses-এ Advertising, Packaging, Carrying, Transportation, Delivery, Manpower ও Other খরচ তারিখসহ যোগ করুন।

Reports-এ:
Net Sales = delivered/active order status ছাড়া Cancelled ও Returned অর্ডার বাদে অর্ডারের subtotal।
Product Cost = অর্ডার তৈরির সময় database-এ snapshot হওয়া unit cost × quantity।
Recorded Expenses = Expenses table-এর সব expense।
Estimated Net Profit = Net Sales − Product Cost − Recorded Expenses।

গুরুত্বপূর্ণ:
- Delivery charge checkout-এ বর্তমানে শূন্য রাখা হয়েছে এবং গ্রাহককে নিশ্চিত করার সময় জানাতে হবে। প্রকৃত delivery collection/cost expense-এ সঠিকভাবে record করুন।
- Returned অর্ডারের stock স্বয়ংক্রিয়ভাবে ফেরত যোগ হয় না; পণ্য হাতে ফিরে এসে পরীক্ষা করার পর inventory হাতে-কলমে ঠিক করুন।
- বিজ্ঞাপন খরচ, প্যাকেজিং, কর্মচারী বেতন ইত্যাদি নিয়মিত record না করলে profit সঠিক হবে না।
- Tax/VAT, payment gateway charge, refund liability, supplier payable ইত্যাদি advanced accounting এই starter-এ নেই।
