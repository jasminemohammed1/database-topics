--6)
--Write a query to calculate the total score and average score 
--for each PostTypeId. Also show the count of posts for each type.
 --Only include post types that have more than 100 posts.
 select Sum(Score) TotalScorePerType,AVG(Score) AVGScorePerType,Count(*) NumOfPostsPerType
 from Posts
 group by PostTypeId
 having Count(*)>100

 --7)
 --Write a query to show each user's DisplayName along with 
 --the total number of badges they have earned. Use a subquery 
--in the SELECT clause to count badges for each user.

select DisplayName,(Select Count(*) from Badges where UserId=Users.Id) TotalNumOfBadgesPerUser
from Users

--8)

 --Write a query to find all posts where the title contains the word 'SQL'. 
 --Display the title, score, and format the CreationDate as 'Mon DD, YYYY'. 
 --Use CHARINDEX and FORMAT functions.
 -- was wrong should be 
 --correct one
 select Title,Score,FORMAT(CreationDate,'MMM dd, YYYY')
 from Posts where CHARINDEX('SQL',Title)>0;

 select Title,CHARINDEX('SQL',Title) StartIndexForSQL,Score,FORMAT(CreationDate,'ddd dd, yyyy') FormattedDate
 from Posts
 where Title like'%SQL%'


 --9)
 --Write a query to group comments by PostId and calculate:
--Total number of comments
-- Sum of comment scores
-- Average comment score
 --Only show posts that have more than 5 comments.
 select count(*) TotalNumOfComments,Sum(Score) SumOfCommentScore,AVG(Score) AVgCommentScore
 from 
 Comments
 group by 
 PostId
 having count(*)>5

 --10)
 --Write a query to find all users whose location is not NULL.
 --Display their DisplayName, Location, and calculate their 
 --reputation level using IIF: 'High' if reputation > 5000, 
 --otherwise 'Normal
 select DisplayName,Location,IIf(Reputation>5000,'High','Normal') ReputationLevel
 from Users
 where Location is not null

 --11)
 --Write a query using a derived table (subquery in FROM) to:
 -- First, calculate total posts and average score per user
 --Then, join with Users table to show DisplayName
 --Only include users with more than 3 posts
 --The derived table must have an alias.
 select DisplayName,DerivedTable.AVgScore,DerivedTable.TotalPosts
 from (
 select OwnerUserId,count(*) TotalPosts,Avg(Score) AVgScore 
 from Posts
 group by OwnerUserId
 having count(*)>3

 ) AS DerivedTable
 inner join Users
 on Users.Id=DerivedTable.OwnerUserId

 --12)
 --Write a query to group badges by UserId and badge Name.
--Count how many times each user earned each specific badge.
 --Display UserId, badge Name, and the count.
 --Only show combinations where a user earned the same badge 
 --more than once

 select UserId,Name as BadegeName,count(*) NumberOfTimes 
 from Badges
 group by UserId,Name
 having Count(*) > 1

 --13)
 --Write a query to display user information along with their 
-- account age in years. Use DATEDIFF to calculate years between 
 --CreationDate and current date. Round the result to 2 decimal places.
 --Also show the absolute value of their DownVotes.

 select Round(DATEDIFF(YEAR,CreationDate,GetDate()),2) AccountAgeInYears,ABS(DownVotes) AbsoluteValueOfTheirDownVotes
 from Users

 --14)
 --Write a complex query that:
 --.Uses a derived table to calculate comment statistics per post
 --.Joins with Posts and Users tables
 --.Shows: Post Title, Author Name, Author Reputation, 
 -- Comment Count, and Total Comment Score
--Filters to only show posts with more than 3 comments 
  --and post score greater than 10
-- Uses COALESCE to replace NULL author names with 'Anonymous'
--the correct one is 
SELECT
    p.Title AS PostTitle,
    COALESCE(u.DisplayName, 'Anonymous') AS AuthorName,
    u.Reputation AS AuthorReputation,
    cs.CommentCount,
    cs.TotalCommentScore
FROM (
    SELECT
        PostId,
        COUNT(*) AS CommentCount,
        SUM(Score) AS TotalCommentScore
    FROM Comments
    GROUP BY PostId
) cs
INNER JOIN Posts p
    ON cs.PostId = p.Id
LEFT JOIN Users u
    ON p.OwnerUserId = u.Id
WHERE
    cs.CommentCount > 3
    AND p.Score > 10;

select P.Title,Coalesce(U.DisplayName,'Anonymous') AuthorName,U.Reputation As AuthorReputation,DerivedTable.TotalCommentScore,DerivedTable.CommentCount

from (
select PostId,Count(*) As CommentCount,Sum(Score) As TotalCommentScore
from Comments
group by PostId
having Count(*)>3 and Sum(Score)>10

)As DerivedTable
inner join Posts P
on P.Id=DerivedTable.PostId
inner join Users U
on U.Id=P.OwnerUserId
