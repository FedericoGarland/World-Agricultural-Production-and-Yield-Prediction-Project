CREATE TABLE crops (
area_code FLOAT, 
area VARCHAR, 
item_code FLOAT, 
item TEXT, 
element_code FLOAT,
element VARCHAR, 
year_code FLOAT,
year INT, 
unit VARCHAR, 
value FLOAT, 
flag VARCHAR
); 

CREATE TABLE temperature (
date DATE, 
temperature FLOAT, 
temperature_error FLOAT, 
country TEXT);

CREATE TABLE rainfall ( 
country TEXT, 
code TEXT, 
year INT, 
rainfall FLOAT);

CREATE TABLE fertilizer (
original_country TEXT, 
country TEXT, 
country_code TEXT, 
region TEXT, 
year TEXT, 
report INT, 
report_year TEXT,
crop TEXT, 
crop_area TEXT,
total_N TEXT,
total_P TEXT,
total_K TEXT,
total_compound TEXT, 
rate_N TEXT,
rate_P TEXT,
rate_K TEXT,
fertilized_area_N TEXT,
fertilized_area_P TEXT,
fertilized_area_K TEXT,
gross_rate_N TEXT,
gross_rate_P TEXT,
gross_rate_K TEXT,
gross_rate_compound TEXT);

CREATE TABLE irrigation (
country TEXT,
avg_irrigated_area TEXT);

CREATE TABLE pesticides (
country TEXT, 
total_pesticides FLOAT, 
rate_pesticides FLOAT);

CREATE TABLE tractor (
country TEXT,
avg_tractor_density TEXT);

CREATE TABLE minmaxtemperature (
country TEXT,
min FLOAT,
max FLOAT);

SET client_encoding = 'ISO_8859_5';
COPY crops FROM 'C:/Users/Public/crops.csv' DELIMITER ',' HEADER CSV;
COPY temperature FROM 'C:/Users/Public/temperature.csv' DELIMITER ',' HEADER CSV;
COPY rainfall FROM 'C:/Users/Public/rainfall.csv' DELIMITER ',' HEADER CSV;
COPY fertilizer FROM 'C:/Users/Public/fertilizer.csv' DELIMITER ',' HEADER CSV;
COPY irrigation FROM 'C:/Users/Public/irrigation_clean.csv' DELIMITER ';' HEADER CSV;
COPY pesticides FROM 'C:/Users/Public/pesticides.csv' DELIMITER ';' HEADER CSV;
COPY tractor FROM 'C:/Users/Public/tractor_clean.csv' DELIMITER ';' HEADER CSV;
COPY minmaxtemperature FROM 'C:/Users/Public/minmaxtemperature.csv' DELIMITER ';' HEADER CSV;