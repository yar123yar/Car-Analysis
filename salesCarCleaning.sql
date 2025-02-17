USE sales_car;
 SET NAMES 'utf8mb4';
 
CREATE TABLE IF NOT EXISTS `car_prices_copy` (
  `year` text NULL,
  `make` text NULL,
  `model` text NULL,
  `trim` text NULL,
  `body` text NULL,
  `transmission` text NULL,
  `vin` text NULL,
  `state` text NULL,
  `condition` text NULL,
  `odometer` text NULL,
  `color` text NULL,
  `interior` text NULL,
  `seller` text NULL,
  `mmr` text NULL,
  `sellingprice` text NULL,
  `saledate` text NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*
	This code is used to enable and execute the process of loading a local CSV file into a MySQL table. The first command, SHOW VARIABLES LIKE "local_infile";, 
	checks whether the local_infile feature is enabled, as it allows MySQL to read data from local files. 
	If it is disabled, the command SET GLOBAL local_infile = 1; is executed to enable it. 
	The LOAD DATA LOCAL INFILE statement is then used to efficiently import data from the "car_prices.csv" 
	file into the car_prices_copy table. The FIELDS TERMINATED BY ',' and ENCLOSED BY '"' ensure 
	that MySQL correctly interprets the CSV format by specifying that fields are separated by commas and may be enclosed in double quotes. 
	LINES TERMINATED BY '\n' ensures that each row is correctly recognized based on newline characters, 
	and IGNORE 1 ROWS skips the header row of the CSV file. 
	This method is preferred over INSERT statements for large datasets as it is much faster and optimized for bulk data loading.
*/

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE "C:\\Users\\muiva\\OneDrive\\Desktop\\Data Analysis\\Projects\\6.Car Sale Analysis\\car_prices.csv"
INTO TABLE car_prices_copy
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM sales_car.car_prices_copy; 

-- 1) create a staging table and copy the data into staging table

CREATE TABLE IF NOT EXISTS carPricesStaging LIKE car_prices_copy; 
INSERT INTO carPricesStaging 
SELECT * FROM  car_prices_copy;

 -- 2) Check Duplicate 
WITH duplicateCte AS
 (
	SELECT *,
	ROW_NUMBER() OVER( PARTITION BY 
	`year`, make, model, trim, body, transmission, vin, state, `condition`, odometer, color, interior, seller, mmr, sellingprice, saledate) AS `duplicate`
	FROM carPricesStaging
 )	SELECT * FROM duplicateCte
 WHERE `duplicate` > 1;
 
-- Standardizing data
-- The NULLIF(column, '') function checks if the column value is an empty string and converts it to NULL.
START TRANSACTION;
	UPDATE carPricesStaging  
		SET `year` = NULLIF(`year`, ''),
			`make` = NULLIF(`make`, ''),
			`model` = NULLIF(`model`, ''),
			`body` = NULLIF(`body`, ''),
			`transmission` = NULLIF(`transmission`, ''),  
			mmr = NULLIF(mmr, ''),  
            `state` = NULLIF(`state`, ''),
            `color` = NULLIF(`color`, ''),
            `vin` = NULLIF(`vin`, ''),
            `interior` = NULLIF(`interior`, ''),
            `seller` = NULLIF(`seller`, ''),
			`condition` = NULLIF(`condition`, ''),  
			sellingprice = NULLIF(sellingprice, '') ,
			saledate =  NULLIF(saledate, '
		') 
	WHERE `year` = '' OR make = '' OR `model` = '' OR `trim` = '' OR body = '' OR transmission = '' OR vin = '' OR `condition` = '' OR
    odometer = ''OR color = '' OR interior= ''OR seller= '' OR mmr = '' OR sellingprice = '';
COMMIT;

# Converting data type
START TRANSACTION;
	ALTER TABLE carPricesStaging
	MODIFY COLUMN `year` int NULL,
	MODIFY COLUMN mmr int NULL,
	MODIFY COLUMN `condition` float NULL,
	MODIFY COLUMN `sellingprice` int NULL;
COMMIT;

UPDATE carPricesStaging
SET make = "Dodge Tak"
WHERE make = "dodge tk";

## Convert data into proper rating value, example 45 = 4.5
START TRANSACTION;
	UPDATE carPricesStaging
	SET `condition` = ROUND(`condition` / 10, 1)
	WHERE `condition` BETWEEN 10 AND 99;
COMMIT;

# Removing unwanted space
UPDATE carPricesStaging
SET `year` = TRIM(`year`), 
	make = TRIM(make),
	 model = TRIM(model), 
	 trim = TRIM(trim),  
	 body = TRIM(body),
	 transmission = TRIM(transmission), 
	 vin = TRIM(vin), 
	 state = TRIM(state),  
	 `condition` = TRIM(`condition`), 
	 odometer = TRIM(odometer), 
	 color = TRIM(color), 
	 interior = TRIM(interior), 
	 seller = TRIM(seller), 
	 mmr = TRIM(mmr), 
	 sellingprice = TRIM(sellingprice), 
	 saledate = TRIM(saledate);

START TRANSACTION;
	UPDATE carPricesStaging
		SET make = TRIM(CONCAT(UPPER(SUBSTRING(make, 1, 1)), LOWER(SUBSTRING(make, 2)))),
			body = TRIM(CONCAT(UPPER(SUBSTRING(body, 1, 1)), LOWER(SUBSTRING(body, 2)))),
			color = TRIM(CONCAT(UPPER(SUBSTRING(color, 1, 1)), LOWER(SUBSTRING(color, 2)))),
			interior = TRIM(CONCAT(UPPER(SUBSTRING(interior, 1, 1)), LOWER(SUBSTRING(interior, 2)))),
			transmission = TRIM(CONCAT(UPPER(SUBSTRING(transmission, 1, 1)), LOWER(SUBSTRING(transmission, 2))));
COMMIT;

START Transaction;
	UPDATE carPricesStaging
		SET trim = "LX"
		WHERE make = "Kia" and trim ="!";
COMMIT;
 
START TRANSACTION;
	UPDATE carPricesStaging
		SET color = null, `condition` = NULL, interior = NULL, transmission = NULL
		WHERE color LIKE '%—%' OR color LIKE '%-%' OR 
        `condition` LIKE '%—%' OR `condition` LIKE '%-%' 
        OR interior LIKE '%—%' OR interior LIKE '%-%'  
        OR transmission LIKE '%—%' OR transmission LIKE '%-%';
COMMIT;

-- creating a new column for date only
ALTER TABLE carPricesStaging
ADD COLUMN `date` date;

# Removing blank and format such as "7500" etc
DELETE FROM carPricesStaging 
WHERE saledate NOT REGEXP '[0-9]{1,2} [0-9]{4}.*$';

START TRANSACTION;
   UPDATE carPricesStaging  
		SET `date` = STR_TO_DATE(SUBSTRING_INDEX(SUBSTRING_INDEX(saledate, ' ', 4), ' ', -3), '%b %d %Y')
	WHERE saledate IS NOT NULL AND saledate != '';
COMMIT;

# Checking for Null /blank values

/*
	This SQL code dynamically counts NULL values for all columns in the carPricesStaging table. 
	First, it increases the group_concat_max_len limit to handle long query strings. 
	Then, it constructs an SQL query using GROUP_CONCAT() to generate COUNT(*) - COUNT(column_name) for each column, 
	retrieving column names from INFORMATION_SCHEMA.COLUMNS. 
	The query is stored in a variable (@sql), executed using PREPARE and EXECUTE, and finally cleaned up with DEALLOCATE PREPARE. 
*/
SET SESSION group_concat_max_len = 1000000;
SET @sql = NULL;
SELECT GROUP_CONCAT(
    CONCAT('COUNT(*) - COUNT(`', COLUMN_NAME, '`) AS `', COLUMN_NAME, '_Null_Count`')
    SEPARATOR ', ')
INTO @sql
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'carPricesStaging' AND TABLE_SCHEMA = DATABASE();

SET @sql = CONCAT('SELECT ', @sql, ' FROM carPricesStaging;');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


# taking out the vin code where there are missing value in other columns
CREATE TABLE `forVin` (
  `year` int COLLATE utf8mb4_unicode_ci,
  `vin` text COLLATE utf8mb4_unicode_ci,
  `color` text COLLATE utf8mb4_unicode_ci,
  `interior` text COLLATE utf8mb4_unicode_ci,
  `model` text COLLATE utf8mb4_unicode_ci,
  `transmission` text COLLATE utf8mb4_unicode_ci,
  `make` text COLLATE utf8mb4_unicode_ci,
  `body` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
 
INSERT INTO forvin 
	SELECT `year`, vin, `color` ,`interior`, `model`, `transmission`, `make`, `body`
		FROM carPricesStaging
	WHERE body IS NULL OR color IS NULL OR
	interior IS NULL OR make IS NULL OR model IS NULL OR transmission IS NULL;
        
SELECT *
FROM updateddata;
    
SELECT COUNT(*) FROM updateddata;

CREATE TABLE `carColor` (
  `vin` text NULL,
  `color` text NULL,
  `interior` text NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE carColor ADD CONSTRAINT unique_vin UNIQUE (vin);

CREATE TABLE `carInfo` (
  `year` int DEFAULT NULL,
  `make` text NULL,
  `model` text NULL,
  `body` text NULL,
  `transmission` text NULL,
  `vin` text NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE carInfo ADD CONSTRAINT unique_vin UNIQUE (vin);

SELECT COUNT(*) FROM carinfo;
SELECT COUNT(*) FROM carcolor;

WITH duplicateCte AS
 (
	SELECT *,
	ROW_NUMBER() OVER( PARTITION BY 
	`year`, make, model, body, transmission, vin) AS `duplicate`
	FROM carinfo
 )	SELECT * FROM duplicateCte
 WHERE `duplicate` > 1;
 
 WITH duplicateCte AS
 (
	SELECT *,
	ROW_NUMBER() OVER( PARTITION BY 
	vin, color, interior) AS `duplicate`
	FROM carcolor
 )	SELECT * FROM duplicateCte
 WHERE `duplicate` > 1;


