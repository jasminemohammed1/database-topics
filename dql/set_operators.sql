--1)
--Retrieve a list of users who meet at least one of these criteria:
--1. Reputation greater than 8000
--2. Created more than 15 posts
--Display UserId, DisplayName, and Reputation.
--Ensure that each user appears only once in the results.
select Id ,DisplayName,Reputation
from Users
where Reputation>800
union
select OwnerUserId,u.DisplayName,u.Reputation
from Posts p inner join Users u
on p.OwnerUserId=u.Id
group by p.OwnerUserId,u.DisplayName,u.Reputation
having count(*) >15;

--2)
--Find users who satisfy BOTH of these conditions simultaneously:
--1. Have reputation greater than 3000
--2. Have earned at least 5 badges
--Display UserId, DisplayName, and Reputation.
select id,DisplayName,Reputation
from Users
where Reputation>3000
intersect
select u.Id,u.DisplayName,u.Reputation
from Badges b inner join Users u
on b.UserId=u.Id
group by u.Id,u.DisplayName,u.Reputation
having count(*) >= 5

--3)
--Identify posts that have a score greater than 20 but have never received any comments
--Display PostId, Title, and Score.

select Id,Title,Score
from Posts
where Score >20
except
select p.Id,p.Title,p.Score
from Comments c inner join Posts p
on c.PostId=p.Id
