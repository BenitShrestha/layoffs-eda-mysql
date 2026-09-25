-- Exploratory Data Analysis
SELECT *
FROM layoffs_cleaned;

-- Focusing on `total_laid_off` and `percentage_laid_off`
SELECT
	MAX(total_laid_off) max_total,
    MAX(percentage_laid_off) max_percentage
FROM layoffs_cleaned;

SELECT * -- Data with fully laid off values
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT * -- Explore by funding
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off) -- View company's total laid off 
FROM layoffs_cleaned
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off) -- View industry's total laid off 
FROM layoffs_cleaned
GROUP BY industry
ORDER BY 2 DESC;

SELECT 
	country, 
    SUM(total_laid_off) -- View country's total laid off 
FROM layoffs_cleaned
GROUP BY country
ORDER BY 2 DESC;

SELECT 
	MIN(`date`), 
    MAX(`date`)
FROM layoffs_cleaned;

SELECT DISTINCT
    YEAR(`date`),
    SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT
    stage,
    SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY stage
ORDER BY 2 DESC;

-- View laid off data from earliest
SELECT
    SUBSTRING(`date`, 1, 7) AS month_,
    SUM(total_laid_off)
FROM layoffs_cleaned
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY month_
ORDER BY 1 ASC;

-- View as rolling total
WITH Rolling_Total AS (
    SELECT
        SUBSTRING(`date`, 1, 7) AS month_,
        SUM(total_laid_off) AS total_off
    FROM layoffs_cleaned
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY month_
    ORDER BY 1 ASC
)
SELECT
    month_,
    total_off,
    SUM(total_off) OVER (ORDER BY month_) AS rolling_total
FROM Rolling_Total;

-- View by company and year
SELECT
    company,
    YEAR(`date`),
    SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY
    company,
    YEAR(`date`)
ORDER BY 3 DESC;

-- CTE to view ranking of top companies laying off for all years
WITH Company_Year (company, years, total_laid) AS (
    SELECT
        company,
        YEAR(`date`),
        SUM(total_laid_off)
    FROM layoffs_cleaned
    GROUP BY
        company,
        YEAR(`date`)
    ORDER BY 3 DESC
),
Company_Year_Rank AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY years
            ORDER BY total_laid DESC
        ) AS ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5;