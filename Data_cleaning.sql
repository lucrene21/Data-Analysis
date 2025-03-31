-- PROJECR 1
-- DATA CLEANING

drop database world_layouts;

select *
from layoffs;

-- 1. remove duplicates if there are any
-- 2. standardize the data (spelling errors and more)
-- 3. null values and blank values
-- 4. remove columns

-- creating a new table with the same columns as in layoffs

create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

-- inserting all the data from layoffs into layoffs_staging

insert layoffs_staging
select *
from layoffs;

-- 1. removing duplicates if there are any
-- The table has duplicates but no unique identifier (id column), i will use ROW_NUMBER() to keep only one instance:

 select *, 
 row_number() over (
 partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- filtering where the row_num is greater than 2

with duplicate_cte as(
select *, 
 row_number() over (
 partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

-- verifying that they are really duplicates

select*
from layoffs_staging
where company = 'cazoo';

-- deleting the duplicate by creating another table with the column row_num and deleting when row_numb = 2

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select*
from layoffs_staging2
where row_num > 1;

insert into layoffs_staging2
select *, 
 row_number() over (
 partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete
from layoffs_staging2
where row_num > 1;

SET SQL_SAFE_UPDATES = 0; -- disenable the safe mode
SET SQL_SAFE_UPDATES = 1; -- enable the safe mode

select*
from layoffs_staging2;


-- standerdising data / finding issues and fixing

-- removing unwanted spaces or specific characters from the beginning and/or end of a string using TRIM() function removes.

select trim(company), company
from layoffs_staging2;

 update layoffs_staging2
 set company = trim(company);
 
 -- sorting the column industry
 
 select distinct industry
 from layoffs_staging2;
 
 select *
 from layoffs_staging2
 where industry like 'crypto%';
 
 update layoffs_staging2
 set industry = 'Crypto'
 where industry like 'crypto%';
 
 
  -- inspecting the column location
  
 select distinct location
 from layoffs_staging2
 order by 1;
 
   -- inspecting the column country
   
 select distinct country
 from layoffs_staging2
 order by 1;
 
 -- removing the dot at the end of united states
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;
 
 -- updating the table to remove the dot from united states
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

  
-- inspecting the column date and changing the format

select `date`
from layoffs_staging2;

-- putting the dates in the correct format and updating the table
select `date`,
str_to_date ( `date`, '%m/%d/%Y') -- putting the dates in the correct format
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date ( `date`, '%m/%d/%Y');

-- changing the datatype of the column date

alter table layoffs_staging2
modify column `date` date;


-- 3. null values and blank values
-- null values and blank values in the column total_laid_off

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null	;

-- setting all the blank rows to null
update layoffs_staging2
set industry = null
where industry = '';

select industry
from layoffs_staging2
where industry = null;

select distinct *
from layoffs_staging2
where company = 'Airbnb';

select t1.industry, t1.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
and t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null)
and t2.industry is not null ;


-- removing columns and rows where total_laid_off is null and percentage_laid_off is null

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null	;

delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null	;

-- deleting the column row_num

select *
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;







