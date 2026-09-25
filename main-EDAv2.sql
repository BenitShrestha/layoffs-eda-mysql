-- OBJECTIVE #1: NULL RATE ACROSS ALL COLUMNS
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

-- OBJECTIVE #2: BUCKET COMPANIES INTO LAYOFF-TIERS
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

-- OBJECTIVE #3: RANK COMPANIES BY TOTAL LAID OFF (RANK, DENSE RANK, ROW NUMBER)
WITH Company_Totals (company, yr, total_laid_off) AS
(
	SELECT 
		company,
        YEAR(`date`),
        SUM(total_laid_off)
	FROM layoffs_cleaned
    GROUP BY 
		company, 
        YEAR(`date`)
),
Company_Rank AS
(
	SELECT 
		*,
		RANK() OVER(
			PARTITION BY yr 
			ORDER BY total_laid_off DESC
		) AS ranking,
		DENSE_RANK() OVER(
			PARTITION BY yr 
			ORDER BY total_laid_off DESC
		) AS dense_ranking,
		ROW_NUMBER() OVER(
			PARTITION BY yr 
			ORDER BY total_laid_off DESC
		) AS row_numbers
	FROM Company_Totals
)
SELECT *
FROM Company_Rank;

-- OBJECTIVE #4: REFINED ROLLING TOTAL
-- Volume excluded by removing NULLs
SELECT
    SUM(total_laid_off) AS null_total
FROM layoffs_cleaned
WHERE `date` IS NULL;

-- NULL ratio
SELECT
    SUM(total_laid_off) AS null_total
FROM layoffs_cleaned
WHERE `date` IS NULL;
WITH Date_Null (date_nulls, date_totals, not_null_dates) AS
(
	SELECT 
		SUM(CASE
				WHEN `date` IS NULL THEN 1 ELSE 0 
			END
		),
        COUNT(*),
        COUNT(`date`)
	FROM layoffs_cleaned
)
SELECT (date_nulls / date_totals) AS null_ratio
FROM Date_Null;

-- Using frame clause
WITH monthly_totals AS (
    SELECT
        SUBSTRING(`date`, 1, 7) AS month_,
        SUM(total_laid_off) AS total_off
    FROM layoffs_cleaned
    WHERE `date` IS NOT NULL
    GROUP BY month_
)
SELECT
    month_,
    total_off,
    SUM(total_off) OVER (
        ORDER BY month_
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rolling_total
FROM monthly_totals
ORDER BY month_;

-- OBJECTIVE #5: MONTH OVER MONTH % CHANGE
WITH monthly_totals AS (
    SELECT
        SUBSTRING(`date`, 1, 7) AS month_,
        SUM(total_laid_off) AS total_off
    FROM layoffs_cleaned
    WHERE `date` IS NOT NULL
    GROUP BY month_
),
prev_monthly AS (
    SELECT
        *,
        LAG(total_off) OVER (
            ORDER BY month_
        ) AS prev_total_off
    FROM monthly_totals
)
SELECT
    *,
    CASE
        WHEN prev_total_off IS NOT NULL
             AND prev_total_off != 0
        THEN round(((total_off - prev_total_off) / prev_total_off) * 100, 2)
    END AS `percent_change(%)`
FROM prev_monthly;





