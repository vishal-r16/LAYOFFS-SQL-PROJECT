-- DATA CLEANING
SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATA
-- 3. NULL VALUES or BLANK VALUES
-- 4. REMOVE ANY COLUMNS

-- CREATING STAGING DATA BASE FOR EDITING
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT*
FROM layoffs_staging;

INSERT layoffs_staging
SELECT* FROM
layoffs;


-- 1. REMOVING DUPLICATES

-- creating row no for group function to find any duplicate 
SELECT*,
ROW_NUMBER()
 OVER(PARTITION BY company, location, industry, total_laid_off,
 percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

-- CREATING CTE for using it again
WITH duplicate_cte AS
(SELECT*,
ROW_NUMBER()
 OVER(PARTITION BY company, location, industry, total_laid_off,
 percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num>1;
-- WE FOUND THE DUPLICATES ROWS HERE 



-- NOW DELETING THE DUPLICATE
 CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- CREATING A NEW TABLE TO KEEP OLD ONE SAFE
INSERT INTO layoffs_staging3
SELECT*,
ROW_NUMBER()
 OVER(PARTITION BY company, location, industry, total_laid_off,
 percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

-- USING SELECT STATEMENTS TO VIEW BEFORE DELETING
SELECT* FROM layoffs_staging3
WHERE row_num>1;

-- DELETING THE DUPLICATES
DELETE
FROM layoffs_staging3
WHERE row_num>1;

SELECT* FROM layoffs_staging3;


-- 2. STANDARDIZE THE DATA

-- TRIM FUNCTION REMOVES SPACES BETWEEN STRINGS

SELECT company, TRIM(company)
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET company=TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging3
ORDER BY 1;
-- THIS HELPS IN CHECKING SIMILAR industry
-- FOUND CRYPTO SIMILAR TO SOME EXTENT

SELECT *
FROM layoffs_staging3
WHERE industry REGEXP 'Crypto';

UPDATE layoffs_staging3
SET industry= 'Crypto'
WHERE industry LIKE 'Crypto%';
-- UPDATED THE LIST FOR BETTER EXPERIENCE 

-- NOW MOVING TOWARDS LOCATION
-- NOTHING FOUND SUSPICIOUS 

-- NOW MOVING TOWARDS COUNTRY
SELECT DISTINCT country
FROM layoffs_staging3
ORDER BY 1;

-- UNITED STATES LIKE PRESENT 
SELECT DISTINCT country, trim(TRAILING '.' FROM country)
FROM layoffs_staging3
ORDER BY 1;

UPDATE layoffs_staging3
SET country=trim(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
-- UPDATED THE COUNTRY

-- DATE IS TEXT FORMAT THAT SHOULD BE IN DATE FORMAT

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging3
MODIFY column `date` DATE;
-- UPDATED AND ALTERED DATE 

-- 3. NULL VALUES or BLANK VALUES

SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

update layoffs_staging3
SET industry = null
WHERE industry = '';

SELECT *
FROM layoffs_staging3
WHERE industry IS NULL OR industry = '';
-- WE ARE TRYING TO POPULATE THIS WITH DATA IF AVAILABLE 

SELECT*
FROM layoffs_staging3
WHERE company='Airbnb';

-- FROM HERE WE SEE AIRBNB HAS ITS INDUSTRY IN ONE

SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
	 ON t1.company=t2.company
     AND t1.location=t2.location
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company=t2.company
     AND t1.location=t2.location
     SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

-- HERE ONLY BAILEY LEFY BECAUSE NO DATA 
-- DELETING DATA WHERE TOTAL AND PERCENTAGE LAID OFF IS NULL AS ITS NO USE OF THE PROJECT 

SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging3
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- 4. REMOVE ANY COLUMNS
-- DELETING ROW NUMBER COLUMN AS IT IS OF NO USE TO US 

ALTER TABLE layoffs_staging3
DROP COLUMN row_num;

SELECT* FROM layoffs_staging3;

-- FINAL DATA FOR FURTHER PROCESSING AFTER CLEANING