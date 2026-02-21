--1
-- create nonclustered composite
--1)create index structure
create nonclustered index specific_user_score_threshold
on Posts(OwnerUserId,Score desc)
include(Title,ViewCount)

--2)test query
select
Title,ViewCount
from Posts where OwnerUserId=5
and score>1000
order by score desc


--2
--create filtered non clustered index
--1)index structure
create nonclustered index filter_with_score_title
on Posts(Score desc)
include(Title)
where Score > 100 and Title is not null

--2)write query to demostrate the optimization
select Score,Title
from Posts
where Score>100 and Title is not null
order by Score desc

--3) as it need specific rows that they meet specific criteria that is is why filtered is good
-- also it save storage and easy maintance
