-- EXPLORATORY DATA ANALYSIS

SELECT * 
FROM layoffs_staging3;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging3;

-- WHICH COMPANY HAVE RAISED MOST FUNDS AND LAID OFF 100%
SELECT * 
FROM layoffs_staging3
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

-- COMPANY ORDER BY LAY OFFS 
SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

-- DATA DATE RANGE
SELECT MIN(`date`), max(`date`)
FROM layoffs_staging3;

-- INDUSTRY ORDER BY LAYOFSS NUMBER
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY industry
ORDER BY 2 DESC;

-- COUNTRY WITH MAXIMUM TO MINIMUM LAYOFFS
SELECT country, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY country
ORDER BY 2 DESC;

-- LAY OFFS PER YEAR 
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- LAYOFFS BY STAGE
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY stage
ORDER BY 2 DESC;

-- SUM LAYOFFS BY MONTH
SELECT substring(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging3
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

-- ROLLING SUM ON MONTH 
WITH Rolling_total AS
(
SELECT substring(`date`,1,7) AS `MONTH`, SUM(total_laid_off) as total_off
FROM layoffs_staging3
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) as rolling
FROM Rolling_total;

-- COMPANY LAYOFFS PER YEAR 
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY  company, YEAR(`date`)
ORDER BY 3 DESC;


-- RANKING COMPANY WITH MAX LAYOFFS YEAR
WITH company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY  company, YEAR(`date`)
ORDER BY 3 DESC
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as Ranking
FROM company_Year
WHERE years IS NOT NULL
ORDER BY Ranking)
SELECT * FROM Company_Year_Rank WHERE Ranking <= 5;

-- SIMILARLY CAN DONE FOR INDUSTRY YEAR OR MONTH ETC.


