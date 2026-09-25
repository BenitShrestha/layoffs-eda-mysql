# Layoffs Exploratory Data Analysis (MySQL)

SQL script that explores and analyzes the cleaned global tech layoffs dataset.

# Overview

This project runs exploratory data analysis on the cleaned layoffs data produced by the [layoffs-data-cleaning-mysql](https://github.com/BenitShrestha/layoffs-data-cleaning-mysql) project. It surfaces trends and patterns in layoffs across companies, industries, countries, and time.

# Features

- Summary statistics on layoff totals and percentages
- Breakdowns by company, industry, country, and funding stage
- Time-based trends, including monthly and yearly patterns
- Rolling totals over time
- Ranking of top companies by layoffs per year

# Tech stack

- **MySQL 8.0+** (uses window functions and CTEs)

# Installation

## 1. Clone the repo

git clone [https://github.com/BenitShrestha/layoffs-eda-mysql.git](https://github.com/BenitShrestha/layoffs-eda-mysql.git) 

cd layoffs-eda-mysql

## 2. Make sure the cleaned dataset is available in your MySQL database

(See layoffs-data-cleaning-mysql to generate it)

## 3. Run the analysis script

mysql -u -p \<database_name> \< main-EDA.sql