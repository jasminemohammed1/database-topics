create table ChangeLog(
TableName varchar(30),
ActionType varchar(30),
UserId int ,
PostTitle varchar(30))
--Q1
--Create an AFTER INSERT trigger on the Posts table that logs every new post creation into a
--ChangeLog table.
--The log should include:
--● Table name
--● Action type
--● User ID of the post owner
--● Post title stored as new data
go
create or alter trigger  AfterInsertPostTrigger
on Posts 
After insert
As
Begin
 insert into ChangeLog(TableName,ActionType,UserId,PostTitle)
 select 'Posts','insert',i.OwnerUserId,i.Title
 from inserted i 

End;

insert into Posts(Title,body,CreationDate,LastActivityDate,Score,PostTypeId,ViewCount)
values ('new post','empty body',GETDATE(),GETDATE(),0,1,0);


select * from ChangeLog

--Q2
--Create an AFTER UPDATE trigger on the Users table that tracks changes to the Reputation
--column.
--The trigger should:
--● Log changes only when the reputation value actually changes
--● Store both the old and new reputation values in the ChangeLog table
Alter table ChangeLog
Add OldValue varchar(30)
Alter table ChangeLog
Add NewValue varchar(30)
go

create or alter trigger AfterUpdateReputation 
on Users
After Update 
AS
Begin 
set nocount on 
if update(Reputation)
Begin
 insert into ChangeLog (TableName,ActionType,OldValue,NewValue)
 select 'Users','Update Reputation',d.Reputation,i.Reputation
 from inserted i inner join deleted d
 on i.Id=d.Id
 where i.Reputation <> d.Reputation
End
End

update Users
set Reputation=20
where id=1


select *  from ChangeLog

--Q3
--Create an AFTER DELETE trigger on the Posts table that archives deleted posts into a
--DeletedPosts table.
--All relevant post information should be stored before the post is removed.

create table DeletedPost(
PostId int primary key,
PostTitle Varchar(20),
PostScore int ,
PostCreationDate DateTime,

)
go
create or alter trigger AfterDeletePost
on Posts 
After Delete 
As
Begin 
set nocount on 

insert into DeletedPost(PostId,PostTitle,PostScore,PostCreationDate)
select d.id,d.Title,d.Score,d.CreationDate
from deleted d 
print 'deleted table information archieved'
End 

--Q4
--Create an INSTEAD OF INSERT trigger on a view named vw_NewUsers (based on the Users
--table).
--The trigger should:
--● Validate incoming data
--● Prevent insertion if the DisplayName is NULL or empty
go
create or alter view vw_NewUsers 
As
select Id,DisplayName,Reputation,age,DownVotes,UpVotes,Views,Location,CreationDate,AccountId,LastAccessDate
from Users
go

create or alter trigger InsteadOfUserInsert
on vw_NewUsers 
instead of insert
As
Begin 
if exists (select 1 from inserted where DisplayName is null or DisplayName ='')
begin 
raiserror('cannot insert empty displayname',16,1)
return
end
insert into Users(DisplayName,DownVotes,CreationDate,UpVotes,AccountId,Views,Location,Reputation,LastAccessDate)
select i.DisplayName,i.downvotes,i.creationdate,i.upvotes,i.accountid,i.views,i.location,i.Reputation,i.LastAccessDate
from 
inserted i 
print ('user inserted sucessfully')

End

insert into vw_NewUsers  (DisplayName,DownVotes,CreationDate,UpVotes,AccountId,Views,Location,Reputation,LastAccessDate)
values ('',0,GETDATE(),0,1,0,'cairo',2,GETDATE())


--Q5
--Create an INSTEAD OF UPDATE trigger on the Posts table that prevents updates to the Id
--column.
--Any attempt to update the Id column should be:
--● Blocked
--● Logged in the ChangeLog table
alter table ChangeLog
add [status] varchar(100)
go
create or alter trigger InsteadOfUpdateIdColumn 
on Posts 
instead of update 
As
begin 
set nocount on
 if update(id)
 begin 
 raiserror('cannot update id column',16,1)
 insert into ChangeLog(TableName,[status]) values ('Posts','Failed To update')
 return 
 end

end 


update  posts
set id=0
where id =1

select * from ChangeLog



--Q6
--Create an INSTEAD OF DELETE trigger on the Comments table that implements a soft
--delete mechanism.
--Instead of deleting records:
--● Add an IsDeleted flag
--● Mark records as deleted
--● Log the soft delete operation

alter table comments 
add IsDeleted bit 
go
create or alter trigger InsteadOfDeleteOnComments
on Comments
instead of delete
As
Begin
 update C
 set IsDeleted=1 
 from Comments C inner join  deleted d 
 on  C.Id=d.Id

 insert into ChangeLog(TableName,[status])
 values ('Comments','SoftDelete')

 print ('soft delete instead of delete')
End


delete from Comments 
where id =4

select * from ChangeLog

--Q7
--Create a DDL trigger at the database level that prevents any table from being dropped.
--All drop table attempts should be logged in the ChangeLog table.

Alter table ChangeLog
add LoginName varchar(max),DataBaseName varchar(max),TsqlCommands Varchar(max)

go
create or alter  trigger DdlDropTrigger
on database 
for drop_table
AS
Begin 
   declare @DataEvent xml=EventData()
   declare @TableName varchar(100)
   SET @TableName = @DataEvent.value(
        '(/EVENT_INSTANCE/ObjectName)[1]',
        'VARCHAR(100)'
    );
   insert into ChangeLog(TableName) values
   (@TableName)
   rollback;
End 
create table test(id int)
drop table test;

select * from ChangeLog


--Q8
--Create a DDL trigger that logs all CREATE TABLE operations.
--The trigger should record:
--● The action type
--● The full SQL command used to create the table

create table  DDlOperationTable(
EventId int identity(1,1) primary key,
EventType varchar(100),
EventDate datetime default getDate(),
LoginName VARCHAR(100),
TSQLCommand NVARCHAR(MAX),
DatabaseName VARCHAR(100)

)
go
create or alter trigger DdlCreateTrigger
on database
for create_table
As
Begin 
declare @dataEvent xml = EventData()
--declare @TsqlCommand Nvarchar(max)=@dataEvent.value('(/EVENT_INSTACE/TSQLCommand/CommandText)[1]','NVarchar(max)')
insert into DDlOperationTable(EventType,TSQlCommand) values ('create',@dataEvent.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)'))

End 


create table testddl4(id int)
select * from DDlOperationTable

--Q9
--Create a DDL trigger that prevents any ALTER TABLE statement that attempts to drop a
--column.
--All blocked attempts should be logged.
go
create or alter Trigger ddlAlterDropComun
on database
for Alter_table 
As
Begin 
Declare @DataEvent xml= EventData()
Declare @TSQLCommand nvarchar(max)=@dataEvent.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')
if @TSQLCommand like '%drop%column%'
begin
raiserror('cannot perform drop column operation ',16,1)
rollback
end
 insert into DDlOperationTable(EventType,TSQlCommand,DataBaseName) values ('Alter',@TSQLCommand,DB_NAME())

End

create table test11ddl (id int , name varchar(10))
Alter table test11ddl
drop column id 

select * from DDlOperationTable

--Q10
--Create a single trigger on the Badges table that tracks INSERT, UPDATE, and DELETE
--operations.
--The trigger should:
--● Detect the operation type using INSERTED and DELETED tables
--● Log the action appropriately in the ChangeLog table
go
create or alter  trigger Badgetrack 
on Badges 
After update , Insert , delete 
As
Begin 
if exists (select 1 from inserted) and exists (select 1 from deleted)
begin 
insert into ChangeLog(TableName,ActionType) values ('badges','update')
end

if exists (select 1 from inserted ) and not exists (select 1 from deleted)
begin 
insert into ChangeLog(TableName,ActionType) values ('badges','insert')
end

if not exists (select 1 from inserted ) and  exists (select 1 from deleted)
begin 
insert into ChangeLog(TableName,ActionType) values ('badges','deleted')
end
End

insert into Badges (Name,UserId,Date) values ('test',1,getDate())
delete from Badges where id =82946
select * from ChangeLog

--Q11
--Create a trigger that maintains summary statistics in a PostStatistics table whenever posts are
--inserted, updated, or deleted.
--The trigger should update:
--● Total number of posts
--● Total score
--● Average score
--for the affected users.


--Q12
--Create an INSTEAD OF DELETE trigger on the Posts table that prevents deletion of posts with
--a score greater than 100.
--Any prevented deletion should be logged.
go
create or alter trigger insteadofdelete
on posts 
instead of delete 
As
Begin
if exists (select 1 from deleted where score>100) 
begin 
raiserror('cannot be deleted',16,1)
insert into ChangeLog(TableName,ActionType) values ('Posts','fail to delete')
end 
delete from posts where id in (select id from deleted where score <=100);

insert into ChangeLog(TableName,ActionType) values ('Posts',' delete')
End

delete from Posts where id =3 
select * from ChangeLog
--Q13
--============================================
--Q1
--Create a DDL trigger that prevents any table from being dropped
--in the database. Log all drop attempts to ChangeLog.
go
create or alter trigger preventdroping
on database 
for drop_table
As
begin 
declare @dataevent xml= EventData();
--DECLARE @TableName VARCHAR(100) = @dataevent.value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(100)')
insert into ChangeLog(TableName,ActionType) values (@dataevent.value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(100)'),'dropping')
print ('cannot drop')
rollback

End 

drop table TestData
select * from ChangeLog


--Q2
--Create a DDL trigger that logs all CREATE TABLE statements
--to the ChangeLog table, including the full SQL command.
go
create or alter  trigger createtablecommands
on database
for create_table 
As
Begin 
 declare @dataEvent xml =EventData();
 declare @TSQLCommands varchar(max)=@dataEvent.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')
 DECLARE @TableName VARCHAR(100) = @dataevent.value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(100)')

insert into DDlOperationTable(TSQLCommand,DataBaseName) values (@TSQLCommands,DB_NAME())
End 

create table testtrigger(id int)
select * from DDlOperationTable

--Q3
--Create a DDL trigger that prevents any ALTER TABLE statement
--that attempts to drop a column from any table.
go
create or alter Trigger ddlAlterDropComun
on database
for Alter_table 
As
Begin 
Declare @DataEvent xml= EventData()
Declare @TSQLCommand nvarchar(max)=@dataEvent.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')
if @TSQLCommand like '%drop%column%'
begin
raiserror('cannot perform drop column operation ',16,1)
rollback
end
 insert into DDlOperationTable(EventType,TSQlCommand,DataBaseName) values ('Alter',@TSQLCommand,DB_NAME())

End
--Q7
--Write a query to view all triggers in the database along with:
-- their status (enabled/disabled), type (AFTER/INSTEAD OF), and
-- the tables they're attached to.
select name as triggername,
case when is_disabled=0 then  'enabled' else 'disabled' end as status,
case when is_instead_of_trigger=0 then 'instead of' else 'after' end as type,
OBJECT_Name(parent_id) as tablename
from sys.triggers
where parent_id<>0
--Q1)
--Write the SQL commands to:
--a) Disable the trigger trg_Posts_LogInsert
--b) Enable the trigger trg_Posts_LogInsert
--c) Check if the trigger is disabled or enabled
go
create trigger trg_Posts_LogInsert
on Posts 
After insert 
AS
begin 
print ('inserted')
end

ENABLE trigger trg_Posts_LogInsert on Posts 
select name,is_disabled 
from sys.triggers
where name ='trg_Posts_LogInsert'


Disable trigger trg_Posts_LogInsert on Posts 
select name,is_disabled 
from sys.triggers
where name ='trg_Posts_LogInsert'
