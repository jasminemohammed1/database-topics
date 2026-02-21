--1
select top 15 
DisplayName,
Reputation,
Location
from Users
order by Reputation desc

--2
select top 10 with ties
Score,
ViewCount,
Title
from Posts
order by Score desc;

--3
select DisplayName,Reputation
from Users
order by Reputation desc
offset 20 rows
fetch next 10 rows only

--4
select
ROW_NUMBER() over (order by score desc) as [row number],
Title,score
from Posts
where Title is not null

--5
-- if two users haves same reputation they will take the same rank 
-- and the reputation between them will count the 2 as 2 or it include gaps
select 
RANK() over (order by Reputation desc ) as rank,
DisplayName,Reputation
from 
Users

--6
--if two posts has the same score they will take the same rank but it doesnot skip gaps
select 
DENSE_RANK() over(order by score) as [Dense rank],
Score,
Title
from 
Posts

--7
select 
NTILE(5) over(order by Reputation desc) as [quintile number],
DisplayName,
Reputation
from 
Users

--8
select 
PostTypeId,
ROW_NUMBER() over (partition by PostTypeId order by Score desc) as [rank within type],
Title,
Score
from 
Posts
