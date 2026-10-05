# Layoffs Exploratory Data Analysis (MySQL)

SQL scripts that explore and analyze the cleaned global tech layoffs dataset.

## Overview

This project runs exploratory data analysis on the cleaned layoffs data produced by the [layoffs-data-cleaning-mysql] (https://github.com/BenitShrestha/layoffs-data-cleaning-mysql) project. It surfaces trends and patterns in layoffs across companies, industries, countries, funding, and time; starting from simple summary queries and building up to window-function and recursive-CTE analysis.

Two scripts are included:
- **`main-EDA.sql`** — Initial, straightforward exploration (totals, breakdowns, a basic rolling total, a top-companies-per-year ranking)
- **`main-EDAv2.sql`** — An expanded follow-up that goes deeper into data quality and more advanced SQL techniques

## Features

- Summary statistics on layoff totals and percentages
- Breakdowns by company, industry, country, and funding stage
- Time-based trends, including monthly and yearly patterns
- Rolling totals and month-over-month percent change
- Ranking of top companies by layoffs per year (`RANK`, `DENSE_RANK`, `ROW_NUMBER`)
- Data-quality checks: null rates across all columns, inconsistent null patterns
- Bucketing companies into layoff-size tiers, with multiple equivalent query approaches compared
- Correlated subquery vs. window function for finding above-average rows
- Year-over-year industry comparisons (e.g. industries present in 2022 but not 2023)
- Funding amount vs. layoff severity
- Company "lifecycle" duration (days between first and last layoff event)
- Partitioned moving averages, including a recursive-CTE version that fills in months with no layoffs
- Quartile analysis with `NTILE`
- Cumulative count of distinct industries affected over time, via correlated subquery

## Tech stack

- **MySQL 8.0+** (uses window functions, CTEs, and recursive CTEs)

## Installation

### 1. Clone the repo

```
git clone https://github.com/BenitShrestha/layoffs-eda-mysql.git
cd layoffs-eda-mysql
```

### 2. Make sure the cleaned dataset is available in your MySQL database

(See [layoffs-data-cleaning-mysql] (https://github.com/BenitShrestha/layoffs-data-cleaning-mysql) to generate it)

### 3. Run the analysis scripts

```
mysql -u <user> -p <database_name> < main-EDA.sql
mysql -u <user> -p <database_name> < main-EDAv2.sql
```

Both scripts expect a `layoffs_cleaned` table in the target database. `main-EDAv2.sql` can be run independently of `main-EDA.sql` — it doesn't depend on any objects created by the first script.