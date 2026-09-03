GAMSHIG-4 ONLINE + ADMIN PANEL

1. Supabase SQL Editor дээр ADMIN_SQL.sql доторх кодыг ажиллуул.
2. Дараа нь index.html-ийг нээ.
3. Admin account-аар нэвтрэхэд ⚙️ ADMIN товч гарна.
4. Тэндээс promo code үүсгэж, ашигласан эсэх, ашигласан email-ийг харж болно.

Анхаарах:
- admin_create_promo function өмнөх алхмаар admin хамгаалалттай болсон байх ёстой.
- Secret/service_role key frontend-д оруулаагүй.


LEADERBOARD FIX:
Supabase дээр save_game_state(integer, integer, integer) RPC үүсгэсэн байх шаардлагатай.
Энэ хувилбар XP/streak/unlocked-ийг profiles хүснэгт рүү тэр RPC-ээр хадгална.
Ингэснээр нүүрний XP болон XP чансааны XP ижил database утгаас уншигдана.
