--1)
--Write a query to display all user display names in uppercase 
--along with the length of their display name.
select UPPER(DisplayName) UpperCaseName,len(DisplayName) LengthOfName
from Users;

--2)
--Write a query to show all posts with their titles and calculate 
--how many days have passed since each post was created.
select Title,DATEDIFF(DAY,CreationDate,getDate()) NumOfDays
from
Posts

--3)
--Write a query to count the total number of posts for each user.
--Display the OwnerUserId and the count of their posts.
--Only include users who have created posts.
select OwnerUserId,Count(*) NumOfPostsPerUser
from Posts
group by OwnerUserId
having Count(*)>0

--4)
-- Write a query to find users whose reputation is greater than 
--the average reputation of all users. Display their DisplayName 
 --and Reputation. Use a subquery in the WHERE clause
 select DisplayName,Reputation
 from Users
 where Reputation > (select Avg(Reputation) from Users)
 --was wrong should do SUBSTRING(isnull(Title,'')),1,50)
 --5)
 --Write a query to display each post title along with the first 
--50 characters of the title. If the title is NULL, replace it 
--with 'No Title'. Use SUBSTRING and ISNULL functions.
select SUBSTRING(Title,1,50) First50CharactersFromTitle, isnull(Title,'No Title') ReplacedTitle
from Posts;
