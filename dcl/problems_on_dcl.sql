--Q2
--Create a SQL login, database user, and grant them SELECT
--permission on the Users table only.

create login jasmine with password ='123456'
create user jasmine for login jasmine
grant  select on Users to jasmine 


--Q3
--Create a database role called "DataAnalysts" and grant it:
-- SELECT permission on all tables
-- EXECUTE permission on all stored procedures
-- Then add a user to this role.

create role DataAnalysts
grant select on schema::dbo to DataAnalysts
grant execute on schema::dbo  to DataAnalysts
Alter role DataAnalysts Add member jasmine

--Q4
--Write SQL to REVOKE INSERT and UPDATE permissions from a role
--called "DataEntry" on the Posts table.

create role DataEntry
grant select,update on schema::dbo to DataEntry
revoke select,update on schema::dbo from DataEntry


--Q5
--Write SQL to DENY DELETE permission on the Users table to a
--specific user, even if they have it through a role.
--Explain why DENY is used instead of REVOKE

deny delete on Users to jasmine 
--using deny as it blocked jasmine even if it has another permission 
