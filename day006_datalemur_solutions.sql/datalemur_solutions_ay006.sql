-- Duplicate Job Listings
with new_tab as (select company_id , title, description , count(job_id) as job_count -- count of job ids by company, title and description
from job_listings
group by company_id, title , description)

select count(title) from new_tab
where job_count>1;