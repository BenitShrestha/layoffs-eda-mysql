-- Exploratory Data Analysis
SELECT *
FROM layoffs_cleaned;

-- Focusing on `total_laid_off` and `percentage_laid_off`
SELECT
	MAX(total_laid_off) max_total,
    MAX(percentage_laid_off) max_percentage
FROM layoffs_cleaned;

SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
