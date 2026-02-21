--Q1)
-- Create a view that displays basic user information including
-- their display name, reputation, location, and account creation date.
-- Name the view: vw_BasicUserInfo
-- Test the view by selecting all records from it.
create view vw_BasicUserInfo
As
select DisplayName,Reputation,Location,CreationDate As AccountCreationDate
from Users 

select * from vw_BasicUserInfo


--Q2)
--Create a view that shows all posts with their titles, scores,
-- view counts, and creation dates where the score is greater than 10.
-- Name the view: vw_HighScoringPosts
-- Test by querying posts from this view.

create view vw_HighScoringPosts with encryption
As
select Title,Score,ViewCount,CreationDate
from Posts
where Score>10

select * from vw_HighScoringPosts

--Q3)
--Create a view that combines data from Users and Posts tables.
-- Show the post title, post score, author name, and author reputation.
-- Name the view: vw_PostsWithAuthors
-- This is a complex view involving joins.
go
create view vw_PostsWithAuthors(PostTitle,PostScore,AuthorName,AuthorReputation)
As
select p.Title ,p.Score,u.DisplayName,u.Reputation
from 
Posts p inner join Users u
on p.OwnerUserId=u.Id

select * from vw_PostsWithAuthors;

--Q4)
--Create a view that aggregates comment statistics per post.
-- Include: PostId, total comment count, sum of comment scores,
-- and average comment score.
-- Name the view: vw_PostCommentStats
-- This is a complex view with aggregation.
go
create view vw_PostCommentStats(PostId,TotalCommentCount,SummationCommentScore,AvgCommentScore)
As
select P.Id, count(P.Id),Sum(c.Score),Avg(c.Score)
from Posts P inner join Comments c
on P.Id=c.PostId
group by P.Id

select * from vw_PostCommentStats

--Q5)
--Create an indexed view that shows user activity summaries.
-- Include: UserId, DisplayName, Reputation, total posts count.
-- Name the view: vw_UserActivityIndexed
-- Make it an indexed view with a unique clustered index on UserId
go
create or Alter view vw_UserActivityIndexed4(UserId,DisplayName,Repuation,TotalPosts) 
with schemabinding
As
select u.Id,U.DisplayName,U.Reputation,COUNT_BIG(*)
from dbo.Users U inner join dbo.Posts P
on U.Id=P.OwnerUserId
group by U.Id,U.Reputation,U.DisplayName

create unique clustered index index_unq_clusteered
on vw_UserActivityIndexed4(UserId)

select * from vw_UserActivityIndexed4

--Q6

--Create a partitioned view that combines high reputation users
-- (reputation > 5000) and low reputation users (reputation <= 5000)
-- from the same Users table using UNION ALL.
-- Name the view: vw_UsersPartitioned

create table HighRepUsers(
Id int primary key,
DisplayName varchar(100),
Reputation int check(Reputation >5000)
)
create table LowRepUsers(
Id int primary key,
DisplayName varchar(100),
Reputation int check(Reputation <=5000)
)

insert into HighRepUsers(Id,DisplayName,Reputation)
select Id,DisplayName,Reputation from Users
where Reputation>5000

insert into LowRepUsers(Id,DisplayName,Reputation)
select Id,DisplayName,Reputation from Users
where Reputation<=5000

go
create view vw_UsersPartitioned(UserId,DisplayName,Reputation)
As
select  Id,DisplayName,Reputation
from HighRepUsers
union all
select  Id,DisplayName,Reputation
from LowRepUsers

select * from vw_UsersPartitioned

--Q7)
---Create an updatable view on the Users table that shows
-- UserId, DisplayName, and Location.
-- Test the view by updating a user's location through the view.
-- Name the view: vw_EditableUsers
go
create view vw_EditableUsers
As
select Id As UserId,DisplayName,Location
from Users
go

update vw_EditableUsers
set Location='cairo'
where UserId=12

select * from vw_EditableUsers

--Q8)
--Create a view with CHECK OPTION that only shows posts with
-- score greater than or equal to 20.
-- Name the view: vw_QualityPosts
-- Ensure that any updates through this view maintain the score >= 20
--condition
go
create or alter view vw_QualityPosts2
As
select Title,Id As PostId,Score
from Posts
where Score>=20
with check option

select * from vw_QualityPosts2

update vw_QualityPosts2
set Score+=12
where PostId=9

--Q9)
--Create a complex view that shows comprehensive post information
-- including post details, author information, and comment count.
--Include: PostId, Title, Score, AuthorName, AuthorReputation,
--CommentCount.
go
create or Alter view vw_comprehensivepostinformation(PostId,Title,Score,AuthorName,AuthorReputation,CommentCount)
As
select p.Id,p.Title,p.Score,u.DisplayName,u.Reputation,count(c.PostId)
from Posts P inner join Users U
on P.OwnerUserId=U.Id
left join Comments C
on P.Id=C.PostId
group by P.Id,P.Title,P.Score,u.DisplayName,u.Reputation

select * from vw_comprehensivepostinformation


--Q10)
--Create a view that shows badge statistics per user.
-- Include: UserId, DisplayName, Reputation, total badge count,
-- and a list of unique badge names (comma-separated if possible,
-- or just the count for simplicity).
-- Name the view: vw_UserBadgeStats
go 
create or alter view vw_UserBadgeStats(UserId, DisplayName, Reputation, totalbadgecount,listofbadgenames) 
as 
select u.Id,u.DisplayName,u.Reputation,count(b.Id),count(DISTINCT b.Name) 

from Badges b inner join Users u on b.UserId=u.Id group by u.Id,u.DisplayName,u.Reputation
go

select * from vw_UserBadgeStats


--Q11
--Create a view that shows only active users (those who have
-- posted in the last 365 days from today, or have a reputation > 1000).
-- Include: UserId, DisplayName, Reputation, LastActivityDate
-- Name the view: vw_ActiveUsers.

create or alter view vw_ActiveUsers
as
select U.Id As UserId,u.DisplayName,u.Reputation,p.LastActivityDate
from Users U inner join Posts P
on U.Id=P.OwnerUserId
where u.Reputation>1000 or DATEDIFF(day,p.LastActivityDate,getDate()) <=365

--Q12
--Create an indexed view that calculates total views and average
-- score per user from their posts.
-- Include: UserId, TotalPosts, TotalViews, AvgScore
-- Name the view: vw_UserPostMetrics
-- Create a unique clustered index on UserId.
go
create or alter view vw_UserPostMetrics with schemabinding
as
select u.Id As UserId, COUNT_BIG(*) As PostsCount,COUNT_BIG(P.ViewCount) As TotalViews,
Sum(P.Score) As ScoreSummation,COUNT_BIG(P.Score) As ScoreCount

from dbo.Posts P inner join dbo.Users U
on P.OwnerUserId=u.Id
group by U.Id

create unique clustered index idx_uni on
vw_UserPostMetrics(UserId)

select UserId,PostsCount,TotalViews,ScoreSummation/ScoreCount As AgvScore
from vw_UserPostMetrics

--Q13
--Create a view that categorizes posts based on their score ranges.
--Categories: 'Excellent' (>= 100), 'Good' (50-99), 'Average' (10-49),
--'Low' (< 10)
-- Include: PostId, Title, Score, Category
-- Name the view: vw_PostsByCategory
go
create or alter view vw_PostsByCategory
As
select p.Id As PostId,P.Title,P.Score,
case 
when P.Score>=100 then 'Excellent'
when P.Score between 50 and 99 then 'Good'
when P.Score between 10 and 49 then 'Average'
when P.Score <10 then 'Low'
end As Category 
from Posts p
go
select * from  vw_PostsByCategory
