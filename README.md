# SIMTAHSIN Online — paket integrasi

Paket ini menyiapkan web app online untuk Vercel + Supabase. **Belum terhubung ke akun/proyek Anda** karena URL proyek dan publishable/anon key belum diberikan, dan saya tidak bisa masuk ke akun eksternal Anda dari chat ini.

## 1. Supabase
1. Masuk ke akun Supabase yang sudah Anda gunakan, lalu buat proyek baru khusus SIMTAHSIN agar tabel dan pengaturan autentikasi SIMAK tidak berubah.
2. Buka SQL Editor dan jalankan seluruh isi `supabase/schema.sql`.
3. Di Authentication > Providers > Email, pastikan login password aktif. Untuk model username alias yang digunakan paket ini, nonaktifkan email confirmation hanya di proyek khusus SIMTAHSIN. Karena proyek ini baru, pengaturan tersebut tidak akan memengaruhi SIMAK.
4. Di Authentication > Users, buat pengguna pertama dengan email alias `admin@simtahsin.local` dan password kuat. Ini adalah alias login, bukan alamat email sungguhan. Setelah pengguna dibuat, jalankan seed admin yang ada di bagian akhir `supabase/schema.sql` (atau jalankan query seed yang sama secara terpisah).
5. Simpan Project URL dan publishable/anon key dari Project Settings > API. Jangan pernah menaruh service_role/secret key di browser atau Git.

## 2. Konfigurasi lokal
1. Untuk lokal, buat file `.env` di root dengan `VITE_SUPABASE_URL=https://PROJECT-REF.supabase.co` dan `VITE_SUPABASE_ANON_KEY=...`.
2. Jalankan `npm install`, lalu `npm run dev` untuk mencoba. `npm run build` untuk membangun.

## 3. Deploy ke Vercel
1. Unggah folder ini ke repository GitHub pribadi Anda (jangan unggah `service_role` key).
2. Di Vercel, Import Project dari repository tersebut. Di Project Settings > Environment Variables, tambahkan `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` untuk Production, Preview, dan Development.
3. Build command `npm run build`, output `dist`.
4. Deploy, lalu buka URL hasil deployment.
5. Jika mengubah konfigurasi, deploy ulang.

## 4. Keamanan
- Jangan gunakan password demo lama `admin123` / `guru123` pada aplikasi online.
- Jalankan SQL dengan RLS. Jangan mematikan RLS untuk memperbaiki masalah.
- Gunakan akun admin khusus SIMTAHSIN. Menambah tabel berawalan `tahsin_` tidak mengubah tabel SIMAK yang sudah ada.
- Karena aplikasi login menggunakan username, username diterjemahkan ke alias email `username@simtahsin.local` sebelum login.

## 5. Impor daftar siswa awal
Setelah `schema.sql` dijalankan, jalankan `supabase/seed_students.sql` di SQL Editor untuk memasukkan 45 siswa dari file Excel yang Anda berikan. Query ini tidak membuat duplikat jika dijalankan ulang.

## 6. Login awal dan pembuatan akun guru
- Di Authentication > Users, buat user pertama dengan email `admin@simtahsin.local` dan password yang kuat. Jika Supabase menolak domain `.local`, gunakan domain alias yang valid dan samakan fungsi `alias()` pada `src/main.js` serta query seed profil.
- Jalankan blok seed admin di bagian akhir `schema.sql` setelah user dibuat.
- Login di web dengan username `admin` dan password yang Anda tetapkan.
- Tambahkan akun guru melalui menu Akun Pengguna. Password minimal 8 karakter.
