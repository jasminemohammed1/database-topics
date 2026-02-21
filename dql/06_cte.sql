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
--12)
--Write a query to find the top 3 highest scoring posts for each PostTypeId.
--Use a subquery or CTE with ROW_NUMBER() and PARTITION BY.
--Display PostTypeId, Title, Score, and the rank.

with TopPosts As(
select PostTypeId,Title,Score,ROW_NUMBER() over(Partition by PostTypeId order by Score Desc) As rn
from Posts

)
select *from TopPosts where rn<=3

--13)
--Write a query using a CTE to find all users whose reputation is above the average reputation. The CTE should calculate 
--the average reputation first.
--Display DisplayName, Reputation, and the average reputation.

With AvgRep As(
select Avg(Reputation) As AvgReputation
from Users 
)
select DisplayName,Reputation,AvgRep.AvgReputation
from Users cross join AvgRep 


--14)
--Write a query using a CTE to calculate the total number of posts and average score for each user. Then join with the Users table to 
--display: DisplayName, Reputation, TotalPosts, and AvgScore.
--Only include users with more than 5 posts.
go
with PostStatisc As(
select OwnerUserId, count(*) As TotalPosts,Avg(Score) as AvgScore
from Posts
group by OwnerUserId
having Count(*)>5

)
select u.DisplayName,u.Reputation,ps.TotalPosts,ps.AvgScore
from 
Users  u inner join PostStatisc ps
on u.Id=ps.OwnerUserId



--15)
--Write a query using multiple CTEs:
--First CTE: Calculate post count per user
--Second CTE: Calculate badge count per user
--Then join both CTEs with Users table to show:
--DisplayName, Reputation, PostCount, and BadgeCount.
--Handle NULL values by replacing them with 0.
go
With  PostData As(
select OwnerUserId, Count(*) As PostCountPerUser
from Posts
group by OwnerUserId

),
 BadgeData As(
select UserId,Count(*) As BadgesCountPerUser
from Badges
group by UserId
)
select u.DisplayName,Reputation,isnull(pd.PostCountPerUser,0) As PostCount,isnull(bd.BadgesCountPerUser,0) As BadgeCount
from 
Users u
inner join 
PostData pd
on u.Id=pd.OwnerUserId
inner join 
BadgeData bd
on u.Id=bd.UserId



--16)
--Write a recursive CTE to generate a sequence of numbers from 1 to 20. Display the generated numbers.
With GenerateNumbers As(
select 1  As GeneratedNumber
union all
select GeneratedNumber +1
from GenerateNumbers
where GeneratedNumber <20

)
select * from GenerateNumbers



