--8)
--Develop a reusable calculation that determines the age of a post in days based on its creation date.
--Input: CreationDate (DATETIME)
--Output: Age in days (INTEGER)
--Test your solution by displaying posts with their calculated ages.
go
create function dbo.AgePostsInDays(@CreationDate Datetime)
returns int
As
Begin
Declare @NumOfDays int;
set @NumOfDays=DATEDIFF(day,@CreationDate,GETDATE())
return @NumOfDays
End
go

select  Id,CreationDate,Title,dbo.AgePostsInDays(CreationDate) As AgeInDays
from Posts

--9)
--Develop a reusable calculation that assigns a badge level to users based on their reputation and post activity.
--Inputs: Reputation (INT), PostCount (INT)
--Output: Badge level (VARCHAR)
--Logic:
--'Gold' if reputation > 10000 AND posts > 50
--'Silver' if reputation > 5000 AND posts > 20
--'Bronze' if reputation > 1000 AND posts > 5
--'None' otherwise
go
create or Alter function dbo.BadgeLevel(@Reputation int,@PostCount int)
returns Varchar(30)
As
Begin
Declare @ReputationLevel varchar(30);
  if @Reputation >10000 And @PostCount>50
     set @ReputationLevel='Gold'
  else if @Reputation >5000 And @PostCount>20
   set @ReputationLevel='Silver';
   else if @Reputation >1000 And @PostCount>5
   set @ReputationLevel='Bronze'
   else
   set @ReputationLevel='None'
return  @ReputationLevel
End
go
select dbo.BadgeLevel(u.Reputation,Count(p.id)) As BadgeLevel
from Posts p inner join Users u
on p.OwnerUserId=u.Id
group by u.Id, u.Reputation


--10)
--Develop a reusable query that retrieves posts created within a specified number of days from today.
--Input: @DaysBack (INT) - number of days to look back
--Output: Table with PostId, Title, Score, ViewCount, CreationDate
--Test with different day ranges (e.g., 30 days, 90 days)
go
create or Alter function dbo.PostsRetrieved(@DaysBack int)
returns Table
As
Return(
select  Id,Title,Score,ViewCount,CreationDate
from Posts
where DATEDIFF(Day,CreationDate,GETDATE())<= @DaysBack
)
go

select *
from dbo.PostsRetrieved(200000);

--11)
--Develop a reusable query that finds top users from a specific location or all locations based on reputation threshold.
--Inputs: @MinReputation (INT), @Location (VARCHAR)
--Output: Table with UserId, DisplayName, Reputation, Location, CreationDate
--If @Location is NULL, return users from all locations.
--Test with different parameters
go
create or alter Function dbo.FindTopUsers(@MinReputation int, @Location varchar(100))
returns Table
As
Return (
Select id,DisplayName,Reputation,Location,CreationDate
from Users
where (Reputation>@MinReputation and @Location is not null and Location=@Location) or (Reputation >@MinReputation and
@Location is null
)
)
go
select *
from dbo.FindTopUsers(10000,'Georgia')
select *
from dbo.FindTopUsers(10000,null)
