# Steam Games Market Analysis (1997 - 2025)
Interactive Power BI Dashboard for Steam Market trends

## 📌 Project Overview
Proyek ini bertujuan untuk menganalisis tren pasar industri game di Steam.
Dengan dataset yg diambil dari kaggle dengan link dataset:
https://www.kaggle.com/datasets/fronkongames/steam-games-dataset/data

## 📊 Dashboard Visualisasi
<img width="1116" height="622" alt="Dashboard Steam Market Analysis" src="https://github.com/user-attachments/assets/c9d7642d-0504-4455-924a-2f6cce3e4aac" />

## 🛠️ Tools & Tahapan
- SQL: Digunakan untuk membersihkan data 
    1. Data Integrity (Remove Duplicates): Memastikan setiap appid bersifat unik untuk menghindari penghitungan ganda pada metrik total games dan revenue.
    2. Data Standardization: Melakukan perapihan teks (seperti fungsi TRIM) untuk memastikan tidak ada spasi berlebih. Selain itu, dilakukan penyesuaian tipe data pada setiap kolom; misalnya, mengubah kolom tanggal yang bertipe string menggunakan fungsi STR_TO_DATE. Hal ini krusial agar Power BI dapat mengenali format tanggal secara benar untuk perhitungan date range dan menghindari error saat proses analisis.
    3. Missing & Blank Value Management: Menangani data yang kosong pada kolom penting (seperti harga atau owner) agar tidak merusak perhitungan rata-rata. Dan mengisi blank value / null value di kolom seperti publishers, tags, dan genres dengan 'unknonw'.
    4. Feature Selection (Remove Irrelevant Columns): Menghapus kolom yang tidak memberikan nilai analisis untuk mengoptimalkan performa query dan ukuran file Power BI.

- Exploratory Data Analysis (EDA)
Selama tahap eksplorasi menggunakan SQL, saya merumuskan berbagai business questions untuk membedah perilaku pasar Steam. Meskipun dashboard akhir difokuskan pada tren waktu dan segmentasi pangsa pasar, investigasi menyeluruh telah dilakukan melalui tahapan berikut:
    1. Market Growth & Publisher Dominance: Menganalisis tren rilis game tahunan serta mengidentifikasi Top 10 Publishers dengan basis pemain terbesar dan pendapatan tertinggi.
    2. Player Engagement Anomaly: Menganalisis rasio retensi pemain dengan melacak game yang memiliki tingkat kepemilikan sangat tinggi (1 - 50 Juta owners) namun memiliki Peak CCU (Pemain Aktif Bersamaan) yang sangat rendah.
    3. Genre & Interaction Dynamics: Mengelompokkan dan menghitung rata-rata pemain aktif berdasarkan mode permainan (Single-player vs Multi-player).
    4. Pricing Strategy & Demographics: Mengevaluasi korelasi antara batasan usia (Required Age) dengan penetapan harga game. Tahap ini memanfaatkan Common Table Expression (CTE) untuk mengisolasi dan membandingkan secara presisi rata-rata harga game kategori dewasa (18+) dengan game untuk di bawah umur.
       
- Power BI & Power Query (Data Transformation & Visualization)
    1. Advanced Data Cleaning: Melakukan tahap pembersihan data kedua (double cleaning) pada Power Query untuk memastikan konsistensi data sebelum proses visualisasi.
    2. Data Filtering & Selection: Menyaring kategori dan genre game yang paling relevan bagi pasar (misalnya: Single-player, Action, Indie, Multiplayer) guna     menghindari bias pada analisis
    3. Data Engineering (Custom Columns & DAX): Melakukan rekayasa data dengan membuat kolom kalkulasi baru, seperti Median Owners (hasil rata-rata dari Owner Upper dan Lower) untuk mendapatkan estimasi Gross Revenue yang lebih akurat dan objektif.
    4. Interactive Dashboard: Membangun visualisasi dinamis yang mencakup tren waktu (Dual-axis), segmentasi pasar, dan peringkat performa game.

## 💡 Key Insights

