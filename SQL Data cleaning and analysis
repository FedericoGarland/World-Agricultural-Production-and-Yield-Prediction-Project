-------- PROYECTO 1 -------
----- CROPS TABLE
---- DATA CLEANING ---- 
--- IDENTIFYING CLEANING REQUIREMENTS
WITH raw_area AS (SELECT 
DISTINCT area 
FROM crops
ORDER BY area),

raw_items AS (SELECT 
DISTINCT item
FROM crops
ORDER BY item),

--- CLEANING THE DATA
clean_data AS (SELECT
*
FROM crops 
WHERE value IS NOT NULL
AND item NOT ILIKE ('%Total%') AND item NOT ILIKE ('%Crop%') AND item NOT ILIKE ('%Primary%') AND item NOT ILIKE ('% nes%')
AND item NOT ILIKE('%Vegetable%') AND item NOT ILIKE('%milled%') 
AND area NOT IN ('China', 'Africa','Americas','Australia and New Zealand','Belgium–Luxembourg','Caribbean', 'Europe', 'Oceania',
				 'Small Island Developing States', 'South-eastern Asia', 'South America', 'Middle Africa', 'Asia','World', 'Melanesia', 
				'Polynesia', 'Micronesia') 
AND area NOT LIKE ('Central%') 
AND area NOT LIKE ('Eastern%')
AND area NOT LIKE ('Northern%')
AND area NOT LIKE ('Southern%')
AND area NOT LIKE ('Western%')
AND area NOT LIKE ('European Union%')
AND area NOT LIKE ('%Countries%')),

--- ANALYSIS
-- TOTAL GLOBAL PRODUCTION BY YEAR (1961-2019)
PRODUCTION_BY_YEAR AS (SELECT 
year,
SUM(value)
FROM clean_data
WHERE element = 'Production'
GROUP BY year
ORDER BY year),

-- MOST PRODUCED CROPS FOR YEAR 2019 
MOST_PRODUCED_CROPS AS (SELECT 
item, 
SUM(value) AS total_production
FROM clean_data
WHERE element = 'Production'
AND year = 2019
GROUP BY item
ORDER BY SUM(value) DESC
LIMIT 20),

-- MOST PRODUCED CROPS BY YEAR (1961 - 2019)
MOST_PRODUCED_BY_YEAR AS (SELECT
year,
item, 
SUM(value) AS total_production,
ROW_NUMBER() OVER (PARTITION BY year ORDER BY SUM(value) DESC) AS row
FROM clean_data 
WHERE element = 'Production'
GROUP BY item, year),

-- TOP 10 MOST PRODUCED CROP EACH YEAR 
TEN_MOST_PRODUCED_BY_YEAR AS (SELECT 
*
FROM MOST_PRODUCED_BY_YEAR 
WHERE row <= 10),

-- COUNTRIES THAT PRODUCED THE MOST OF THE TEN MOST PRODUCED CROPS IN 2019
MOST_PRODUCTIVE_COUNTRIES AS (SELECT 
area AS country, 
SUM(value) AS production
FROM clean_data
WHERE element = 'Production'
AND year = 2019
AND item IN (SELECT item FROM TEN_MOST_PRODUCED_BY_YEAR WHERE year = 2019)
GROUP BY area
ORDER BY production DESC
LIMIT 10),

-- COUNTRIES THAT HARVESTED THE MOST AREA FROM THE TEN MOST PRODUCED CROPS IN 2019
MOST_HARVESTED_AREA_COUNTRIES AS (SELECT 
area AS country, 
SUM(value) AS area
FROM clean_data
WHERE element = 'Area harvested'
AND year = 2019
AND item IN (SELECT item FROM TEN_MOST_PRODUCED_BY_YEAR WHERE year = 2019)
GROUP BY area
ORDER BY area DESC
LIMIT 10),

-- AVERAGE YIELD FOR THE MOST PRODUCTIVE COUNTRIES IN THE TEN MOST PRODUCED CROPS IN 2019
YIELD_BY_TOP_PRODUCING_COUNTRY AS (
SELECT 
area AS country, 
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND year = 2019
AND item IN (SELECT item FROM TEN_MOST_PRODUCED_BY_YEAR WHERE year = 2019)
AND area IN (SELECT country FROM MOST_PRODUCTIVE_COUNTRIES)
GROUP BY area
ORDER BY yield DESC),


-- AVERAGE YIELD BY COUNTRY FOR THE TEN MOST PRODUCED CROPS IN 2019 
YIELD_BY_COUNTRY AS (SELECT 
area AS country, 
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND year = 2019
AND item IN (SELECT item FROM TEN_MOST_PRODUCED_BY_YEAR WHERE year = 2019)
GROUP BY area
ORDER BY yield DESC),

-- MOST PRODUCED CROPS IN THE TOP 4 MOST PRODUCTIVE COUNTRIES IN 2019
CROPS_BY_COUNTRY AS (SELECT 
area, 
item, 
SUM(value), 
DENSE_RANK() OVER (PARTITION BY area ORDER BY SUM(value) DESC) AS rank
FROM clean_data
WHERE element = 'Production'
AND area IN (SELECT country FROM MOST_PRODUCTIVE_COUNTRIES LIMIT 4)
AND year = 2019
GROUP BY area, item
ORDER BY area, SUM(value) DESC),

-- TOP 3 MOST PRODUCED CROPS IN THE TOP 4 MOST PRODUCTIVE COUNTRIES IN 2019 
TOP_CROPS_BY_COUNTRY AS (SELECT 
*
FROM CROPS_BY_COUNTRY 
WHERE rank <= 3),

-- TOTAL HARVESTED AREA EACH YEAR (1961-2019)
HARVESTED_AREA_BY_YEAR AS (SELECT 
year,
SUM(value)
FROM clean_data
WHERE element = 'Area harvested'
GROUP BY year
ORDER BY year ASC),

-- HARVESTED AREA BY CROP FOR YEAR 2019
AREA_BY_CROP AS (SELECT 
item, 
SUM(value), 
DENSE_RANK() OVER (ORDER BY SUM(value) DESC)
FROM clean_data
WHERE element = 'Area harvested'
AND year = 2019 
GROUP BY item),

-- GLOBAL AVERAGE ALL-CROP YIELD BY YEAR (1961-2019)
AVERAGE_GLOBAL_YIELDS_YEAR AS (SELECT
year,
AVG(value)*0.0001
FROM clean_data
WHERE element = 'Yield'
GROUP BY year
ORDER BY year),

-- AVERAGE YIELD BY CROP FOR EACH YEAR (1961-2019)
TOP_YIELDING_CROPS_BY_YEAR AS (SELECT 
year, 
item,
AVG(value)*0.0001 AS yield, 
DENSE_RANK() OVER (PARTITION BY year ORDER BY AVG(value) DESC) AS rank
FROM clean_data
WHERE element = 'Yield'
AND item NOT LIKE ('Mushroom%')
AND year BETWEEN 1961 AND 2019
GROUP BY year, item
ORDER BY year ASC, 3 DESC), 

-- TOP 10 HIGHEST YIELDING CROPS EACH YEAR (1961-2019)
TEN_HIGHEST_YIELDING_CROPS_BY_YEAR AS (SELECT 
* 
FROM TOP_YIELDING_CROPS_BY_YEAR 
WHERE rank <= 10),

-- TOP YIELDING CROPS IN 2019 
TOP_YIELDING_CROPS AS (SELECT
item, 
AVG(value)*0.0001 AS yield,
DENSE_RANK() OVER (ORDER BY AVG(value) DESC) AS rank
FROM clean_data
WHERE element = 'Yield'
AND item NOT LIKE ('Mushroom%')
AND year = 2019
GROUP BY item
ORDER BY AVG(value) DESC),

-- AMOUNT OF TIMES THAT EACH CROP HAS BEEN THE HIGHEST YIELDING (TOP 1)
FREQUENCY_OF_HIGHEST_YIELDING_CROP AS (SELECT
item,
COUNT(*)
FROM TOP_YIELDING_CROPS_BY_YEAR
WHERE rank = 1
GROUP BY item),

-- YEARS WHERE TOMATO WAS THE HIGHEST YIELDING CROP
YEARS_WHERE_TOMATO_WAS_HIGHEST_YIELDING AS (SELECT 
year, 
item,
rank
FROM TEN_HIGHEST_YIELDING_CROPS_BY_YEAR
WHERE rank = 1
AND item = 'Tomatoes'),

-- YIELD EACH YEAR (1961-2019) FOR EACH OF THE 5 MOST PRODUCED CROPS OF YEAR 2019
YIELD_FIVE_TOP_CROPS_BY_YEAR AS (SELECT 
item,
year,
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND item IN ('Sugar cane', 'Maize', 'Wheat', 'Rice, paddy', 'Oil palm fruit')
GROUP BY item, year),

-- YIELD FOR EACH OF THE 5 MOST PRODUCED CROPS IN THE TOP 4 MOST PRODUCING COUNTRIES, IN YEAR 2019 
YIELD_TOP_CROPS_IN_PRODUCTIVE_COUNTRIES AS (SELECT 
area, 
item,
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND year = 2019
AND item IN ('Sugar cane', 'Maize', 'Wheat', 'Rice, paddy', 'Oil palm fruit')
AND area IN (SELECT country FROM MOST_PRODUCTIVE_COUNTRIES LIMIT 4)
GROUP BY area, item
ORDER BY area, item, AVG(value) DESC),

-- HARVESTED AREA FOR EACH OF THE 5 MOST PRODUCED CROP OF 2019, BETWEEN YEARS 1961 AND 2019 
AREA_FIVE_TOP_CROPS_BY_YEAR AS (SELECT 
item, 
year, 
SUM(value) AS area
FROM clean_data
WHERE element = 'Area harvested'
AND item IN ('Sugar cane', 'Maize', 'Wheat', 'Rice, paddy', 'Oil palm fruit')
GROUP BY item, year),

-- TOTAL PRODUCTION OF THE 5 MOST PRODUCED CROPS OF 2019, BETWEEN YEARS 1961 AND 2019 
PRODUCTION_FIVE_TOP_CROPS_BY_YEAR AS (SELECT
item,
year, 
SUM(value) AS production 
FROM clean_data 
WHERE element = 'Production'
AND item IN ('Sugar cane', 'Maize', 'Wheat', 'Rice, paddy', 'Oil palm fruit')
GROUP BY item, year),

-- TOTAL PRODUCTION, AVERAGE YIELD AND HARVESTED AREA FOR THE 5 MOST PRODUCED CROPS OF 2019, BETWEEN YEARS 1961 AND 2019 
FIVE_CROPS_SUMMARY AS (SELECT
y.item, 
y.year,
p.production,
y.yield, 
a.area
FROM YIELD_FIVE_TOP_CROPS_BY_YEAR y INNER JOIN PRODUCTION_FIVE_TOP_CROPS_BY_YEAR p
ON y.item = p.item 
AND y.year = p.year 
INNER JOIN AREA_FIVE_TOP_CROPS_BY_YEAR a 
ON y.item = a.item 
AND y.year = a.year),

-- AMOUNT OF COUNTRIES WHERE EACH CROP IS PRODUCED 
COUNTRY_COUNT_PER_CROP AS (SELECT
item, 
COUNT(DISTINCT area)
FROM clean_data
GROUP BY item
ORDER BY COUNT(area) DESC),

-- AVERAGE YIELD FOR THE 10 MOST PRODUCED CROPS OF 2019, BETWEEN YEARS 1961 AND 2019
TOP_TEN_CROPS_YIELD_EVOLUTION AS (SELECT
year, 
item, 
AVG(value)*0.0001
FROM clean_data
WHERE element = 'Yield'
AND item IN (SELECT item FROM TEN_MOST_PRODUCED_BY_YEAR WHERE year = 2019)
GROUP BY year, item
ORDER BY year, item),

-- TOTAL HARVESTED AREA FOR THE 10 MOST PRODUCED CROPS OF 2019, BETWEEN YEARS 1961 AND 2019
TOP_TEN_CROPS_AREA_EVOLUTION AS (SELECT 
year, 
item, 
SUM(value)
FROM clean_data
WHERE element = 'Area harvested'
AND item IN (SELECT item FROM TEN_MOST_PRODUCED_BY_YEAR WHERE year = 2019)
GROUP BY year, item
ORDER BY year, item),

-- HARVESTED AREA BY CROP IN 2016 AND 2019 
AREA_BY_CROP_BY_YEAR AS (SELECT 
year, 
item, 
SUM(value) AS area 
FROM clean_data
WHERE element = 'Area harvested'
AND year IN (2016,2019)
GROUP BY year, item 
ORDER BY item, year),

-- YEAR ON YEAR GROWTH RATE OF HARVESTED AREA FOR EACH CROP IN PERIOD 2016-2019
YOY_AREA_GROWTH AS (SELECT
year, 
item, 
area,
(area - LAG(area) OVER (PARTITION BY item ORDER BY year))/LAG(area) OVER (PARTITION BY item ORDER BY year)*100 AS yoy_growth
FROM AREA_BY_CROP_BY_YEAR),

-- CROPS WITH THE HIGHEST HARVESTED AREA GROWTH RATE 
HIGHEST_AREA_GROWTH_CROPS AS (SELECT
*
FROM YOY_AREA_GROWTH
WHERE year = 2019
ORDER BY yoy_growth DESC
LIMIT 10),

---- TEMPERATURE TABLE 
--- CLEANING DATA 
-- IDENTIFYING CLEANING REQUIREMENTS
TEMPERATURE_BY_COUNTRY AS (SELECT
country,
AVG(temperature) AS temperature
FROM temperature
WHERE DATE_PART('year', date) BETWEEN 1961 and 2013
AND temperature IS NOT NULL
GROUP BY country),

NULL_COUNTRIES AS (SELECT 
DISTINCT c.area, 
t.country, 
t.temperature
FROM clean_data c LEFT JOIN TEMPERATURE_BY_COUNTRY t 
ON c.area = t.country
WHERE t.country IS NULL
ORDER BY c.area),

CLEAN_TEMPERATURE AS (SELECT 
country, 
CASE 
WHEN country = 'Antigua And Barbuda' THEN 'Antigua and Barbuda'
WHEN country = 'Bolivia' THEN 'Bolivia (Plurinational State of)'
WHEN country = 'Bosnia And Herzegovina' THEN 'Bosnia and Herzegovina'
WHEN country = 'Cape Verde' THEN 'Cabo Verde'
WHEN country = 'Hong Kong' THEN 'China, Hong Kong SAR'
WHEN country = 'Macau' THEN 'China, Macao SAR'
WHEN country = 'Taiwan' THEN 'China, Taiwan Province of'
WHEN country = 'Czech Republic' THEN 'Czechia'
WHEN country = 'Congo (Democratic Republic Of The)' THEN 'Democratic Republic of the Congo'
WHEN country = 'Swaziland' THEN 'Eswatini'
WHEN country = 'Ethiopia' THEN 'Ethiopia PDR'
WHEN country = 'French Guiana' THEN 'French Guyana'
WHEN country = 'Guinea Bissau' THEN 'Guinea-Bissau'
WHEN country = 'Iran' THEN 'Iran (Islamic Republic of)'
WHEN country = 'Federated States Of Micronesia' THEN 'Micronesia (Federated States of)'
WHEN country = 'Burma' THEN 'Myanmar'
WHEN country = 'Macedonia' THEN 'North Macedonia' 
WHEN country = 'Palestina' THEN 'Palestine'
WHEN country = 'South Korea' THEN 'Republic of Korea'
WHEN country = 'Moldova' THEN 'Republic of Moldova'
WHEN country = 'Russia' THEN 'Russian Federation'
WHEN country = 'Saint Kitts And Nevis' THEN 'Saint Kitts and Nevis'
WHEN country = 'Saint Vincent And The Grenadines' THEN 'Saint Vincent and the Grenadines'
WHEN country = 'Sao Tome And Principe' THEN 'Sao Tome and Principe'
WHEN country = 'Syria' THEN 'Syrian Arab Republic'
WHEN country = 'Timor Leste' THEN 'Timor-Leste'
WHEN country = 'Trinidad And Tobago' THEN 'Trinidad and Tobago'
WHEN country = 'United Kingdom' THEN 'United Kingdom of Great Britain and Northern Ireland'
WHEN country = 'Tanzania' THEN 'United Republic of Tanzania'
WHEN country = 'United States' THEN 'United States of America'
WHEN country = 'Venezuela' THEN 'Venezuela (Bolivarian Republic of)'
WHEN country = 'Vietnam' THEN 'Viet Nam'
ELSE country 
END AS clean_country,
AVG(temperature) AS temperature
FROM TEMPERATURE_BY_COUNTRY
GROUP BY country, clean_country
ORDER BY country),

-- AVERAGE YIELD + TEMPERATURE DATA FOR EACH COUNTRY
JOIN_TEMPERATURE_YIELD AS (SELECT 
c.area, 
t.clean_country AS country, 
AVG(t.temperature) AS temperature,
AVG(c.value)*0.0001 AS yield
FROM clean_data c INNER JOIN CLEAN_TEMPERATURE t
ON c.area = t.clean_country
WHERE c.element = 'Yield'
AND c.year BETWEEN 1961 AND 2013
GROUP BY c.area, t.clean_country
ORDER BY c.area),

-- RAINFALL TABLE 
-- DATA CLEANING
NULL_COUNTRIES_RAINFALL AS (SELECT
c.area,
r.country,
AVG(r.rainfall)
FROM clean_data c LEFT JOIN rainfall r
ON c.area = r.country
WHERE r.country IS NULL
GROUP BY r.country, c.area
ORDER BY r.country),

CLEAN_RAINFALL AS (
SELECT 
*, 
CASE 
WHEN country = 'Bolivia' THEN 'Bolivia (Plurinational State of)'
WHEN country = 'Brunei' THEN 'Brunei Darussalam'
WHEN country = 'Cape Verde' THEN 'Cabo Verde'
WHEN country = 'China' THEN 'China, mainland'
WHEN country = 'Czechia' THEN 'Czechoslovakia'
WHEN country = 'Democratic Republic of Congo' THEN 'Democratic Republic of the Congo'
WHEN country = 'Ethiopia' THEN 'Ethiopia PDR'
WHEN country = 'Iran' THEN 'Iran (Islamic Republic of)'
WHEN country = 'South Korea' THEN 'Republic of Korea'
WHEN country = 'Moldova' THEN 'Republic of Moldova'
WHEN country = 'Russia' THEN 'Russian Federation'
WHEN country = 'Syria' THEN 'Syrian Arab Republic'
WHEN country = 'Timor' THEN 'Timor-Leste'
WHEN country = 'United Kingdom' THEN 'United Kingdom of Great Britain and Northern Ireland'
WHEN country = 'Tanzania' THEN 'United Republic of Tanzania'
WHEN country = 'United States' THEN 'United States of America'
WHEN country = 'Venezuela' THEN 'Venezuela (Bolivarian Republic of)'
WHEN country = 'Vietnam' THEN 'Viet Nam'
ELSE country
END AS clean_country
FROM rainfall),

-- AVERAGE YIELD + TEMPERATURE + RAINFALL DATA FOR EACH COUNTRY
AVERAGE_RAINFALL_TEMPERATURE_YIELD AS (SELECT 
j.country, 
j.temperature, 
j.yield,
AVG(r.rainfall) AS rainfall
FROM JOIN_TEMPERATURE_YIELD j INNER JOIN CLEAN_RAINFALL r
ON j.country = r.clean_country
GROUP BY j.country, j.temperature, j.yield
ORDER BY j.country),

---- FERTILIZER TABLE 
--- DATA CLEANING 
NULL_COUNTRIES_FERTILIZER AS (SELECT
DISTINCT c.area,
f.country
FROM clean_data c LEFT JOIN fertilizer f
ON c.area = f.country
WHERE f.country IS NULL
ORDER BY c.area),

NULL_CROPS AS (SELECT 
DISTINCT c.item, 
f.crop
FROM clean_data c LEFT JOIN fertilizer f
ON c.item = f.crop
WHERE f.crop IS NULL
ORDER BY c.item),

CLEAN_CROPS AS (SELECT
*,
CASE 
WHEN crop = 'Almond' THEN 'Almonds, with shell'
WHEN crop = 'Apricot' THEN 'Apricots'
WHEN crop = 'Arecanut' THEN 'Areca nuts'
WHEN crop = 'Artichoke' THEN 'Artichokes'
WHEN crop = 'Avocado' THEN 'Avocados'
WHEN crop = 'Banana' THEN 'Bananas'
WHEN crop = 'Dry beans' THEN 'Beans, dry'
WHEN crop = 'Green beans' THEN 'Beans, green'
WHEN crop = 'Buckwheat & millet' THEN 'Buckwheat'
WHEN crop = 'Cabbage' THEN 'Cabbages and other brassicas'
WHEN crop IN ('Carrot','carrot') THEN 'Carrots and turnips'
WHEN crop IN ('Broccoli','Cauliflower','cauliflower') THEN 'Cauliflowers and broccoli'
WHEN crop = 'Cherry' THEN 'Cherries'
WHEN crop IN ('Chick pea','Chickpea','Chickpeas') THEN 'Chick peas'
WHEN crop = 'Pepper and chilli' THEN 'Chillies and peppers, dry'
WHEN crop = 'Clover' THEN 'Cloves'
WHEN crop IN ('coconut','Coconut') THEN 'Coconuts'
WHEN crop = 'Coffee green' THEN 'Coffee, green'
WHEN crop = 'Cowpea' THEN 'Cow peas, dry'
WHEN crop = 'Cranbery' THEN 'Cranberries'
WHEN crop IN ('cucumber','Cucumber') THEN 'Cucumbers and gherkins'
WHEN crop = 'Date' THEN 'Dates'
WHEN crop = 'Eggplant' THEN 'Eggplants (aubergines)'
WHEN crop = 'Fibre flax' THEN 'Flax fibre and tow'
WHEN crop = 'Mixed grains' THEN 'Grain, mixed'
WHEN crop = 'Grapefruit' THEN 'Grapefruit (inc. pomelos)'
WHEN crop = 'Grape' THEN 'Grapes'
WHEN crop = 'Groundnut' THEN 'Groundnuts, with shell'
WHEN crop = 'Hazelnut' THEN 'Hazelnuts, with shell'
WHEN crop = 'Hemp/Tow' THEN 'Hempseed'
WHEN crop = 'Hop' THEN 'Hops'
WHEN crop IN ('Kiwi','Kiwifruit') THEN 'Kiwi fruit'
WHEN crop IN ('Lemon and lime','Lemon') THEN 'Lemons and limes'
WHEN crop = 'Lettuce' THEN 'Lettuce and chicory'
WHEN crop = 'Mango' THEN 'Mangoes, mangosteens, guavas'
WHEN crop = 'Cantaloupe & melons' THEN 'Melons, other (inc.cantaloupes)'
WHEN crop = 'Mustard' THEN 'Mustard seed'
WHEN crop IN ('Oil-Palm','Oil Palm','Oil-palm','Oil palm') THEN 'Oil palm fruit'
WHEN crop = 'Olive' THEN 'Olives'
WHEN crop IN ('Dry onions','Onion/Dry') THEN 'Onions, dry'
WHEN crop IN ('Pea, dry','Pea/Dry') THEN 'Peas, dry'
WHEN crop = 'Pea, green' THEN 'Peas, green'
WHEN crop = 'Pepper' THEN 'Pepper (piper spp.)'
WHEN crop = 'Pineapple' THEN 'Pineapples'
WHEN crop = 'Pistachio' THEN 'Pistachios'
WHEN crop = 'Plantain' THEN 'Plantains and others'
WHEN crop = 'Plum' THEN 'Plums and sloes'
WHEN crop = 'Poppy' THEN 'Poppy seed'
WHEN crop = 'Potato' THEN 'Potatoes'
WHEN crop IN ('Squash','Squash and gourd','Squash/Gourd') THEN 'Pumpkins, squash and gourds'
WHEN crop = 'Raspberry' THEN 'Raspberries'
WHEN crop = 'Rubber' THEN 'Rubber, natural'
WHEN crop = 'Sesame' THEN 'Sesame seed'
WHEN crop = 'Strawberry' THEN 'Strawberries'
WHEN crop IN ('Potato, sweet','Potato sweet','Potato/Sweet','Potato (sweet)','Potato (Sweet)') THEN 'Sweet potatoes'
WHEN crop = 'Tangerine' THEN 'Tangerines, mandarins, clementines, satsumas'
WHEN crop IN ('Tobacco','Tobacco leaves') THEN 'Tobacco, unmanufactured'
WHEN crop IN ('Tomato','Tomato/Fresh','Fresh tomatoes') THEN 'Tomatoes'
WHEN crop = 'Vetch' THEN 'Vetches'
WHEN crop IN ('Watermelon','Water-melon','Water-Melon','Water Melon','WaterMelon') THEN 'Watermelons'
WHEN crop = 'Yam' THEN 'Yams'
WHEN crop IN ('Sugarcane', 'Sugar cane', 'Sugar Cane', 'sugar Cane', 'sugar cane') THEN 'Sugar cane'
ELSE crop 
END AS clean_crop
FROM fertilizer),

CLEAN_COUNTRIES_FERTILIZER AS (SELECT 
*, 
CASE 
WHEN country = 'China' THEN 'China, mainland'
WHEN country = 'China, Taiwan' THEN 'China, Taiwan Province of'
WHEN country = 'Czech Republic' THEN 'Czechia'
WHEN country = 'Ethiopia PDR' THEN 'Ethiopia'
WHEN country = 'Venezuela, Bolivarian Republic of' THEN 'Venezuela (Bolivarian Republic of)'
ELSE country
END AS clean_country
FROM CLEAN_CROPS),

CLEAN_FERTILIZER AS (SELECT
clean_country AS country,
CAST(year AS INT),
clean_crop AS crop,
CAST(NULLIF(crop_area, 'NA') AS FLOAT) AS crop_area,
CAST(NULLIF(total_n, 'NA') AS FLOAT) AS total_n,
CAST(NULLIF(total_p, 'NA') AS FLOAT) AS total_p,
CAST(NULLIF(total_k, 'NA') AS FLOAT) AS total_k,
CAST(NULLIF(total_compound, 'NA') AS FLOAT) AS total_compound,
CAST(NULLIF(rate_n, 'NA') AS FLOAT) AS rate_n, 
CAST(NULLIF(rate_p, 'NA') AS FLOAT) AS rate_p,
CAST(NULLIF(rate_k, 'NA') AS FLOAT) AS rate_k, 
CAST(NULLIF(fertilized_area_n, 'NA') AS FLOAT) AS fertilized_area_n, 
CAST(NULLIF(fertilized_area_p, 'NA') AS FLOAT) AS fertilized_area_p,
CAST(NULLIF(fertilized_area_k, 'NA') AS FLOAT) AS fertilized_area_k,
CAST(NULLIF(gross_rate_n, 'NA') AS FLOAT) AS gross_rate_n, 
CAST(NULLIF(gross_rate_p, 'NA') AS FLOAT) AS gross_rate_p,
CAST(NULLIF(gross_rate_k, 'NA') AS FLOAT) AS gross_rate_k, 
CAST(NULLIF(gross_rate_compound, 'NA') AS FLOAT) AS gross_rate_compound
FROM CLEAN_COUNTRIES_FERTILIZER
WHERE year NOT ILIKE ('%-%') AND year NOT ILIKE ('%/%')),

---- IRRIGATION TABLE 
-- DATA CLEANING 
NULL_COUNTRIES_IRRIGATION AS (SELECT
DISTINCT c.area,
i.country
FROM clean_data c LEFT JOIN irrigation i
ON c.area = i.country
WHERE i.country IS NULL 
ORDER BY c.area),

CLEAN_IRRIGATION AS (SELECT
country,
CAST(NULLIF(avg_irrigated_area, 'NA') AS FLOAT) AS avg_irrigated_area,
CASE 
WHEN country = 'Bahamas, The' THEN 'Bahamas'
WHEN country = 'Bolivia' THEN 'Bolivia (Plurinational State of)'
WHEN country = 'Hong Kong SAR, China' THEN 'China, Hong Kong SAR'
WHEN country = 'Macao SAR, China' THEN 'China, Macao SAR'
WHEN country = 'China' THEN 'China, mainland'
WHEN country = 'Congo, Rep.' THEN 'Congo'
WHEN country = 'Czechia' THEN 'Czechoslovakia'
WHEN country = 'Congo, Dem. Rep.' THEN 'Democratic Republic of the Congo'
WHEN country = 'Egypt, Arab Rep.' THEN 'Egypt'
WHEN country = 'Ethiopia' THEN 'Ethiopia PDR'
WHEN country = 'Gambia, The' THEN 'Gambia'
WHEN country = 'Iran, Islamic Rep.' THEN 'Iran (Islamic Republic of)'
WHEN country = 'Kyrgyz Republic' THEN 'Kyrgyzstan'
WHEN country = 'Micronesia, Fed. Sts.' THEN 'Micronesia (Federated States of)'
WHEN country = 'Korea, Rep.' THEN 'Republic of Korea'
WHEN country = 'Moldova' THEN 'Republic of Moldova'
WHEN country = 'St. Kitts and Nevis' THEN 'Saint Kitts and Nevis'
WHEN country = 'St. Lucia' THEN 'Saint Lucia'
WHEN country = 'St. Vincent and the Grenadines' THEN 'Saint Vincent and the Grenadines'
WHEN country = 'Slovak Republic' THEN 'Slovakia'
WHEN country = 'Turkiye' THEN 'Turkey'
WHEN country = 'United Kingdom' THEN 'United Kingdom of Great Britain and Northern Ireland'
WHEN country = 'Tanzania' THEN 'United Republic of Tanzania'
WHEN country = 'United States' THEN 'United States of America'
WHEN country = 'Venezuela, RB' THEN 'Venezuela (Bolivarian Republic of)'
WHEN country = 'Vietnam' THEN 'Viet Nam'
WHEN country = 'Yemen, Rep.' THEN 'Yemen'
ELSE country
END AS clean_country
FROM irrigation),

---- PESTICIDES TABLE
--- DATA CLEANING
NULL_COUNTRIES_PESTICIDES AS (SELECT
DISTINCT c.area,
p.country
FROM clean_data c LEFT JOIN pesticides p
ON c.area = p.country
WHERE p.country IS NULL
ORDER BY c.area),

CLEAN_PESTICIDES AS (SELECT
*,
CASE 
WHEN country = 'Bolivia' THEN 'Bolivia (Plurinational State of)'
WHEN country = 'Brunei' THEN 'Brunei Darussalam'
WHEN country = 'Hong Kong' THEN 'China, Hong Kong SAR'
WHEN country = 'China' THEN 'China, mainland'
WHEN country = 'Taiwan' THEN 'China, Taiwan Province of'
WHEN country = 'Czech Republic (Czechia)' THEN 'Czechia'
WHEN country = 'Dominican Republic' THEN 'Dominica'
WHEN country = 'Ethiopia' THEN 'Ethiopia PDR'
WHEN country = 'Iran' THEN 'Iran (Islamic Republic of)'
WHEN country = 'State of Palestine' THEN 'Palestine'
WHEN country = 'South Korea' THEN 'Republic of Korea'
WHEN country = 'Moldova' THEN 'Republic of Moldova'
WHEN country = 'Russia' THEN 'Russian Federation'
WHEN country = 'Saint Kitts & Nevis' THEN 'Saint Kitts and Nevis'
WHEN country = 'Syria' THEN 'Syrian Arab Republic'
WHEN country = 'United Kingdom' THEN 'United Kingdom of Great Britain and Northern Ireland'
WHEN country = 'Tanzania' THEN 'United Republic of Tanzania'
WHEN country = 'United States' THEN 'United States of America'
WHEN country = 'Venezuela' THEN 'Venezuela (Bolivarian Republic of)'
WHEN country = 'Vietnam' THEN 'Viet Nam'
ELSE country 
END AS clean_country
FROM pesticides),

---- TRACTOR TABLE 
--- DATA CLEANING 
NULL_COUNTRIES_TRACTOR AS (SELECT 
DISTINCT c.area, 
t.country
FROM clean_data c LEFT JOIN tractor t
ON c.area = t.country
WHERE t.country IS NULL
ORDER BY c.area),

CLEAN_TRACTOR AS (SELECT 
country,
CAST(NULLIF(avg_tractor_density, 'NA') AS FLOAT) AS avg_tractor_density,
CASE 
WHEN country = 'Bolivia' THEN 'Bolivia (Plurinational State of)'
WHEN country = 'Hong Kong SAR' THEN 'China, Hong Kong SAR'
WHEN country = 'Macao SAR' THEN 'China, Macao SAR'
WHEN country = 'China' THEN 'China, mainland'
WHEN country = 'Ethiopia' THEN 'Ethiopia PDR'
WHEN country = 'Iran' THEN 'Iran (Islamic Republic of)'
WHEN country = 'Kyrgyz Republic' THEN 'Kyrgyzstan'
WHEN country = 'Micronesia' THEN 'Micronesia (Federated States of)'
WHEN country = 'Korea' THEN 'Republic of Korea'
WHEN country = 'Moldova' THEN 'Republic of Moldova'
WHEN country = 'St. Kitts and Nevis' THEN 'Saint Kitts and Nevis'
WHEN country = 'St. Lucia' THEN 'Saint Lucia'
WHEN country = 'St. Vincent and the Grenadines' THEN 'Saint Vincent and the Grenadines'
WHEN country = 'Slovak Republic' THEN 'Slovakia'
WHEN country = 'Turkiye' THEN 'Turkey'
WHEN country = 'United Kingdom' THEN 'United Kingdom of Great Britain and Northern Ireland'
WHEN country = 'Tanzania' THEN 'Republic of Tanzania'
WHEN country = 'United States' THEN 'United States of America'
WHEN country = 'Venezuela' THEN 'Venezuela (Bolivarian Republic of)'
WHEN country = 'Vietnam' THEN 'Viet Nam'
ELSE country 
END AS clean_country
FROM tractor),

---- MINMAXTEMPERATURE TABLE 
-- DATA CLEANING 
MINMAXT_NULL_COUNTRIES AS (SELECT
DISTINCT c.area, 
m.country
FROM clean_data c LEFT JOIN minmaxtemperature m
ON c.area = m.country
WHERE m.country IS NULL
ORDER BY c.area),

CLEAN_MINMAX_COUNTRY AS (SELECT
*,
CASE 
WHEN country = 'Iran (Islamic Republic of)' THEN 'Iran'
WHEN country = 'South Korea' THEN 'Republic of Korea'
WHEN country = 'Moldova' THEN 'Republic of Moldova'
WHEN country = 'Russia' THEN 'Russian Federation'
WHEN country = 'Syria' THEN 'Syrian Arab Republic'
WHEN country = 'United Kingdom' THEN 'United Kingdom of Great Britain and Northern Ireland'
WHEN country = 'United States' THEN 'United States of America'
WHEN country = 'Vietnam' THEN 'Viet Nam'
ELSE country
END AS clean_country
FROM minmaxtemperature),

CLEAN_MINMAX AS (SELECT 
clean_country AS country, 
min,
max
FROM CLEAN_MINMAX_COUNTRY),

---- CREATING YIELD PREDICTION DATASETS (YIELD + TEMPERATURE + RAINFALL + FERTILIZER + IRRIGATION + TRACTORS + PESTICIDES)
-- ALL CROPS 
-- AVERAGE ALL-CROP YIELD PREDICTION 
AVERAGE_YIELD_PREDICTION_BY_COUNTRY AS (SELECT
a.country AS country, 
a.temperature,
a.rainfall,
a.yield,
i.avg_irrigated_area,
p.rate_pesticides, 
p.total_pesticides,
t.avg_tractor_density,
AVG(f.total_n) AS avg_total_n,
AVG(f.total_p) AS avg_total_p,
AVG(f.total_k) AS avg_total_k,
AVG(f.total_compound) AS avg_total_compound,
AVG(f.rate_n) AS avg_rate_n,
AVG(f.rate_p) AS avg_rate_p,
AVG(f.rate_k) AS avg_rate_k,
AVG(f.fertilized_area_n) AS avg_fertilized_area_n,
AVG(f.fertilized_area_p) AS avg_fertilized_area_p,
AVG(f.fertilized_area_k) AS avg_fertilized_area_k,
AVG(f.gross_rate_n) AS avg_gross_rate_n,
AVG(f.gross_rate_p) AS avg_gross_rate_p,
AVG(f.gross_rate_k) AS avg_gross_rate_k,
AVG(f.gross_rate_compound) AS avg_gross_rate_compound,
m.min, 
m.max
FROM AVERAGE_RAINFALL_TEMPERATURE_YIELD a INNER JOIN CLEAN_FERTILIZER f
ON a.country = f.country
INNER JOIN CLEAN_IRRIGATION i 
ON a.country = i.clean_country
INNER JOIN CLEAN_PESTICIDES p 
ON a.country = p.clean_country
INNER JOIN CLEAN_TRACTOR t
ON a.country = t.clean_country
INNER JOIN CLEAN_MINMAX m
ON a.country = m.country
WHERE f.year BETWEEN 1961 AND 2013
GROUP BY a.country, a.temperature, a.rainfall, a.yield, i.avg_irrigated_area, p.rate_pesticides, p.total_pesticides, t.avg_tractor_density, m.min, m.max
ORDER BY country),

-- AVERAGE BY-CROP YIELD PREDICTION
YIELD_COUNTRY_CROP AS (SELECT 
area AS country, 
item AS crop,
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND year BETWEEN 1961 AND 2013 
GROUP BY area, item),

AVERAGE_BY_CROP_YIELD_PREDICTION AS (SELECT 
y.country AS country, 
y.crop,
y.yield,
AVG(t.temperature) AS temperature,
AVG(r.rainfall) AS rainfall,
i.avg_irrigated_area,
p.rate_pesticides, 
p.total_pesticides,
tr.avg_tractor_density,
AVG(f.total_n) AS avg_total_n,
AVG(f.total_p) AS avg_total_p,
AVG(f.total_k) AS avg_total_k,
AVG(f.total_compound) AS avg_total_compound,
AVG(f.rate_n) AS avg_rate_n,
AVG(f.rate_p) AS avg_rate_p,
AVG(f.rate_k) AS avg_rate_k,
AVG(f.fertilized_area_n) AS avg_fertilized_area_n,
AVG(f.fertilized_area_p) AS avg_fertilized_area_p,
AVG(f.fertilized_area_k) AS avg_fertilized_area_k,
AVG(f.gross_rate_n) AS avg_gross_rate_n,
AVG(f.gross_rate_p) AS avg_gross_rate_p,
AVG(f.gross_rate_k) AS avg_gross_rate_k,
AVG(f.gross_rate_compound) AS avg_gross_rate_compound,
m.min, 
m.max
FROM YIELD_COUNTRY_CROP y INNER JOIN CLEAN_TEMPERATURE t
ON y.country = t.country
INNER JOIN CLEAN_RAINFALL r
ON y.country = r.country
INNER JOIN CLEAN_FERTILIZER f 
ON y.country = f.country
AND y.crop = f.crop
INNER JOIN CLEAN_IRRIGATION i 
ON y.country = i.clean_country
INNER JOIN CLEAN_PESTICIDES p 
ON y.country = p.clean_country
INNER JOIN CLEAN_TRACTOR tr
ON y.country = tr.clean_country
INNER JOIN CLEAN_MINMAX m 
ON y.country = m.country
GROUP BY y.country, y.crop, y.yield, i.avg_irrigated_area, p.rate_pesticides, p.total_pesticides, tr.avg_tractor_density, m.min, m.max
ORDER BY y.country, y.crop),


-- SPECIFIC CROPS
-- SUGAR CANE YIELD PREDICTION
SUGAR_CANE_YIELD AS (SELECT 
area AS country,
item AS crop,
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND item = 'Sugar cane'
AND year BETWEEN 1961 AND 2013
GROUP BY area, item),

SUGAR_CANE_YIELD_PREDICTION AS (SELECT 
s.country, 
s.crop,
s.yield,
AVG(t.temperature) AS temperature,
AVG(r.rainfall) AS rainfall,
i.avg_irrigated_area,
p.rate_pesticides, 
p.total_pesticides,
tr.avg_tractor_density,
AVG(f.total_n) AS avg_total_n,
AVG(f.total_p) AS avg_total_p,
AVG(f.total_k) AS avg_total_k,
AVG(f.total_compound) AS avg_total_compound,
AVG(f.rate_n) AS avg_rate_n,
AVG(f.rate_p) AS avg_rate_p,
AVG(f.rate_k) AS avg_rate_k,
AVG(f.fertilized_area_n) AS avg_fertilized_area_n,
AVG(f.fertilized_area_p) AS avg_fertilized_area_p,
AVG(f.fertilized_area_k) AS avg_fertilized_area_k,
AVG(f.gross_rate_n) AS avg_gross_rate_n,
AVG(f.gross_rate_p) AS avg_gross_rate_p,
AVG(f.gross_rate_k) AS avg_gross_rate_k,
AVG(f.gross_rate_compound) AS avg_gross_rate_compound,
m.min, 
m.max
FROM SUGAR_CANE_YIELD s INNER JOIN CLEAN_TEMPERATURE t
ON s.country = t.country
INNER JOIN CLEAN_RAINFALL r
ON s.country = r.country
INNER JOIN CLEAN_FERTILIZER f 
ON s.country = f.country
AND s.crop = f.crop
INNER JOIN CLEAN_IRRIGATION i 
ON s.country = i.clean_country
INNER JOIN CLEAN_PESTICIDES p 
ON s.country = p.clean_country
INNER JOIN CLEAN_TRACTOR tr
ON s.country = tr.clean_country
INNER JOIN CLEAN_MINMAX m 
ON s.country = m.country
GROUP BY s.country, s.crop, s.yield, i.avg_irrigated_area, p.rate_pesticides, p.total_pesticides, tr.avg_tractor_density, m.min, m.max
ORDER BY s.country, s.crop),

-- MAIZE YIELD PREDICTION
MAIZE_YIELD AS (SELECT 
area AS country,
item AS crop,
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND item = 'Maize'
AND year BETWEEN 1961 AND 2013
GROUP BY area, item),

MAIZE_YIELD_PREDICTION AS (SELECT 
s.country, 
s.crop,
s.yield,
AVG(t.temperature) AS temperature,
AVG(r.rainfall) AS rainfall,
i.avg_irrigated_area,
p.rate_pesticides, 
p.total_pesticides,
tr.avg_tractor_density,
AVG(f.total_n) AS avg_total_n,
AVG(f.total_p) AS avg_total_p,
AVG(f.total_k) AS avg_total_k,
AVG(f.total_compound) AS avg_total_compound,
AVG(f.rate_n) AS avg_rate_n,
AVG(f.rate_p) AS avg_rate_p,
AVG(f.rate_k) AS avg_rate_k,
AVG(f.fertilized_area_n) AS avg_fertilized_area_n,
AVG(f.fertilized_area_p) AS avg_fertilized_area_p,
AVG(f.fertilized_area_k) AS avg_fertilized_area_k,
AVG(f.gross_rate_n) AS avg_gross_rate_n,
AVG(f.gross_rate_p) AS avg_gross_rate_p,
AVG(f.gross_rate_k) AS avg_gross_rate_k,
AVG(f.gross_rate_compound) AS avg_gross_rate_compound,
m.min, 
m.max
FROM MAIZE_YIELD s INNER JOIN CLEAN_TEMPERATURE t
ON s.country = t.country
INNER JOIN CLEAN_RAINFALL r
ON s.country = r.country
INNER JOIN CLEAN_FERTILIZER f 
ON s.country = f.country
AND s.crop = f.crop
INNER JOIN CLEAN_IRRIGATION i 
ON s.country = i.clean_country
INNER JOIN CLEAN_PESTICIDES p 
ON s.country = p.clean_country
INNER JOIN CLEAN_TRACTOR tr
ON s.country = tr.clean_country
INNER JOIN CLEAN_MINMAX m 
ON s.country = m.country
GROUP BY s.country, s.crop, s.yield, i.avg_irrigated_area, p.rate_pesticides, p.total_pesticides, tr.avg_tractor_density, m.min, m.max
ORDER BY s.country, s.crop),

-- WHEAT YIELD PREDICTION
WHEAT_YIELD AS (SELECT 
area AS country,
item AS crop,
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND item = 'Wheat'
AND year BETWEEN 1961 AND 2013
GROUP BY area, item),

WHEAT_YIELD_PREDICTION AS (SELECT 
s.country, 
s.crop,
s.yield,
AVG(t.temperature) AS temperature,
AVG(r.rainfall) AS rainfall,
i.avg_irrigated_area,
p.rate_pesticides, 
p.total_pesticides,
tr.avg_tractor_density,
AVG(f.total_n) AS avg_total_n,
AVG(f.total_p) AS avg_total_p,
AVG(f.total_k) AS avg_total_k,
AVG(f.total_compound) AS avg_total_compound,
AVG(f.rate_n) AS avg_rate_n,
AVG(f.rate_p) AS avg_rate_p,
AVG(f.rate_k) AS avg_rate_k,
AVG(f.fertilized_area_n) AS avg_fertilized_area_n,
AVG(f.fertilized_area_p) AS avg_fertilized_area_p,
AVG(f.fertilized_area_k) AS avg_fertilized_area_k,
AVG(f.gross_rate_n) AS avg_gross_rate_n,
AVG(f.gross_rate_p) AS avg_gross_rate_p,
AVG(f.gross_rate_k) AS avg_gross_rate_k,
AVG(f.gross_rate_compound) AS avg_gross_rate_compound,
m.min,
m.max
FROM WHEAT_YIELD s INNER JOIN CLEAN_TEMPERATURE t
ON s.country = t.country
INNER JOIN CLEAN_RAINFALL r
ON s.country = r.country
INNER JOIN CLEAN_FERTILIZER f 
ON s.country = f.country
AND s.crop = f.crop
INNER JOIN CLEAN_IRRIGATION i 
ON s.country = i.clean_country
INNER JOIN CLEAN_PESTICIDES p 
ON s.country = p.clean_country
INNER JOIN CLEAN_TRACTOR tr
ON s.country = tr.clean_country
INNER JOIN CLEAN_MINMAX m 
ON s.country = m.country
GROUP BY s.country, s.crop, s.yield, i.avg_irrigated_area, p.rate_pesticides, p.total_pesticides, tr.avg_tractor_density, m.min, m.max
ORDER BY s.country, s.crop),

-- POTATO YIELD PREDICTION
POTATO_YIELD AS (SELECT 
area AS country,
item AS crop,
AVG(value)*0.0001 AS yield
FROM clean_data
WHERE element = 'Yield'
AND item = 'Potatoes'
AND year BETWEEN 1961 AND 2013
GROUP BY area, item),

POTATO_YIELD_PREDICTION AS (SELECT 
s.country, 
s.crop,
s.yield,
AVG(t.temperature) AS temperature,
AVG(r.rainfall) AS rainfall,
i.avg_irrigated_area,
p.rate_pesticides, 
p.total_pesticides,
tr.avg_tractor_density,
AVG(f.total_n) AS avg_total_n,
AVG(f.total_p) AS avg_total_p,
AVG(f.total_k) AS avg_total_k,
AVG(f.total_compound) AS avg_total_compound,
AVG(f.rate_n) AS avg_rate_n,
AVG(f.rate_p) AS avg_rate_p,
AVG(f.rate_k) AS avg_rate_k,
AVG(f.fertilized_area_n) AS avg_fertilized_area_n,
AVG(f.fertilized_area_p) AS avg_fertilized_area_p,
AVG(f.fertilized_area_k) AS avg_fertilized_area_k,
AVG(f.gross_rate_n) AS avg_gross_rate_n,
AVG(f.gross_rate_p) AS avg_gross_rate_p,
AVG(f.gross_rate_k) AS avg_gross_rate_k,
AVG(f.gross_rate_compound) AS avg_gross_rate_compound,
m.min,
m.max
FROM POTATO_YIELD s INNER JOIN CLEAN_TEMPERATURE t
ON s.country = t.country
INNER JOIN CLEAN_RAINFALL r
ON s.country = r.country
INNER JOIN CLEAN_FERTILIZER f 
ON s.country = f.country
AND s.crop = f.crop
INNER JOIN CLEAN_IRRIGATION i 
ON s.country = i.clean_country
INNER JOIN CLEAN_PESTICIDES p 
ON s.country = p.clean_country
INNER JOIN CLEAN_TRACTOR tr
ON s.country = tr.clean_country
INNER JOIN CLEAN_MINMAX m
ON s.country = m.country
GROUP BY s.country, s.crop, s.yield, i.avg_irrigated_area, p.rate_pesticides, p.total_pesticides, tr.avg_tractor_density, m.min, m.max
ORDER BY s.country, s.crop),


---- INPUT ANALYSIS 
-- PESTICIDE
PESTICIDE_RATE_BY_COUNTRY AS (SELECT
clean_country, 
rate_pesticides
FROM CLEAN_PESTICIDES
ORDER BY rate_pesticides DESC),

-- FERTILIZER
AMOUNT_OF_COUNTRIES_AND_CROPS_MEASURED_BY_YEAR AS (SELECT
year, 
COUNT(DISTINCT country), 
COUNT(DISTINCT crop)
FROM CLEAN_FERTILIZER
GROUP BY year 
ORDER BY year),

YEARS_REGISTERED_BY_CROP AS (SELECT
crop,
COUNT(DISTINCT year), 
MAX(year),
MIN(year)
FROM CLEAN_FERTILIZER
GROUP BY crop
ORDER BY COUNT(DISTINCT year) DESC),

YEARS_REGISTERED_BY_COUNTRY AS (SELECT 
country,
COUNT(DISTINCT year), 
MAX(year),
MIN(year)
FROM CLEAN_FERTILIZER
GROUP BY country
ORDER BY COUNT(DISTINCT year) DESC),

MAIZE_FERTILIZER_EVOLUTION AS (SELECT 
year,
AVG(rate_n),
AVG(rate_p),
AVG(rate_k)
FROM CLEAN_FERTILIZER
WHERE crop = 'Maize'
GROUP BY year
ORDER BY year)

-- CALLING ANY QUERY
SELECT
*
FROM MOST_PRODUCED_CROPS







