SELECT * FROM games
LIMIT 100;

#membuat kolom duplikat dari tabel raw 
CREATE TABLE dataset_cleaning1
LIKE games;

#cek apakah ada? kalo ada lanjut masukan isi datanya juga
SELECT * FROM dataset_cleaning1
LIMIT 1000;
#memasukan data mentah tabel games ke dataseset clean 1
INSERT INTO dataset_cleaning1
SELECT * FROM games;

#Ini untuk cek apakah ada duplikasi dari semua baris di tabel
#pakai CTE dan ini subquery untuk dibungkus ke CTE
SELECT *,
ROW_NUMBER() OVER(PARTITION BY appid,`name`,release_date,price) AS row_num #MASUKAN SEMUA KOLOM JIKA INGIN PASTI CEK DUPLIKAT
FROM dataset_cleaning1
LIMIT 1000;
#Membuat CTE
WITH dup_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY appid,`name`,release_date,price) AS row_num
FROM dataset_cleaning1
)
SELECT *
FROM dup_cte
WHERE row_num > 1 #YG LEBIH DARI 1 UDAH OTOMATIS DUPLIKAT
LIMIT 1000;

#KARENA MY SQL GAK BISA LANGSUNG HAPUS DUPLIKASI DI CTE JADI
#MEMBUAT TABEL BARU LAGI

#BUAT TABEL BARU DAN ALTER TABLE ADD KOLOM ROW_NUM
CREATE TABLE dataset_cleaning2
LIKE dataset_cleaning1;

ALTER TABLE dataset_cleaning2
ADD COLUMN row_num INT;

#MEMASUKAN SEMUA DATA TERMASUK ROW_NUM CTE TADI KE TABEL BARU
INSERT INTO dataset_cleaning2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY appid,`name`,release_date,price) AS row_num
FROM dataset_cleaning1;

#CEK DATA APAKAH ROW_NUM ADA
SELECT * FROM dataset_cleaning2
LIMIT 1000;
#KALO ADA LANJUT DELETE DATA DUPLIKAT
DELETE
FROM dataset_cleaning2
WHERE row_num > 1;
#CEK LAGI APAKAH DUPLIKAT SUDAH HILANG
SELECT COUNT(*)
FROM dataset_cleaning2
WHERE row_num = 1
LIMIT 100;

#CLEANING SPASI BERLEBIH DI SEMUA KOLOM TEKS
#AWALI DENGAN SELECT DULU SBLM EKSEKUSI UPDATE
SELECT 
  Publishers, Categories, Genres, Tags,
  TRIM(Publishers) AS Pub_Clean,
  TRIM(Categories) AS Cat_Clean,
  TRIM(Genres) AS Gen_Clean,
  TRIM(Tags) AS Tag_Clean
FROM dataset_cleaning2;

#Kalau sudah fix 
#baru update teks spasi berlebihan
UPDATE dataset_cleaning2
	SET Publishers = TRIM(Publishers),
	 Categories = TRIM(Categories),
	 Genres = TRIM(Genres),
	 Tags = TRIM(Tags);
	 
#Karena tipe data date ini masih string jadi 
#AWALI DENGAN SELECT DULU SBLM EKSEKUSI UPDATE 
SELECT release_Date,
STR_TO_DATE(release_date,'%b%d,%Y')
FROM dataset_cleaning2
LIMIT 1000;

##updatee data tanggal
UPDATE dataset_cleaning2
SET release_date = STR_TO_DATE(release_date,'%b%d,%Y');

#edit kolom jadi sesuai barisnya tipe data apa
ALTER TABLE dataset_cleaning2
MODIFY COLUMN developers INT,
MODIFY COLUMN release_date DATE
;

#ini unutuk memecah estimasi karena baris berisi range -
#splittt estimasi owner pake substring & tambah table baru dulu
ALTER TABLE dataset_cleaning2 
ADD COLUMN owners_lower BIGINT,
ADD COLUMN owners_upper BIGINT;

#SELECT DUA BAGIAN JADI OWNERE UPER&LOWER
WITH CTE_OWNERUPLOW AS (
SELECT 
CAST(SUBSTRING_INDEX(Estimated_owners, ' - ', 1) AS UNSIGNED) AS lowerr,
CAST(SUBSTRING_INDEX(Estimated_owners, ' - ', -1) AS UNSIGNED) AS uperr
FROM dataset_cleaning2
)
SELECT lowerr, uperr
FROM CTE_OWNERUPLOW
LIMIT 1000;

# UPDATE DAN MEMECAH PAKE DELIMETERE - UNTUK KE 2 KOLOM PAKE CAST DAN SUBSTRING UNTUK DI MYSQL
UPDATE dataset_cleaning2 
SET owners_lower = CAST(SUBSTRING_INDEX(Estimated_owners, ' - ', 1) AS UNSIGNED),
    owners_upper = CAST(SUBSTRING_INDEX(Estimated_owners, ' - ', -1) AS UNSIGNED);

#CEK MISING VALUE ISNULL/BLANK DENGAN AGREGASI + CASE WHEN + ""
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Price IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN Release_date IS NULL THEN 1 ELSE 0 END) AS missing_release_date,
    SUM(CASE WHEN owners_lower IS NULL THEN 1 ELSE 0 END) AS missing_owners,
    SUM(CASE WHEN Genres IS NULL OR Genres = "" THEN 1 ELSE 0 END) AS missing_genres,
    SUM(CASE WHEN Appid IS NULL OR Appid = "" THEN 1 ELSE 0 END) AS missing_appid,
    SUM(CASE WHEN `NAME` IS NULL OR NAME = "" THEN 1 ELSE 0 END) AS missing_name,
    SUM(CASE WHEN Publishers IS NULL OR Publishers = "" THEN 1 ELSE 0 END) AS missing_publishers,
    SUM(CASE WHEN Categories IS NULL OR Categories = "" THEN 1 ELSE 0 END) AS missing_categories,
    SUM(CASE WHEN Tags IS NULL OR Tags = "" THEN 1 ELSE 0 END) AS missing_tags
FROM dataset_cleaning2;

#cek mising value dan hapus mising value
SELECT name,Release_date FROM dataset_cleaning2
WHERE Release_date IS NULL 
LIMIT 1000;
#cek nama isnull ada 1
SELECT * FROM dataset_cleaning2
WHERE appid = 396420 OR NAME = '';
##hapus mising date and nama ""
DELETE 
FROM dataset_cleaning2
WHERE Release_date IS NULL;
DELETE
FROM dataset_cleaning2
WHERE appid = 396420 OR NAME = '';

#MISING GENRE PUBLISHER CATEFORIES AND TAGS SEKITAR 8K AN
#MENGUPDATE DENGAN KALIMAT UNKNOWN DI SEMUA ""
UPDATE dataset_cleaning2 SET genres = 'unknown' WHERE genres = "";
UPDATE dataset_cleaning2 SET publishers = 'unknown' WHERE publishers = "";
UPDATE dataset_cleaning2 SET categories = 'unknown' WHERE categories = "";
UPDATE dataset_cleaning2 SET tags = 'unknown' WHERE tags = "";

#karena ada kategori yg kosong dan itu banyak sekali
#update kategori yg sama dengan publihser
UPDATE dataset_cleaning2 
SET categories = 'unknown' 
WHERE categories = Publishers;

#hapus kolom tidak dibuthkan
ALTER TABLE dataset_cleaning2
DROP COLUMN row_num,
DROP COLUMN About_the_game,
DROP COLUMN Reviews,
DROP COLUMN Header_image,
DROP COLUMN Website,
DROP COLUMN Support_url,
DROP COLUMN Support_email,
DROP COLUMN Metacritic_url,
DROP COLUMN Screenshots,
DROP COLUMN Movies,
DROP COLUMN Notes,
DROP COLUMN Discount_DLC_count,
DROP COLUMN Full_audio_languages,
DROP COLUMN Score_rank,
DROP COLUMN Average_playtime_two_weeks,
DROP COLUMN Median_playtime_two_weeks;
DROP COLUMN User_score, 
DROP COLUMN Achievements, 
DROP COLUMN Recommendations, 
DROP COLUMN Average_playtime_forever, 
DROP COLUMN Median_playtime_forever, 
DROP COLUMN developers,
DROP COLUMN Windows, 
DROP COLUMN Mac, 
DROP COLUMN Linux, 
DROP COLUMN Metacritic_score,
DROP COLUMN Positive,
DROP COLUMN Negative;

#cek apakah sudah rapih kalo sudah lanjut EDA
SELECT *
FROM dataset_cleaning2
LIMIT 1000;
