ALTER AUTHORIZATION
ON DATABASE::UniversityResearchSystem
TO sa;
--Q1
--Write a query to display all researchers along with the projects they work on. Include
--researchers who are not currently working on any project.
select R.Id,R.FirstName,R.MiddleName,R.LastName, P.Title,P.Status
from Researcher R 
left join WorksOn W 
on R.Id=W.ResearcherId
left join ResearchProject P
on P.Id=W.ProjectId

--Q2
--List all research projects with their lead researcher's full name and email. Show only projects
--that have at least one grant funding them.

select P.Title as ProjectTitle, P.Status As ProjectStatus, P.Budget As ProjectBudget,
CONCAT(R.FirstName,' ',R.MiddleName,' ',R.LastName) As LeaderFullName,R.Email As LeaderEmail
from ResearchProject P inner join Researcher R
on P.LeaderId= R.Id
where Exists(select 1 from Funds f 
inner join Grants G
on F.GrantId=G.Id
where f.ProjectId=P.Id
)



--Q3
--Write a query to show all possible combinations of researchers and publications. Then explain
--why this might be a bad idea for a production query.

select P.Title, P.Title, P.CitationCount, P.DOI , R.FirstName , R.LastName , R.MiddleName , R.Email
from Publication P cross join Researcher R

-- this is very costly production query as there is no cutoff condition it try to combine all the rows from first 
-- table with all the rows with the second table 
-- the Total num of rows returned = #Table1 * #Table2

--Q4
--Display all researchers who supervise others, along with the names of researchers they
--supervise. Include the supervision start date and role.

select concat ( supervisor.FirstName , supervisor.MiddleName , supervisor.LastName) As SupervisorName , concat (supervised.FirstName,supervised.MiddleName,supervised.LastName) As SupervisedName , s.Role, s.SupervisionStartDate
from Researcher supervisor inner join Supervises s
on supervisor.Id = s.SupervisorId
inner join Researcher supervised 
on s.SupervisedId = supervised.Id




--Q5
--Write a query to find all researchers who have published papers but are NOT currently working
--on any active project.

select CONCAT(R.FirstName,' ',R.MiddleName,' ',R.LastName) As ResearcherFullName , PC.Type
from Researcher R inner join Publishes P
on R.Id= P.ResearcherId
inner join Publication PC
on P.PublicationId = PC.Id
where not exists (
select 1 from ResearchProject inner join WorksOn
on ResearchProject.Id= WorksOn.ProjectId
and WorksOn.ResearcherId=R.Id
and ResearchProject.Status = 'active'
)





--Q6
--Retrieve the five most-cited publications, ensuring that any publications sharing the same
--citation count as the fifth-ranked entry are also included.

select top 5 with ties *
from Publication
order by CitationCount desc

--Q7
--Retrieve researchers ordered by last name, displaying the second page of results with 10
--records per page.
select *
from Researcher
order by LastName
offset 10 rows 
fetch next 10 rows only 

--Q8
--Compare the results of:
SELECT TOP 3 *
FROM Researcher
ORDER BY LastName
--Versus
SELECT *
FROM Researcher
ORDER BY LastName
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY
--Are they functionally identical? What are the advantages of OFFSET-FETCH over TOP?
-- the result set of both is the same they return top 3 of names order ascend
-- we can use offset and fetch as replace to top but we cannot use top in replace of pagination to offset - fetch 
-- offset - fetch used in pagination while top not 
-- offset - fetch must have order by  while top can be used without order by 
-- the performance of offset - fetch is good than top in pagination (advatnage)
-- so i think they do  same things in functionality  but offset - fetch can do more than top (Pagination)

--Q9
--Assign a unique sequential index to each researcher within the same building, ordered by date
--of birth from oldest to youngest.
select ROW_NUMBER() over (Partition by building Order by  dateofbirth ) as SequentialIndex , *
from Researcher

--Q10
--Rank publications within each publication type (Journal or Conference) based on their citation
--count, and display the publication title, type, citation count, and rank.

select p.CitationCount , p.Title , p.Type , DENSE_RANK() over (Partition by Type order by CitationCount desc) As RankPerType
from Publication p

--Q11
--Rank research projects by their budget within each status category, then explain how ranking
--with gaps differs from ranking without gaps.

--1) ranking without gaps

select DENSE_RANK() over (Partition  by status order by budget desc) AS RankingWithoutGaps, Status, Budget
from ResearchProject
--when two projects take the same rank the next take the next rank (1 - 1) the next is 2 (ثانويه عامه)  without gaps
-- 100 ->rank 1
-- 100 ->rank 1
-- 90  ->rank 2
--2) ranking with gaps
select Rank() over (Partition  by status order by budget desc) AS RankingWithGaps, Status, Budget
from ResearchProject
--when two projects take the same rank the next take the next next rank (1 -1 ) the next is 3 (الالومبيات) with gaps
-- 100 ->rank 1
-- 100 ->rank 1
-- 90  ->rank 3

--Q12
--Divide researchers into four equal groups based on the number of publications they have
--authored, and display each researcher’s ID, name, publication count, and group number.

select R.Id ,R.FirstName, count (p.PublicationId) As PublicationCount ,NTILE(4) over (Order By count (p.PublicationId) desc) As groupNumber
from Researcher R left join Publishes P
on R.Id = P.ResearcherId
group by R.Id, R.FirstName



--Q13
--Explain the logical execution order of the following query clauses: SELECT, FROM, WHERE,
--GROUP BY, HAVING, ORDER BY, TOP/OFFSET-FETCH.

--1) from 
--2) where 
--3) group by
--4) having 
--5) select
--6) orderby
-- 7) top 
-- 8) offset - fetch


--Q14
--Given this query, explain why it produces an error and how to fix it:
/*SELECT ResearcherId, COUNT(*) as ProjectCount
FROM WorksOn
WHERE ProjectCount > 2 GROUP BY ResearcherId
*/


select w.ResearcherId , count (w.ProjectId) as ProjectCount
from WorksOn w
group by w.ResearcherId
having count (w.ProjectId) >2


-- the error simply because (where clause) is executed before the select so is cannot see the projectCount
-- to correct it we must use having as we deal with aggregate function

--Q15
--Write a query to display each researcher's full name (FirstName + MiddleName + LastName) as
--a single column, their email in lowercase, and their age in years.

select CONCAT(r.FirstName ,' ', r.MiddleName, ' ', r.LastName) As ResearcherFullName , LOWER(r.Email) As EmailInLowerCase,
DATEDIFF(YEAR,r.DateOfBirth,getDate()) As ResearcherAge
from Researcher r

--Q16
--For each research project, calculate the duration in days between StartDate and EndDate (or
--current date if EndDate is NULL). Also show the month and year when the project started.

select DATEDIFF(DAY,p.StartDate,isNull(p.EndDate,GetDate())) As ProjectDurationInDays, Year(P.StartDate) YearOfProjectStarted , 
Month(P.StartDate) As MonthOfProjectStarted
from ResearchProject p

--Q17
--Write a query to find all researchers whose email domain (part after @) is 'university.edu'.


select *
from Researcher
where Email like '%@university.edu'

--Q18
--Display researcher details, substituting 'N/A' wherever the MiddleName or RoomNumber is
--missing.

select iif(R.MiddleName is null or R.MiddleName = '' or RoomNumber is null ,'N/A',CONCAT('Id:  ',R.Id, '   ' , ',FirstName:  ',R.FirstName , '  ' ,',MiddleName:  ', R.MiddleName , '  ',',LastName:  ', R.LastName ,'  ', ',RoomNumber:  ',R.RoomNumber , '  ',',DateOfBirth:  ',R.DateOfBirth)) 
As Details
from Researcher R

--Q19
--Write a query to classify projects into categories based on their budget: 'Small' for budgets
--under 50,000, 'Medium' for budgets between 50,000 and 150,000, and 'Large' for budgets
--exceeding 150,000.

select case 
when Budget < 50000 then 'Small'
when Budget >=50000 and budget <=150000 then 'Medium'
when Budget > 150000 then 'Large' 
end
As ProjectCategory, Budget
from ResearchProject 

--Q20
--Calculate the total budget managed by each researcher who leads one or more projects, and
--display their full name alongside this total.

select CONCAT(R.FirstName,' ',R.MiddleName,' ',R.LastName) As LeaderFullName, R.Id,Sum(P.Budget) As TotalBudget
from Researcher R inner join ResearchProject P
on R.Id = P.LeaderId
group by R.Id , R.FirstName,R.LastName, R.MiddleName




--Q21
--Display the number of researchers in each building, but only for buildings that have more than 3
--researchers.

select R.Building,count(R.id) as NumberOfResearcher
from Researcher R
group by R.Building
having (count (id) >3)

--Q22
--For each publication type, calculate the average citation count, total citations, and number of
--publications. Filter to show only types with an average citation count above 50.

select p.Type, Avg(P.CitationCount) As AverageCitationCount, Sum(P.CitationCount) As TotalCitation , Count(P.Id) As 
NumberOfPublication
from Publication P
group by P.Type
having Avg(P.CitationCount)>50


--Q23
--Find researchers who work on more than 2 projects and have a total weekly hour commitment
--exceeding 60 hours. Show ResearcherId, project count, and total hours.

select R.id, count (W.ProjectId) As ProjectCount ,sum( W.HoursPerWeek) As TotalNumberOfHours
from Researcher R inner join WorksOn W
on R.Id=W.ResearcherId 
group by R.Id
  having count (W.ProjectId) > 2 and sum (W.HoursPerWeek) >60


--Q24
--Write a query using a subquery to find all projects that have a budget greater than the average
--budget of all projects.

select *
from ResearchProject
where Budget >(select Avg(Budget) from ResearchProject)


--Q25
--Write a query using a subquery to find researchers who have more publications than the
--average number of publications for researchers in the same building.

select R.Id , R.FirstName , R.Building, count (p.PublicationId) As Publicationcount
from Researcher R inner join Publishes P
on R.Id = P.ResearcherId
group by R.Id , R.FirstName ,  R.Building
having count (P.PublicationId) >
(
 select Avg( sub.totalPublish)
  from (
  select R2.Id ,R2.building ,count (P.PublicationId) totalPublish
 from  Researcher R2 inner join Publishes P
  on R2.Id = P.ResearcherId
  where R.Building = R2.Building
  group by R2.Id,R2.Building ) As sub


);




--Q26
--Write a query using EXISTS to find all researchers who supervise at least one other researcher.

select  * 
from Researcher R
where exists (
select 1 from  Supervises S
where S.SupervisorId = R.Id
and s.SupervisedId is not null
)

--Q27
--Use a subquery to display each project along with the total number of researchers working on
--it.


select RP.*, (select count (R.Id)
from Researcher R
inner join WorksOn W
on R.Id=W.ResearcherId
where W.ProjectId= RP.Id
) As NumberOfResearchersWorking
from ResearchProject RP


--Q28
--Write a query to find the second highest budget among all research projects (Do not use
--OFFSET-FETCH or ranking functions).
select top 1 *
from ResearchProject where 
Budget < (select max(Budget) from ResearchProject)
order by budget desc



--Q29
--Combine the list of all researcher emails and all grant funding agency names into a single list
--labeled "Contact Information".

select Email As [contact Information]
from Researcher
union 
select FundingAgency
from Grants

--Q30
--Identify researchers involved in projects who have not authored any publications.

select R.Id , R.FirstName , R.MiddleName
from Researcher R inner join WorksOn W
on R.Id= W.ResearcherId

except 
select R2.Id , R2.FirstName , R2.MiddleName
from  Researcher R2 inner join  Publishes P
on R2.Id= P.ResearcherId




--Q31
--Find researchers who supervise others and also lead one or more research projects.

select R.Id , CONCAT(R.FirstName,' ',R.MiddleName,' ',R.LastName) As ResearcherFullName
from Researcher  R inner join Supervises S
on R.Id=S.SupervisorId

intersect

select R.Id , CONCAT(R.FirstName,' ',R.MiddleName,' ',R.LastName) As ResearcherFullName
from Researcher R inner join ResearchProject P
on R.Id = P.LeaderId

--Q32
--Write a CTE to calculate the total hours per week for each researcher across all their projects,
--then use it to find researchers working more than 40 hours per week.

with ReseracherHoursPerWeek   As(

select IsNull(Sum(W.HoursPerWeek),0) As TotalhoursPerweek,
R.Id As ResearcherId,
CONCAT(R.FirstName,' ',R.MiddleName,' ',R.LastName) As ResearcherFullName
from Researcher R left join WorksOn W
on R.Id = W.ResearcherId
group by R.Id , R.FirstName , R.MiddleName , R.LastName
)

select TotalhoursPerweek , ResearcherFullName ,ResearcherId  from ReseracherHoursPerWeek 
where TotalhoursPerweek > 40


--Q33
--Write a query using multiple CTEs: one to get the total budget per researcher (who leads
--projects), another to get their publication count, then join them to show researchers with
--budget > 100000 AND at least 3 publications.

with TotalBudget As(
  select Sum(P.Budget) As TotalBudget,
  R.Id As ResearcherId,
  CONCAT(R.FirstName,' ',R.MiddleName,' ',R.LastName) As ResearcherFullName
  from Researcher R inner join ResearchProject P
  on R.Id = P.LeaderId
  group by R.Id,R.FirstName,R.MiddleName,LastName
),
PublicationCount As
(
  select  R.Id As ResearcherId,
  CONCAT(R.FirstName,' ',R.MiddleName,' ',R.LastName) As ResearcherFullName,
  count (Ps.PublicationId) As TotalPublication
  from Researcher R 
  left join Publishes Ps
  on R.Id =Ps.ResearcherId
  group by R.Id,R.FirstName,R.MiddleName,LastName
)
select Pc.ResearcherId , Pc.ResearcherFullName , Pc.TotalPublication, TB.TotalBudget
from PublicationCount PC inner join TotalBudget TB
on PC.ResearcherId = TB.ResearcherId
where PC.TotalPublication >=3 and TB.TotalBudget >100000


--Q34
--Write a reusable function that takes a ProjectId and returns how many days the project has
--been active, calculating from the start date to either the end date or today if the project is
--ongoing.
GO
CREATE OR ALTER FUNCTION dbo.ProjectDaysActive (@ProjectId varchar(10))
RETURNS INT
AS
BEGIN
    DECLARE @ActiveDays INT;

    SELECT @ActiveDays =
        DATEDIFF(
            DAY,
            P.StartDate ,
            ISNULL(P.EndDate ,GETDATE() )
        )
    FROM ResearchProject P
    WHERE P.Id = @ProjectId;

    RETURN @ActiveDays;
END
GO

SELECT dbo.ProjectDaysActive('P002') AS DaysActive;


--Q35
--Write a reusable function that takes a ResearcherId and returns all projects they are involved in,
--showing the project title, their role, and hours worked per week.
go
CREATE or Alter function dbo.GetProjectById(@ResearcherId varchar(10))
Returns table 
As
return (
select  P.Title , W.Role , W.HoursPerWeek
from WorksOn W inner join ResearchProject P
on W.ProjectId = P.Id
where  W.ResearcherId = @ResearcherId

)
go

select * from dbo.GetProjectById('R001')

--Q36
--Write a function that takes a ResearcherId and returns a table containing the total number of
--projects, total publications, total hours worked per week, and average citations per publication
--for that researcher. Also, explain the scenarios where a multi-statement table-valued function is
--preferred over an inline table-valued function.
go
create or alter function dbo.CoPrehinsiveFunc(@ResearcherId varchar(10))
Returns @table Table(
TotalNumOfProjects int,
TotalPublications int, 
TotalHoursWorked int,
AVGCitationPerPublication decimal(10,2)

)

As
begin 
 declare @TotalNumOfProjects int ,
  @TotalPublications int , 
 @TotalHoursWorked int ,
 @AVGCitationPerPublication decimal(10,2)


 select @TotalNumOfProjects = ISNull(count (W.ProjectId),0)
 from WorksOn W
  where W.ResearcherId = @ResearcherId


  select @TotalPublications= isNull(count (P.PublicationId),0)
  from Publishes P
  where P.ResearcherId = @ResearcherId


  select @TotalHoursWorked=ISNull( Sum(W.HoursPerWeek),0)
  from WorksOn W
  where W.ResearcherId = @ResearcherId


  select @AVGCitationPerPublication = AVg( isnull(Pc.CitationCount,0))
  from Publishes P inner join Publication Pc
  on P.PublicationId = Pc.Id
  where P.ResearcherId = @ResearcherId
  


  insert into @table(TotalPublications,TotalNumOfProjects,TotalHoursWorked,AVGCitationPerPublication)
  values (@TotalPublications,@TotalNumOfProjects,@TotalHoursWorked,@AVGCitationPerPublication)
return;
End
go

select * from dbo.CoPrehinsiveFunc('R009')

-- when we need to return a table that is build step by step with columns new that
--havenot been in any table in our DB , if we need to do insert based on select or more complex
--logic with multiple select  statements

--Q37
--Create a non-clustered index on the ResearchProject table to improve queries that search by
--Status and StartDate.

select P.Title
from ResearchProject P
where Status = 'Active' 
order by StartDate desc

create nonclustered index indx_ResearchProject_by_Status_StartDate
on ResearchProject (Status,StartDate desc)
include (Title,Budget)


--Q38
--Explain the difference between a clustered and non-clustered index. How many clustered
--indexes can a table have? What happens to existing indexes when you create a clustered index?

-- Cluster index : is how physically the data is stored on the disk 
-- As we cannot sort and store data based on 2 columns so we have only one 
-- clustered index per table (default is PK) but we can change it 
-- it looks like a B tree and each node contain all the date 


-- NonClusted index: it speed up the queries that filter with non key columns 
-- it create a seperate structure (b tree) and each node contains only the column in the index 
-- and leaf node oly contains pointers either to the actual data or clusted index if exists
-- we can have many non-clusted index per table 


-- when creating cluster index on table has already non cluster index it will re-build or re-organize
-- as the leaf node should now has pointer to that new cluster index to get the rest of columns 
-- as it doesnot contain all data

--Q39
--You have a query that frequently searches for researchers by Email and retrieves their
-- FirstName and LastName. Write a covering index that would make this query more efficient.
-- Explain what a covering index is and why it improves performance.


select R.FirstName , R.LastName
from Researcher R
where email ='peter.wilson24@example.com' 


create nonclustered index idx_Researcher_by_Email
on Researcher(email)
include (FirstName,LastName)

-- the covered index is to put all needed cloumns (include) as 
-- if i donnot do that even if i make clusted index on email the SQL will
-- ignore the index and make full table scan as it will need data from the clustered index

--Q40
--Create a view named ActiveProjectSummary that shows project title, leader name, number of team
 --members, total hours per week allocated, and total budget..
 go
 create or alter view ActiveProjectSummary
 As
 select P.Id, P.Title As ProjectTitle, Concat (R.FirstName,R.MiddleName,R.LastName) As LeaderName,
 isNull(count(W.ResearcherId),0) As NumberOfTeamMembers,
 isNull(Sum(P.Budget),0) As TotalBudget,
 isNull(Sum(W.HoursPerWeek),0) As TotalHoursPerWeek
 from ResearchProject P inner join Researcher R
 on P.LeaderId = R.Id
 left join WorksOn W
 on P.Id = W.ProjectId
 where P.Status ='Active'
 group by P.Id , P.Title, R.FirstName , R.MiddleName ,R.LastName
 

 go

 select * from ActiveProjectSummary




 --Q41
 --Create an indexed view named ResearcherPublicationStats that shows ResearcherId, researcher full
 --name, and total number of publications. Include the necessary.

 -- it tryied very much to use concat or + in indexed view but i cannont, i try to use view in view but cannot work in this case
 -- i think that we can add column FullName in the Researcher table 

 Alter table Researcher
 Add  FullName varchar(100);

 update Researcher
 set FullName = CONCAT(FirstName,' ',MiddleName ,' ', LastName)

 select * from Researcher

 go
 create or Alter view ResearcherPublicationStats(ResearcherId,ResearcherFullName,TotalNumberOfPublications)
 with schemabinding
 As

 select R.Id , 
R.FullName, COUNT_BIG(*)
 from dbo.Researcher R inner join dbo.Publishes P
 on R.Id = P.ResearcherId
 
 group by R.Id, R.FullName

 go
 create unique clustered index indx_Unique 
 on dbo.ResearcherPublicationStats(ResearcherId)

 select ResearcherId, ResearcherFullName,
 TotalNumberOfPublications from ResearcherPublicationStats

 --Q42
 --Explain the requirements and restrictions for creating an indexed view. What are the
--performance benefits? When would you choose an indexed view over a regular view or a table?

-- requirements :
-- 1) must say with schema binding
-- 2) must specify the schema name of the tables
-- 3) must use count_big 
--4)  must create unique clustered index on view 

-- Restrictions

-- 1) cannoy use AVG or Min or Max 
-- 2) cannot use undeterminstuc functions like newid
-- 3) cannot use count(*)
-- 4)cannot use left or ritht or outer join
-- 5) cannot use union or union all or distinct
-- 6) cannot use CTE or top or offset or subquery or derived table 

-- performance benifts
-- it is store phsically the output result set on the disk and boost up the query speed as 
-- it see it as precalculated query 

--chossing it 
-- i will choose it over the reqular view  if it complex query and uses many joins 
-- so i need to deal with it as precalculated data 
-- i will choose it over a regular table if i want to abstract some columns or improve the security for some users 
-- or to only allow them to view specfic columns
-- also i will use it if the table doesnot have many updates (penalty of insert ot update or delete ) 
-- as it will also affect the indexed view 

--Q43
--Create a stored procedure named AddResearcherToProject that accepts ResearcherId, ProjectId,
--JoinDate, Role, and HoursPerWeek as parameters. The procedure should:
--● Validate that both researcher and project exist
--● Check that the researcher isn't already on the project
--● Insert the record into WorksOn
--● Return 0 for success, -1 for errors
go
create or alter proc AddResearcherToProject(@ResarcherId varchar(10), @ProjectId varchar(10), @joinDate date , @Role varchar(50) , @HoursPerWeek int)
As
begin
begin try
if not exists (select 1 from Researcher where Id = @ResarcherId)
begin
raiserror('this researcher doesnot exist',16,1);
return
end
if not exists (select 1 from ResearchProject where Id = @ProjectId)
begin
raiserror('this Project doesnot exists',16,1);
return;
end
if exists (select 1 from WorksOn where ResearcherId = @ResarcherId and ProjectId = @ProjectId)
begin 
raiserror('this researcher already on that project',16,1);
return;
end

insert into WorksOn(ResearcherId,ProjectId,JoinDate,Role,HoursPerWeek)
values (@ResarcherId,@ProjectId,@joinDate,@Role,@HoursPerWeek)
print ('Added sucessfully')
return 0;
end try
begin catch
Print (error_message());
return -1;
end catch
End


exec AddResearcherToProject 'R001','P001','2023-01-01','Researcher',1200;--invalid
exec AddResearcherToProject 'R029','P030','2023-01-01','Researcher',12; --valid


--Q44
--Create a stored procedure named UpdateProjectStatus that accepts a ProjectId and changes its
--status from 'Pending' to 'Active', but only if the project has at least one researcher assigned and
--at least one funding source. Use appropriate error handling.
go
create or alter Proc UpdateProjectStatus(@ProjectId varchar(10))
As
begin
begin try
if not exists (select 1 from ResearchProject where Id = @ProjectId)
begin 
raiserror ('this project that you try to update doesnot exist',16,1);
return;
end

if exists (select 1 from
Funds F 
where F.ProjectId = @ProjectId
and F.GrantId is not null
) and exists (
select 1 from WorksOn W
where W.ProjectId  = @ProjectId
and W.ResearcherId is not null 
and W.Role = 'Researcher'
)

begin 
update ResearchProject
set Status ='Active'
where  Status ='Pending' and Id=@ProjectId

PRINT 'Project status updated to Active';
            RETURN 0;
end
else
begin
Print (' This Project cannot be updated')
end

end try


begin catch

print (error_message())
return -1;

end catch

End

exec UpdateProjectStatus 'P001'


select P.Id
from ResearchProject P inner join WorksOn W
on P.Id = W.ProjectId
where W.Role ='Researcher' and P.Status ='Pending'

intersect

select P.Id 
from ResearchProject P inner join Funds F
on P.Id = F.ProjectId and P.Status ='Pending'

-- no projects meet the conditions


--Q45
--Write a stored procedure with OUTPUT parameters that accepts a ResearcherId and returns the
--total number of projects they work on, their total publications, and their total weekly hours
--across all projects.
go
create or alter Proc SummaryAboutResearcher (@ResearcherId varchar(10) ,@TotalNumberOfProject int output , @TotalPublications int output , @TotalWeeklyHours int output )
As
begin


select @TotalNumberOfProject = ISNULL( count (W.ProjectId),0)
from WorksOn W
where W.ResearcherId = @ResearcherId

select @TotalPublications= IsNull(count (P.PublicationId),0)
from Publishes P
where P.ResearcherId= @ResearcherId

select @TotalWeeklyHours = ISNull(Sum(W.HoursPerWeek),0)
from WorksOn W
where W.ResearcherId= @ResearcherId

end




declare @TotalNumberOfProjectoutput int ;
declare @TotalPublicationsoutput int ;
declare @TotalWeeklyHoursoutput int;

exec SummaryAboutResearcher 'R001',@TotalNumberOfProjectoutput output, @TotalPublicationsoutput output ,  @TotalWeeklyHoursoutput output 



select @TotalNumberOfProjectoutput As TotalNumerOfPjocts ,@TotalPublicationsoutput as TotalNumberOfPublication ,@TotalWeeklyHoursoutput As TotalNumberOfHours


--Q46
--Create an AFTER INSERT trigger on the WorksOn table that prevents a researcher from being
--assigned to more than 5 projects. If the insertion would exceed this limit, rollback the
--transaction and raise an error.
go
create or alter trigger After_insert_workson
on Workson 
After insert 
As
begin 


if exists (
select 1 from (
select  count (i.ProjectId) As ProjectCount
from inserted i inner join WorksOn W
on i.ResearcherId= W.ResearcherId
group by i.ResearcherId) As T
where T.ProjectCount >5
)
begin
raiserror('Cannot insert as it will exceed 5 Projects',16,1);
rollback tran;
return;
end
else
print ('Added Sucessfully')

end

--After adding in works on more date
select R.Id
from WorksOn W inner join Researcher R
on W.ResearcherId = R.Id
group by R.Id
having count (W.ProjectId) = 5

-- R001 -

insert into WorksOn (Role,ResearcherId,ProjectId,JoinDate) values ('test','R001','P025','2025-1-3')
--cannot Added

select R.Id
from WorksOn W inner join Researcher R
on W.ResearcherId = R.Id
group by R.Id
having count (W.ProjectId) = 3
-- R002 
insert into WorksOn (Role,ResearcherId,ProjectId,JoinDate) values ('test','R002','P009','2025-1-3')
--Added Sucessfully


--Q47
--Create a trigger on the ResearchProject table that automatically updates the Status to
--'Completed' when an EndDate is set to a date in the past. Should this be an AFTER or INSTEAD
--OF trigger? Explain your choice.

-- i think After trigger is better as i donnot need to do validation and then insert 
-- and i donnot need to do alternative action 
go
create or Alter Trigger updateStatusOfProject
on ResearchProject 
After update , insert 
As
begin 
 update P
 set Status ='completed'
 from ResearchProject P inner join inserted i
 on P.Id = i.EndDate
 where i.EndDate is not null 
 and i.EndDate < GETDATE()
 
end


--Q48
--Create an audit trigger that logs all updates to the Grants table. Create an appropriate audit
--table to store: GrantId, OldAmount, NewAmount, ModifiedBy (SYSTEM_USER), ModifiedDate.

create table GrantAudit3(
AuditId int primary key identity (1,1),
GrantId varchar(10) ,
OldAmount decimal (12,2),
NewAmount decimal (12,2),
ModifiedBy varchar(50),
ModifiedDate date default getDate()
)


go

create or alter trigger trigger_Audit_Grants
on Grants
After update
As
begin
insert into GrantAudit3 (GrantId,OldAmount,NewAmount,ModifiedBy,ModifiedDate)
select i.StartDate , d.Amount , i.Amount,SYSTEM_USER , getdate()
from inserted i inner join deleted d 
on i.Id = d.Id 
where i.Amount <> d.Amount

end


--Q49
--Write a transaction that:
--1. Creates a new research project
--2. Assigns the project leader to work on it
--3. Allocates a grant to fund it
--Include proper error handling with TRY-CATCH and ROLLBACK if any step fails.

begin try
begin transaction
--1)

  if exists (select 1 from Researcher where id = 'R031') and  exists (select 1 from Grants where id ='G015')
  begin
  --1)
  insert into ResearchProject(Id,Title,StartDate,LeaderId)
values ('P200','new project',getdate(),'R031')

--2)
insert into WorksOn(ResearcherId,ProjectId,JoinDate,HoursPerWeek,Role)
values ('R031','P200',GETDATE(),12,'Leader')

--3)
insert into Funds (GrantId,ProjectId,AllocationDate,AllocationAmount)
values ('G015','P200',GETDATE(),18000)

print ('done sucessfully')
commit

  end

  else
  begin
  rollback tran
  raiserror('Researcher not exists or Grants doesnot exists',16,1);
  return;

  end


end try 
begin catch

if @@TRANCOUNT >0
begin
 rollback tran
end
else
print ERROR_MESSAGE()


end catch

-- Check project created
SELECT * 
FROM ResearchProject 
WHERE Id = 'P200';

-- Check leader assigned
SELECT * 
FROM WorksOn 
WHERE ProjectId = 'P200';

-- Check funding allocated
SELECT * 
FROM Funds 
WHERE ProjectId = 'P200';


--Q50
--Explain the ACID properties of transactions. For each property, give an example from the
--university research database showing why it's important.

--A: Atomicity: that if we have a procedure (some steps) related to others that one step  if fails all should be fails
-- create new new researcher and this assign a supervisor on it 
-- create new project and assign worker on it 

--C: consistency, the Data base state must be the same as begening tran or ending it 
-- or the transcation must take the DB state from consistent one to another one consistent 
-- in otherwords the constraints and all the data integrity or domain constraints must be valid 

--the funds allocation amount cannot be negative 

--I: isolation, all the transactions can feel that the only one in the system or all the uncommited data 
-- cannot be visible to others trnsactions.
-- when adding new researcher and in the step that i donnot commit yet must this be not visible to works on table as
-- i may rollback so in works on table now has wrong data (dirty read)

--D: durability all the commited actions must be saved permenant and cannot be rollback
-- after adding a new Researcher and commit the transcation must be saved on the disk. 


--explain Atomicity
--


begin try 
begin tran

--1) add new employee

--2) add supervisor

insert into Researcher(Id,FirstName,MiddleName,LastName,Email)
values ('R888','Saja','Mohamed','Elsayed','saja@gmail.com');

insert into Supervises(SupervisedId,SupervisorId,Role,SupervisionStartDate)
values ('R888','R001','test',GETDATE());

commit 
end try
begin catch
if @@TRANCOUNT>0
begin
rollback
end
end catch

--explain the consistency
-- the data is consistent, if Researcher with R888 is not exists so no supervisor on it
-- the data base state is consistent
begin try 
begin tran

--1) add new employee

--2) add supervisor

insert into Researcher(Id,FirstName,MiddleName,LastName,Email)
values ('R888','Saja','Mohamed','Elsayed','saja@gmail.com');

insert into Supervises(SupervisedId,SupervisorId,Role,SupervisionStartDate)
values ('R888','R001','test',GETDATE());

commit 
end try
begin catch
if @@TRANCOUNT>0
begin
rollback
end
end catch

-- explain isolation 
-- using the isolation levels here i want to prevent the diry read
-- so use read commited isolation level that no Tran will see the data before the commit(default)


begin tran

update ResearchProject
set Status = 'Pending'
where id ='P001'

--open tran
-- any other Trans cannot see this dirty data

--implicit tran want to access data the is modfied but not commited will see the old value
--prevent the dirty read
select Status
from ResearchProject
where id ='P001'

--Explain duability 
-- After execute the trans all the data is persitent on SQL
begin try
begin transaction
--1)

  if exists (select 1 from Researcher where id = 'R031') and  exists (select 1 from Grants where id ='G015')
  begin
  --1)
  insert into ResearchProject(Id,Title,StartDate,LeaderId)
values ('P200','new project',getdate(),'R031')

--2)
insert into WorksOn(ResearcherId,ProjectId,JoinDate,HoursPerWeek,Role)
values ('R031','P200',GETDATE(),12,'Leader')

--3)
insert into Funds (GrantId,ProjectId,AllocationDate,AllocationAmount)
values ('G015','P200',GETDATE(),18000)

print ('done sucessfully')
commit

  end

  else
  begin
  rollback tran
  raiserror('Resaercher not exists or Grants doesnot exists',16,1);
  return;

  end


end try 
begin catch

if @@TRANCOUNT >0
begin
 rollback tran
end
else
print ERROR_MESSAGE()


end catch

-- Check project created
SELECT * 
FROM ResearchProject 
WHERE Id = 'P200';

-- Check leader assigned
SELECT * 
FROM WorksOn 
WHERE ProjectId = 'P200';

-- Check funding allocated
SELECT * 
FROM Funds 
WHERE ProjectId = 'P200';

--Q51
--Write the necessary GRANT statements to:
--● Give user 'ResearchManager' full permissions on all tables
--● Give user 'ResearchAssistant' SELECT and INSERT permissions only on Researcher and Publication tables
--● Give user 'DataAnalyst' SELECT permission on all views but no direct table access



GRANT SELECT, INSERT, UPDATE, DELETE
ON SCHEMA::dbo
TO ResearchManager;



GRANT SELECT, INSERT ON Researcher TO ResearchAssistant;
GRANT SELECT, INSERT ON Publication TO ResearchAssistant;

Grant select on ActiveProjectSummary To DataAnalyst;
Grant select on ResearcherPublicationStats To DataAnalyst;


--Q52
--Write REVOKE statements to remove INSERT and UPDATE permissions from user
--'ResearchAssistant' on the Researcher table. Explain the difference between GRANT, REVOKE,
--and DENY.
--the difference between the revoke and  deny 
-- that the revoke of permission from spcific user it it has anther role which has this permission
-- it can use this 

-- but deny same as block it can never use tis permission again 
GRANT  update ON Researcher TO ResearchAssistant;
revoke insert on Researcher from ResearchAssistant;
revoke update on Researcher from ResearcherAssistant;

--Q53
--Compare these two queries for finding researchers who work on project 'P001':
--Which query is likely to perform better and why? What factors influence the optimizer's choice?
SELECT r.*
FROM Researcher r
WHERE r.Id IN (SELECT ResearcherId FROM WorksOn WHERE ProjectId = 'P001')

SELECT r.*
FROM Researcher r
WHERE EXISTS (SELECT 1 FROM WorksOn w WHERE w.ResearcherId = r.Id AND w.ProjectId =
'P001')

-- i think that the second query is better in performance
-- as it cutoff as soon as the result set returned (select 1)
-- donnot need to wait for all the valus to check the id in those values like the query 1
-- if you care about the performance & the good execution plan i think tou should use exists not in key word
-- in => return result set forr all the ids that are in prokect p001
-- in => very bad if the result set will be big 
-- exists => just need one result set and then stop (at first match) (cutoff)
-- exists very good for large result set 
-- factors influence the optimizer's choice:

--if the subquery has nulls it will avoid the in keyword as it not safe and chosses exist as it searches for existence
-- if the subquery return result sets small may behave similarly 
-- if subquery returns large set the better is exists
-- if making indexes in the columns in the subquery the in and existsbe more faster

--Q54
--A query retrieving all projects with their researchers is running

SELECT p.Title, r.FirstName, r.LastName
FROM ResearchProject p LEFT JOIN WorksOn w
ON p.Id = w.ProjectId
LEFT JOIN Researcher r
ON w.ResearcherId = r.Id
WHERE p.Status = 'Active'
ORDER BY p.StartDate DESC

create nonclustered index idx_Researcher_Id
on Researcher (Id)
include(FirstName, LastName);

create nonclustered index idx_WorksOn_ProjectId
on WorksOn (ProjectId)
include (ResearcherId);

create nonclustered index idx_ResearchProject_Status_StartDate
on ResearchProject (Status, StartDate DESC)
include (Id, Title);

--rewrite it 
-- the second left join doesnot matter (we donnot select any thing from works on )


SELECT p.Title, r.FirstName, r.LastName
FROM ResearchProject p
LEFT JOIN WorksOn w ON p.Id = w.ProjectId
INNER JOIN Researcher r ON w.ResearcherId = r.Id
WHERE p.Status = 'Active'
ORDER BY p.StartDate DESC;









--Q55
--You need to regularly retrieve the top 10 most cited publications along with their authors. You
--have four options:
--Option A: Write the query each time it's needed
--Option B: Create a view
--Option C: Create a stored procedure
--Option D: Create an indexed view
--Discuss the pros and cons of each approach. Which would you choose and why? Consider
--factors like performance, maintenance, and data freshness.

--Option A: 
--Pros:
-- it will not need to be store as it not data base object
-- data freshness
--Cons:
-- code duplication every time you need to write execute this query you must write it 
-- it donnot save the excution plan for the query 

--========================
--Option B:
--Pros:
--the view is a named result set it store the meta data and definitions of the table
-- it doesnot store the data in it (result set) -save storage
-- can grantee the security as i can grant permissions on spcific views not the whole table
-- it abscract and simfily the logic instead of select from 2 tables select only from the view
-- centralized logic, i can change in one place

--Cons:
-- it doesnot speed the performance nor decrease it it depend totally on the Query inside it
-- in case of nested views it decrease the performane
--=================================
--Option c:
--Pros:
-- stroed procedure encapsulate a very complex logic
-- it can be used for more secure Apps 
-- it prevents the SQL injection
-- we can use it if we want to validate before selecting
-- can use Transcation with it 
-- the caller just exec the SP without knowing the logic or know the underlying tables
-- the first time in execution it may be solwer then the next times it becomes very fast
-- as it saved the first 3 steps in exceution any query (pasre - optimize meta data - query tree)
-- can grant permissions on it 
-- very good in maintanability all in one place 
-- very good in reusability 

-- cons:
-- i think in our example to use this will be overkill we donnot need  all of these
-- it doesnot cash the result data set just the execution plan 

--===========================================

--option D:
--pros:
-- it is the only view that store the result set 
-- it speed the performance very much as it precalucalted data
-- good for querires with many joins
-- provide a window to deal with the query without know the underlyibg table

--cons:
-- storage cost
-- creating it very restrictive
-- cannot use it min - max - avg
-- cannot use count (*) - must be count_big
-- cannot use left join - right join - outer join 
-- cannot use union - union all 
-- must build it with schema binding 
-- must spcify the names of tables
-- its updatable or maintance under conditions (must affect only one bae table)

-- i think in our case the best solution is the indexed view 


