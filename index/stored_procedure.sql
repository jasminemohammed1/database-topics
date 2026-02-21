--Q1)
--Create a stored procedure named sp_GetRecentBadges that retrieves all badges earned by
--users within the last N days.
--The procedure should accept one input parameter @DaysBack (INT) to determine how many
--days back to search.
--Test the procedure using different values for the number of days.
go
create or alter proc sp_GetRecentBadges @DaysBack int
As
begin 
declare @CutOffDate DateTime
 set @CutOffDate=DateAdd(day,-@DaysBack,getDate())
 select b.Name
 from Badges b
 where b.Date >= @CutOffDate
end

exec sp_GetRecentBadges 10;

--Q2
--Create a stored procedure named sp_GetUserSummary that retrieves summary statistics for a
--specific user.
--The procedure should accept @UserId as an input parameter and return the following values
--as output parameters:
--? Total number of posts created by the user
--? Total number of badges earned by the user
--? Average score of the user’s posts
go
create or alter proc sp_GetUserSummary @UserId int, @TotalPosts int output,@TotalBadges int output,
@AVGScore decimal (10,2) output
As
begin 
select Count(*) As TotalPosts, AVG(P.Score) As AVGScore
from Posts P
where P.OwnerUserId=@UserId

select Count(*) As TotalBadges 
from Badges B
where B.UserId=@UserId

end

declare @TotalPosts int
declare @TotalBadges int
declare @AVGScore decimal(10,2)

exec sp_GetUserSummary 100,@TotalPosts  output , @TotalBadges output,@AVGScore output 
select @TotalBadges As TotalBadges, @TotalPosts As TotalPosts ,@AVGScore As AVGScore

--Q3
--Create a stored procedure named sp_SearchPosts that searches for posts based on:
--? A keyword found in the post title
--? A minimum post score
--The procedure should accept @Keyword as an input parameter and @MinScore as an
--optional parameter with a default value of 0.
--The result should display matching posts ordered by score.
go
create or alter procedure sp_SearchPosts @Keyword varchar(30),@MinScore int =0
AS
begin 
select *
from Posts
where Title like '%'+@Keyword+'%'and Score >=@MinScore
order by Score
end 

exec sp_SearchPosts 'SQL' ,30;

--Q4
--Create a stored procedure named sp_GetUserOrError that retrieves user details by user ID.
--If the specified user does not exist, the procedure should raise a meaningful error.
--Use TRY...CATCH for proper error handling.
go
create or alter proc sp_GetUserOrError @UserId int 
As
Begin 
Begin try
    if not Exists (select 1 from Users where Id=@UserId)
	begin 
	raisError('User with id %d doesnot exit ',16,1,@UserId) with log
	return;
	end
	select * from Users where id=@UserId
	print ('User returned sucessfully')

End try

Begin Catch
select ERROR_MESSAGE() As ErrorMessage, ERROR_NUMBER() As ErrorNumber
print ('Error occurred while return data')
End Catch
End


exec sp_GetUserOrError 1;
exec sp_GetUserOrError 9000;

--Q5
--Create a stored procedure named sp_AnalyzeUserActivity that:
--? Calculates an Activity Score for a user using the formula:
--Reputation + (Number of Posts × 10)
--? Returns the calculated Activity Score as an output parameter
--? Returns a result set showing the user’s top 5 posts ordered by score
go
create or Alter proc sp_AnalyzeUserActivity @UserId int,@CalculatedActivityScore decimal(10,2)
output
AS
Begin
declare @Reputation int ;
declare @NumberOfPosts int ;

select @Reputation=Reputation,
@NumberOfPosts=Count(P.Id)
from Users U left join Posts P
on U.Id=P.OwnerUserId
where U.id=@UserId
group by U.Reputation

set @CalculatedActivityScore=@Reputation+(@NumberOfPosts*10)
select top 5 P.Body,P.Title,P.Score
from 
Users U inner join Posts P
on U.Id=P.OwnerUserId
Order by P.Score desc
End



declare @ActivityScore decimal(10,2);
exec sp_AnalyzeUserActivity 1, @CalculatedActivityScore=@ActivityScore output 

--Q6
--Create a stored procedure named sp_GetReputationInOut that uses a single input/output
--parameter.
--The parameter should initially contain a UserId as input and return the corresponding user
--reputation as output.
go
create or alter proc sp_GetReputationInOut @InputOutput int output
as
begin 

 select @InputOutput=Reputation
from Users 
where Id=@InputOutput
end 

declare @id int 
set @id=1
exec sp_GetReputationInOut @id output
select @id As reputation

--Q7
--Create a stored procedure named sp_UpdatePostScore that updates the score of a post.
--The procedure should:
--● Accept a post ID and a new score as input
--Validate that the post exists
--● Use transactions and TRY...CATCH to ensure safe updates
--● Roll back changes if an error occurs
go
create or alter proc sp_UpdatePostScore @PostId int ,@NewScore int 
As
Begin
begin Tran
Begin try
  if not exists (select 1 from Posts where id=@PostId)
  Begin 
  RaisError('Post with thar id is not exist',16,1)
  return;
  End
  update  Posts
  set Score=@NewScore
  where Id=@PostId
  print('Making Updates Sucessfully')
  select 'Updates done' As Result,@NewScore As NewScore
End Try
Begin Catch
 if @@TRANCOUNT>0
 rollback transaction;
 select 'Error occured while updating' As Result
End Catch
End


exec sp_UpdatePostScore 20,1000
exec sp_UpdatePostScore 600,1000

--Q8
--Create a stored procedure named sp_GetTopUsersByReputation that retrieves the top N
--users whose reputation is above a specified minimum value.
--Then create a permanent table named TopUsersArchive and insert the results returned by the
--procedure into this table.
go
create or alter proc sp_GetTopUsersByReputation @MinValue int
As
Begin
select U.DisplayName,U.Age,U.Reputation
from Users U
where U.Reputation>@MinValue
End

create table TopUsersArchive (
UserName varchar(1000),
UserId int  identity (1,1) primary key,
UserAge int,
UserRepuation int 
)

insert into TopUsersArchive(UserName,UserAge,UserRepuation)
exec sp_GetTopUsersByReputation @MinValue=700

select * from TopUsersArchive;

--Q9
--Create a stored procedure named sp_InsertUserLog that inserts a new record into a UserLog
--table.
--The procedure should:
--● Accept user ID, action, and details as input
--● Return the newly created log ID using an output parameter

create table UserLog3 (
UserId int identity (1,1)primary key,
action varchar(100),
details varchar(300)
)

go
create or alter Proc sp_InsertUserLog @UserId int,@action varchar(100),@details varchar(300),@NewlyId int output
As
Begin 
Begin Tran
set NoCount on ;
Begin Try
 if not exists (select 1 from Users where id=@UserId)
 begin 
 raisError('User with id d% is not exist',16,1,@UserId) with log
 return
 end
 insert into UserLog3(action,details) values (@action,@details);
 set @NewlyId=SCOPE_IDENTITY();
 commit tran;
 select 'Added user sucessfully in UserLog'As result ,@NewlyId As NewIdCreated
End Try
Begin Catch
 if @@TRANCOUNT>0
  rollback tran;
  set @NewlyId=-1
  select 'Error occured' As result ,@NewlyId As NewIdCreated
End Catch

End






declare @NewId int ;
exec sp_InsertUserLog 1,'Post a post','Post a post about DB',@NewlyId=@NewId



--Q10
--Create a stored procedure named sp_UpdateUserReputation that updates a user’s reputation.
--The procedure should:
--● Validate that the reputation value is not negative
--● Validate that the user exists
--● Return the number of rows affected
--● Handle errors appropriately
go
create or alter proc sp_UpdateUserReputation @UserId int ,@NewReputation int
As
Begin 
set Nocount on;
declare @AffectedARows int;
Begin tran
Begin try
  if not exists (select 1 from Users where Id=@UserId)
  begin
  raiserror('user with this id doesnot exist',16,1)
  return
  end
  if @NewReputation<0
  begin 
  raiserror('reputation cannot be negative',16,1)
  return
  end
  update Users
  set Reputation=@NewReputation
  where Id=@UserId
  set @AffectedARows=@@ROWCOUNT
  commit tran
  
  select 'updates done sucessfully'As result ,@NewReputation As NewReputation,@AffectedARows As AffecedRows
end try
begin catch
 if @@TRANCOUNT>0
 rollback tran
 select 'error occured' As result
end catch
End



exec sp_UpdateUserReputation 1,5000


--Q11
--Create a stored procedure named sp_DeleteLowScorePosts that deletes all posts with a score
--less than or equal to a given value.
--The procedure should:
--● Use transactions
--● Return the number of deleted records as an output parameter
--● Roll back changes if an error occurs

go
create or alter proc sp_DeleteLowScorePosts @Threshold int,@AffectedRows int output
As
begin 
set nocount on
begin tran
begin try
  
 delete from Posts where Score <=@Threshold
 set @AffectedRows=@@ROWCOUNT
 select 'deleted succesfuuly' As result
 commit tran
end try
begin catch
 if @@TRANCOUNT>0
 rollback tran
 set @AffectedRows=-1;
 select 'Error occured' As result
end catch 
end

declare @AffectedRows int 
exec sp_DeleteLowScorePosts 12,@AffectedRows output
select @AffectedRows


--Q12
--Create a stored procedure named sp_BulkInsertBadges that inserts multiple badge records for
--a user.
--The procedure should:
--● Accept a user ID
--● Accept a badge count indicating how many badges to insert
--● Insert multiple related records in a single operation
go
create or alter proc sp_BulkInsertBadges @UserId int ,@BadgeCount int
As
Begin  

begin tran
Begin try 

with Number AS(
select 1 as n
union all
select n+1 from Number where n+1 < @BadgeCount
)
insert into Badges(UserId,Name,Date)
select @UserId,'New Badge',GetDate() from Number
select 'inserted sucessfully' As result
commit tran

End Try 
Begin Catch 
  rollback tran
 select 'Error occured' As result
End catch

End


exec sp_BulkInsertBadges 1,10;


--Q13
--Create a stored procedure named sp_GenerateUserReport that generates a complete user
--report.
--The procedure should:
--➢ Call another stored procedure internally to retrieve user statistics
--➢ Combine user profile data and statistics
--➢ Return a formatted report including a calculated user level
go
create or alter proc  SP_User_statistics @Id int,@PostCount int output,
@AVGScore decimal(10,2) output ,@SummationScore int output 
As
Begin 
Set nocount on 
Begin Tran
Begin try
  if not exists (select 1 from Users where Id=@Id)
  begin 
  raiserror('this user isnot exist',16,1)
  return
  end

  select @PostCount= count(P.Id) , @AVGScore=AVG(P.Score)  ,@SummationScore=Sum(P.Score) 
  from  Posts P
 where p.OwnerUserId=@Id

  commit Tran
  
  

End Try

begin catch
 if @@TRANCOUNT>0
 rollback tran
 select 'Error occured' As result
 set @AVGScore=0;
 set @PostCount=0;
 set @SummationScore=0;

end catch

End


go
create or alter proc UserComibnedDate @Userid int 
As
Begin
begin tran
begin try
  if not exists ( select 1 from users where id=@Userid)
  begin
  raiserror('this user doesnot exist',16,1)
  return
  end
  declare @Postcount int 
  declare @AVGScore decimal(10,2)
  declare @SummationScore int
exec SP_User_statistics @id=@UserId, @PostCount =@Postcount output ,@AVGScore=@AVGScore output ,@SummationScore=@SummationScore output 
 declare @UserLevel varchar(20)
 set @UserLevel = case 
 when @Postcount>500
 then 'high'
 when @Postcount>100
 then 'mediem'
 when @Postcount>50
 then 'Low'
 end

select u.DisplayName,u.Age,u.EmailHash,u.Reputation,@Postcount As NumOfPosts,@AVGScore As AVGScore,@SummationScore
As SummationScore,@UserLevel As UserLevel
from Users u
where u.Id=@Userid
commit tran
end try
begin catch
 if @@TRANCOUNT>0
  rollback tran
end catch
end

exec UserComibnedDate 1;



