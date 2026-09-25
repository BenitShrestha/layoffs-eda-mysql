-- OBJECTIVE #1: Calculate NULL rate across all columns
	-- COUNT(*) means Total no. of rows
	-- COUNT(column) means Total no. of non-null rows

-- Count and Rate
WITH null_count AS
(
    SELECT 
        COUNT(*) AS total_rows,
        COUNT(*) - COUNT(company) AS company_null,
        COUNT(*) - COUNT(location) AS location_null,
        COUNT(*) - COUNT(industry) AS industry_null,
        COUNT(*) - COUNT(total_laid_off) AS total_laid_off_null,
        COUNT(*) - COUNT(percentage_laid_off) AS percentage_laid_off_null,
        COUNT(*) - COUNT(`date`) AS date_null,
        COUNT(*) - COUNT(stage) AS stage_null,
        COUNT(*) - COUNT(country) AS country_null,
        COUNT(*) - COUNT(funds_raised_millions) AS funds_raised_millions_null
    FROM layoffs_cleaned
)

-- Null Rate
SELECT
	total_rows,
    company_null / total_rows * 100 AS company_null_rate,
    location_null / total_rows * 100 AS location_null_rate,
    industry_null / total_rows * 100 AS industry_null_rate,
    total_laid_off_null / total_rows * 100 AS total_laid_off_null_rate,
    percentage_laid_off_null / total_rows * 100 AS percentage_laid_off_null_rate,
    date_null / total_rows * 100 AS date_null_rate,
    stage_null / total_rows * 100 AS stage_null_rate,
    country_null / total_rows * 100 AS country_null_rate,
    funds_raised_millions_null / total_rows * 100 AS funds_raised_millions_null_rate
FROM null_count;

-- Checking total_laid_off NULL percentage_laid_off NOT NULL and vice versa
SELECT
    SUM(CASE WHEN total_laid_off IS NULL AND percentage_laid_off IS NOT NULL THEN 1 ELSE 0 END) AS total_null_percent_not,
    SUM(CASE WHEN total_laid_off IS NOT NULL AND percentage_laid_off IS NULL THEN 1 ELSE 0 END) AS total_not_percent_null
FROM layoffs_cleaned;

-- OBJECTIVE #2: Bucket companies into layoff-severity tiers
WITH Distinct_Company AS (
    SELECT
        company,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_cleaned
    GROUP BY company
),
Layoff_Tiers AS (
    SELECT
        SUM(CASE
				WHEN total_laid_off BETWEEN 0 AND 1999 THEN 1
				ELSE 0
			END) AS `(0-2000)`,

        SUM(CASE
				WHEN total_laid_off BETWEEN 2000 AND 3999 THEN 1
				ELSE 0
			END) AS `(2000-4000)`,

        SUM(CASE
				WHEN total_laid_off BETWEEN 4000 AND 5999 THEN 1
				ELSE 0
			END) AS `(4000-6000)`,

        SUM(CASE
				WHEN total_laid_off BETWEEN 6000 AND 7999 THEN 1
				ELSE 0
			END) AS `(6000-8000)`,

        SUM(CASE
				WHEN total_laid_off BETWEEN 8000 AND 9999 THEN 1
				ELSE 0
			END) AS `(8000-10000)`,

        SUM(CASE
				WHEN total_laid_off >= 10000 THEN 1
				ELSE 0
			END) AS `(>10000)`
    FROM Distinct_Company
)
SELECT *
FROM Layoff_Tiers;

-- No. total laid off per tier
WITH Distinct_Company AS (
    SELECT
        company,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_cleaned
    GROUP BY company
)
SELECT
        SUM(CASE
				WHEN total_laid_off BETWEEN 0 AND 1999 THEN total_laid_off
				ELSE 0
			END) AS `(0-2000)_total`,

        SUM(CASE
				WHEN total_laid_off BETWEEN 2000 AND 3999 THEN total_laid_off
				ELSE 0
			END) AS `(2000-4000)_total`,

        SUM(CASE
				WHEN total_laid_off BETWEEN 4000 AND 5999 THEN total_laid_off
				ELSE 0
			END) AS `(4000-6000)_total`,

        SUM(CASE
				WHEN total_laid_off BETWEEN 6000 AND 7999 THEN total_laid_off
				ELSE 0
			END) AS `(6000-8000)_total`,

        SUM(CASE
				WHEN total_laid_off BETWEEN 8000 AND 9999 THEN total_laid_off
				ELSE 0
			END) AS `(8000-10000)_total`,

        SUM(CASE
				WHEN total_laid_off >= 10000 THEN total_laid_off
				ELSE 0
			END) AS `(>10000)_total`
FROM Distinct_Company;

-- Combined: Tall Approach
WITH Distinct_Company AS (
    SELECT
        company,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_cleaned
    GROUP BY company
)
SELECT
	CASE
        WHEN total_laid_off BETWEEN 0 AND 1999 THEN '0-2000'
        WHEN total_laid_off BETWEEN 2000 AND 3999 THEN '2000-4000'
        WHEN total_laid_off BETWEEN 4000 AND 5999 THEN '4000-6000'
        WHEN total_laid_off BETWEEN 6000 AND 7999 THEN '6000-8000'
        WHEN total_laid_off BETWEEN 8000 AND 9999 THEN '8000-10000'
        WHEN total_laid_off >= 10000 THEN '>10000'
    END AS layoff_tier,
    COUNT(*) AS num_companies,
    SUM(total_laid_off) as total_laid_off
FROM Distinct_Company
GROUP BY layoff_tier
ORDER BY MIN(total_laid_off);

-- Manual tiers approach
SELECT
    layoff_tier,
    num_companies,
    total_laid_off
FROM (
    WITH Company_Totals AS (
        SELECT
            company,
            SUM(total_laid_off) AS total_laid_off
        FROM layoffs_cleaned
        GROUP BY company
    )
    SELECT
        CASE
            WHEN total_laid_off BETWEEN 0 AND 1999 THEN '0-2000'
            WHEN total_laid_off BETWEEN 2000 AND 3999 THEN '2000-4000'
            WHEN total_laid_off BETWEEN 4000 AND 5999 THEN '4000-6000'
            WHEN total_laid_off BETWEEN 6000 AND 7999 THEN '6000-8000'
            WHEN total_laid_off BETWEEN 8000 AND 9999 THEN '8000-10000'
            WHEN total_laid_off >= 10000 THEN '>10000'
        END AS layoff_tier,
        COUNT(*) AS num_companies,
        SUM(total_laid_off) AS total_laid_off,
        CASE
            WHEN total_laid_off BETWEEN 0 AND 1999 THEN 1
            WHEN total_laid_off BETWEEN 2000 AND 3999 THEN 2
            WHEN total_laid_off BETWEEN 4000 AND 5999 THEN 3
            WHEN total_laid_off BETWEEN 6000 AND 7999 THEN 4
            WHEN total_laid_off BETWEEN 8000 AND 9999 THEN 5
            WHEN total_laid_off >= 10000 THEN 6
        END AS tier_sort
    FROM Company_Totals
    GROUP BY layoff_tier, tier_sort
) AS Tiered
ORDER BY tier_sort;