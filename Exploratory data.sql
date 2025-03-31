-- exploratory data analysis

select *
from layoffs_staging2;


select max(total_laid_off), max(percentage_laid_off) 		 -- maximun total laid off and percentage
from layoffs_staging2;

select *
from layoffs_staging2
where percentage_laid_off = 1;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select max(`date`), min(`date`)
from layoffs_staging2;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 1 desc;

-- finfing the total laid off per month

select substring(`date`, 1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `month`
order by 1;

with rolling_total_cte as 
(
select substring(`date`, 1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `month`
order by 1
)
select `month`, total_off, 
sum(total_off) over(order by `month` ) as total
from rolling_total_cte;


-- total laid off per company

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

-- ranking to fing rhe year they laid off most people
 
 with company_year (company, years, total_laid_off)as 
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), 
company_year_rank as 
(
 select * ,
 dense_rank() over(partition by years order by total_laid_off desc) as ranking
 from company_year
 where years is not null
 order by ranking
 )
 select *
 from company_year_rank
 where ranking <= 5  ;









