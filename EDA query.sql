#### EDAAA QUERY UNTUK VISUALISASI NANTI
#ENTAH KEPAKE ATAU GAK NANTINYA:v

#TOTAL GAME RILIS BERDASARKAN TAAHUN dan Diurutkan dari kecil ke besar
SELECT YEAR(release_date) AS tahun, COUNT(appid) total_game_rilis
FROM dataset_cleaning2
GROUP BY tahun
ORDER BY tahun ASC
LIMIT 50;

#AGREGASI PALYER CCU + CTE DAN DI GROUP BY KATEGORI PRICE(GRATIS, MURAH MAHAL)
WITH ctekategoripeak AS(
SELECT peak_ccu,
	case when price = 0 then 'Gratis'
		  when price <10 then 'Murah'
		  when price <100 then 'Lumayan Mahal'
		  ELSE 'Mahal Banget'
		  END AS kategori_price
FROM dataset_cleaning2
)

SELECT kategori_price,SUM(peak_ccu) AS total_player_aktif, AVG(peak_ccu) rata2_playeraktif , MIN(peak_ccu), MAX(peak_ccu)FROM ctekategoripeak
GROUP BY kategori_price
ORDER BY total_player_aktif DESC
LIMIT 20;

# TOP 10 PUBLISHER DENGAN PEMAIN TERBANYAK
SELECT publishers, SUM(owners_upper) AS pemain
FROM dataset_cleaning2
GROUP BY publishers
ORDER BY pemain DESC
LIMIT 10;


#TOP 10 PUBLISHER TERKAYA 
WITH ctetotalpublsiher AS(
SELECT publishers, (owners_upper + owners_lower)/2 AS nilaitengah2
FROM dataset_cleaning2
WHERE (owners_upper + owners_lower)/2 >2
GROUP BY publishers,nilaitengah2
)
SELECT publishers, SUM(nilaitengah2) AS totalpend FROM ctetotalpublsiher
GROUP BY publishers
ORDER BY totalpend DESC
LIMIT 10
;


SELECT `name`,price,publishers,owners_upper
FROM dataset_cleaning2
WHERE publishers = 'DICE';

#MENAMPILKAN MASING2 NAMA GAME DAN PUBLISHER DENGAN PEMAIN CCU TERBANYAK
WITH cte_denserank AS(
	SELECT `name`, publishers, peak_ccu,
	DENSE_RANK() OVER(PARTITION BY publishers ORDER BY peak_ccu DESC ) rankdense
	FROM dataset_cleaning2
)

SELECT `name`, publishers, peak_ccu FROM cte_denserank
WHERE rankdense = 1 AND peak_ccu >=1
ORDER BY peak_ccu DESC; 

#MENAMPILKAN KEPEMILIKAN GAME TERBANYAK range 1jt - 50jt TAPI PEMAIN AKTIF DIKIT
SELECT `Name`, owners_upper, Peak_CCU FROM dataset_cleaning2
WHERE (owners_upper > 1000000 OR owners_upper >5000000)
		AND (Peak_CCU <100 OR Peak_CCU < 50)
ORDER BY owners_upper DESC ;

#MENGETAHUI RATA2 PEMAIN AKTIF TERBANYAK BERDASARKAN GENRE YG DIKATEGORIKAN MULTI PLAYER, SINGLE PLAYER, DAN LAINNYA
WITH ctekateogri AS (
SELECT genres, peak_ccu ,
	case when genres LIKE '%Multi-player%' then 'Pasukan Mabar'
	 	  when genres LIKE '%Single-player%' then 'Penyendiri' 
	 	  ELSE 'Other'
	END AS genress
FROM dataset_cleaning2
)
SELECT genress, AVG(peak_ccu) AS rata2ccu
FROM ctekateogri
GROUP BY genress;


#MEGCEK RATA2 HARGA GAME BERDASARKAN UMUR
SELECT required_age,AVG(price) AS rata2harg
FROM dataset_cleaning2
GROUP BY required_age
ORDER BY required_age,rata2harg ;

#TOTAL DARI KESELURUHAN RATA2 HARGA DI UMUR SAMA DENGAN 18+ 
WITH cterata2harga AS (
	SELECT `name`,publishers,avg(price) AS rata2harga
	FROM dataset_cleaning2
	WHERE required_age >= 18
	GROUP BY `name`,publishers
	ORDER BY publishers
)
SELECT AVG(rata2harga) FROM cterata2harga;

#TOTAL DARI KESELURUHAN RATA2 HARGA DI BAWAH UMUR 18+ 
WITH cterata2hargadibawah18 AS (
	SELECT `name`,publishers,avg(price) AS rata2hargaa
	FROM dataset_cleaning2
	WHERE required_age < 18
	GROUP BY `name`,publishers
	ORDER BY publishers
)
SELECT AVG(rata2hargaa) FROM cterata2hargadibawah18;

#TOTAL HARGA GAME DI ATAS SAMA DENGAN 18+
WITH ctetotalharga18 AS (
	SELECT `name`,publishers,SUM(price) AS totalharga
	FROM dataset_cleaning2
	WHERE required_age >= 18
	GROUP BY `name`,publishers
	ORDER BY publishers
)
SELECT SUM(totalharga) AS total FROM ctetotalharga18;

#TOTAL HARGA GAME DI BAWAH 18+
WITH ctetotalhargadibawah18 AS (
	SELECT `name`,publishers,required_age,price,SUM(price) AS totalharga
	FROM dataset_cleaning2
	WHERE required_age < 18
	GROUP BY `name`,publishers,required_age,price
	ORDER BY publishers
)
SELECT SUM(totalharga)FROM ctetotalhargadibawah18;



