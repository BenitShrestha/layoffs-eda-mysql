-- OBJECTIVE #1: Null rate across all columns
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


-- OBJECTIVE #2: Bucket companies into layoff-tiers
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


-- OBJECTIVE #3: Rank companies by total laid off (rank, dense rank, row number)
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


-- OBJECTIVE #4: Refined Rolling Total
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


-- OBJECTIVE #5: Month over month % change
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


-- OBJECTIVE #6: Correlated Subquery

-- Row average above company's own average

-- Using correlated subquery
SELECT
    a.*,
    (
        SELECT AVG(b.total_laid_off)
        FROM layoffs_cleaned AS b
        WHERE b.company = a.company
    ) AS company_average
FROM layoffs_cleaned AS a
WHERE a.total_laid_off > (
    SELECT AVG(b.total_laid_off)
    FROM layoffs_cleaned AS b
    WHERE b.company = a.company
);

--  Using a window function
WITH Company_Average AS (
    SELECT
        *,
        AVG(total_laid_off) OVER (PARTITION BY company) AS company_avg
    FROM layoffs_cleaned
)
SELECT *
FROM Company_Average
WHERE total_laid_off > company_avg;


-- OBJECTIVE #7: Industry Comparison (2022 v. 2023)
WITH industry_22_23 AS (
    SELECT
        industry,
		SUM(CASE WHEN YEAR(`date`) = 2022 THEN total_laid_off END) AS sum_in_22,        
		SUM(CASE WHEN YEAR(`date`) = 2023 THEN total_laid_off END) AS sum_in_23,        
        COUNT(CASE WHEN YEAR(`date`) = 2022 THEN 1 END) AS count_in_22, 
        COUNT(CASE WHEN YEAR(`date`) = 2023 THEN 1 END) AS count_in_23  
    FROM layoffs_cleaned
    GROUP BY industry
)
SELECT
    industry,
    CASE
        WHEN (count_in_22 > 0 AND count_in_23 = 0) THEN 'Yes' 
        ELSE 'No'
    END AS in22_not23
FROM industry_22_23
ORDER BY in22_not23;

-- Alternative way: Using JOIN
SELECT *
FROM (
    SELECT DISTINCT industry
    FROM layoffs_cleaned
    WHERE YEAR(`date`) = 2022
) AS a
LEFT JOIN (
    SELECT DISTINCT industry
    FROM layoffs_cleaned
    WHERE YEAR(`date`) = 2023
) AS b
    ON a.industry = b.industry
WHERE b.industry IS NULL;


-- OBJECTIVE #8: Funding vs layoff severity
SELECT
    CASE
        WHEN funds_raised_millions BETWEEN 0 AND 39999
            THEN '0-40000'
        WHEN funds_raised_millions BETWEEN 40000 AND 79999
            THEN '40000-80000'
        WHEN funds_raised_millions BETWEEN 80000 AND 119999
            THEN '80000-120000'
        WHEN funds_raised_millions >= 120000
            THEN '120000+'
        WHEN funds_raised_millions IS NULL
            THEN 'null_values'
    END AS funds_bucket,
    AVG(percentage_laid_off) AS avg_percent_laid_off
FROM layoffs_cleaned
GROUP BY funds_bucket
ORDER BY MIN(funds_raised_millions);


-- OBJECTIVE #9: Company lifecycle CTE chain
WITH Layoff_Dates (company, first_date, last_date) AS (
    SELECT
        company,
        MIN(`date`),
        MAX(`date`)
    FROM layoffs_cleaned
    GROUP BY company
),
Total_Laid_Window AS (
    SELECT
        ld.*,
        SUM(lc.total_laid_off) AS sum_total_laid_off
    FROM Layoff_Dates AS ld
    JOIN layoffs_cleaned AS lc
        ON ld.company = lc.company
    GROUP BY ld.company
)
SELECT
    *,
    DATEDIFF(last_date, first_date) AS days_between
FROM Total_Laid_Window
ORDER BY days_between;


-- OBJECTIVE #10: Partitioned moving average
WITH Monthly_Layoff AS (
    SELECT
        industry,
        SUBSTRING(`date`, 1, 7) AS month_,
        SUM(total_laid_off) AS sum_total
    FROM layoffs_cleaned
    WHERE total_laid_off IS NOT NULL
    GROUP BY industry, month_
    ORDER BY industry, month_
)
SELECT
    industry,
    month_,
    ROUND(
        AVG(sum_total) OVER (
            PARTITION BY industry
            ORDER BY month_
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        1
    ) AS trimonthly_average
FROM Monthly_Layoff;

-- Alternative: Populating missing months
WITH RECURSIVE month_spine AS (
    SELECT
        DATE_FORMAT(MIN(`date`), '%Y-%m-01') AS month_
    FROM layoffs_cleaned

    UNION ALL

    SELECT
        DATE_ADD(month_, INTERVAL 1 MONTH)
    FROM month_spine
    WHERE month_ < (
        SELECT DATE_FORMAT(MAX(`date`), '%Y-%m-01')
        FROM layoffs_cleaned
    )
),
Industry_List AS (
    SELECT DISTINCT
        industry
    FROM layoffs_cleaned
    WHERE industry IS NOT NULL
),
Industry_Month_Grid AS (
    SELECT
        i.industry,
        m.month_
    FROM Industry_List AS i
    CROSS JOIN month_spine AS m
),
Real_Data AS (
    SELECT
        industry,
        DATE_FORMAT(`date`, '%Y-%m-01') AS month_,
        SUM(total_laid_off) AS total_off
    FROM layoffs_cleaned
    WHERE industry IS NOT NULL
    GROUP BY
        industry,
        DATE_FORMAT(`date`, '%Y-%m-01')
),
Gap_Filled AS (
    SELECT
        g.industry,
        g.month_,
        COALESCE(r.total_off, 0) AS total_off
    FROM Industry_Month_Grid AS g
    LEFT JOIN Real_Data AS r
        ON g.industry = r.industry
        AND g.month_ = r.month_
)
SELECT
    industry,
    DATE_FORMAT(month_, '%Y-%m') AS `year-month`,
    ROUND(
        AVG(total_off) OVER (
            PARTITION BY industry
            ORDER BY month_
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        1
    ) AS trimonthly_average
FROM Gap_Filled;


-- OBJECTIVE #11: Percentile/NTILE
WITH Company_Totals AS (
    SELECT
        company,
        SUM(total_laid_off) AS sum_laid_off,
        funds_raised_millions
    FROM layoffs_cleaned
    GROUP BY
        company,
        funds_raised_millions
),
Company_Quartile AS (
    SELECT
        company,
        sum_laid_off,
        funds_raised_millions,
        NTILE(4) OVER (
            ORDER BY sum_laid_off
        ) AS laid_off_quartile
    FROM Company_Totals
)
SELECT
    ROUND(AVG(funds_raised_millions), 1) AS avg_funds_raised_millions,
    laid_off_quartile
FROM Company_Quartile
GROUP BY laid_off_quartile
ORDER BY laid_off_quartile;

-- Better view
	-- MIN(sum_laid_off) AS min_layoffs, MAX(sum_laid_off) AS max_layoffs, 


-- OBJECTIVE #12: Cumulative distinct industries
WITH month_industry AS (
    SELECT DISTINCT
        DATE_FORMAT(`date`, '%Y-%m') AS month_,
        industry
    FROM layoffs_cleaned
    WHERE total_laid_off > 0
    ORDER BY month_
),
months AS (
    SELECT DISTINCT
        month_
    FROM month_industry
)
SELECT
    m.month_,
    (
        SELECT COUNT(DISTINCT industry)
        FROM month_industry AS inner_
        WHERE inner_.month_ <= m.month_
    ) AS distinct_industries_so_far
FROM months AS m
ORDER BY m.month_;
