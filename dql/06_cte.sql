--4)
--Create a new permanent table called Posts_Backup that stores all posts with a score greater than 10.
--The new table should include: Id, Title, Score, ViewCount, CreationDate, OwnerUserId.
select Id, Title, Score, ViewCount, CreationDate, OwnerUserId
into Posts_Backup
from Posts
where Score > 10

--5)
--Create a new table called ActiveUsers containing users who meet the following criteria:
--Reputation greater than 1000
--Have created at least one post
--The table should include: UserId, DisplayName, Reputation, Location, and PostCount (calculated).
with CalculatedPostCount As(
select OwnerUserId,Count(*) As PostCount
from Posts
where OwnerUserId is not null
group by OwnerUserId
having Count(*)>=1
)
select u.Id,u.DisplayName,u.Reputation,u.Location, CPC.PostCount
into ActiveUsers
from Users u inner join CalculatedPostCount CPC
on u.Id=CPC.OwnerUserId
where u.Reputation>1000

--6)
--Create a new empty table called Comments_Template that has the exact same structure as the Comments table but contains no data rows.

select *
into Comments_Template
from Comments
where 1=0;

--7)
--Create a summary table called PostEngagementSummary that combines data from Posts, Users, and Comments tables.
--The table should include:  PostId, Title, AuthorName, Score, ViewCount CommentCount (calculated), TotalCommentScore (calculated)
--Include only posts that have received at least 3 comments.


With CommentStatis As(
select PostId ,Count(*) AS CommentCount,Sum(Score) As TotalCommentScore
from Comments
where PostId is not null
group by PostId
having count(*) >=3
)
select p.Id,p.Title,U.DisplayName As AuthorName,p.Score,p.ViewCount,CS.CommentCount,CS.TotalCommentScore
into PostEngagementSummary2
from Posts P inner join Users U
on p.OwnerUserId=u.Id
inner join CommentStatis CS
on CS.PostId=P.Id
