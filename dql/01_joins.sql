-- 1) i will use on delete cascade, as the hotel is deleted with its rooms 
Alter table Resources.Rooms
Add constraint FK_Rooms_Hotel foreign key (HotelId) references
Hotel(HotelId) on delete cascade;

--) i will use on delete cascade as the room no longer available so its amenties also will be deleted
--as i missed to create Amenties table 
create table Amenties(
RoomNum int primary key ,
Amentiy varchar(20),
)
Alter table Amenties
add constraint Fk_Amenties_Rooms foreign key (RoomNum) references Resources.Rooms(RoomNum) on delete cascade

--3) if the staff id change in service staff id must change also so i will use on update cascade

Alter table Finance.Service
drop constraint FK__Service__StaffId__59063A47

Alter table Finance.Service
add constraint FK_Services_Staff foreign key (StaffId) references Resources.Staff(StaffId) on update cascade
-- joins
--1)
select U.DisplayName,U.Age,PT.Type
from Users U cross join PostTypes PT
--2)
select U.DisplayName,U.Reputation,P.Title
from Users U inner join Posts P
on U.Id=P.OwnerUserId

--3)
select C.Score,C.Text,P.Title
from Posts P inner join Comments C
on P.Id=C.PostId

--4)
select U.DisplayName,B.Name As [Badge Name],B.Date As [Badge Date]
from Users U left join Badges B
on U.id=B.UserId

--5)
--was wrong i donnot need to say post title not null in where
select P.Title ,P.Score As [Post Score],C.Text As [comment text],C.Score As [Comment score]
from Posts P left  outer join Comments C
on P.Id=C.PostId 



--6)
select V.VoteTypeId,V.CreationDate,P.Title
from Posts P right outer join Votes V
on P.Id=V.PostId

--7)
--was wrong
select Answer.Title As [Answer Title],Answer.Score AS [Answer Score],Quest.Title AS[ Question Title],Quest.Score As [Question Score]
from Posts Answer inner join Posts Quest
on Answer.ParentId=Quest.Id


--8)
--was wrong and corrected
select p.Title as [original post title],
p2.Title as [related post title],
pl.LinkTypeId
from PostLinks pl inner join 
Posts p
on pl.PostId=p.Id
inner join 
Posts p2
on pl.RelatedPostId=p2.Id

--9)
select P.Title,U.DisplayName,U.Reputation,PTs.Type
from Posts P inner join Users U
on P.OwnerUserId=U.Id
inner join PostTypes PTs
on P.PostTypeId=PTs.Id

--10)
--was wrong all inner
select P.Title,U.DisplayName As [Author name],commentors.DisplayName As[ Commentor Name]
from Posts P inner join Users U 
on P.OwnerUserId=U.Id 
inner join Comments C
on P.Id=C.PostId
inner join Users commentors
on C.UserId=commentors.Id




--11)
--was wrong
--said all votes to use left join between votes and posts instead of inner 
select P.Title,V.BountyAmount,V.CreationDate,VT.Name
from Votes V  left join Posts P
on V.PostId =P.Id
inner join
VoteTypes VT
on V.VoteTypeId=VT.Id
 
 --12)
 --was wrong
 select U.DisplayName As [User Name],P.Title,C.Text As [Comment text]
 from 
 Users U left outer join Posts P
 on U.Id=P.OwnerUserId
 left outer join 
 Comments C
 on U.Id=C.UserId
 -- the correct c.postid=p.id (comment on those posts)

 --13)
 select P.Title,U.DisplayName,B.Name As [Badget Name],PT.Type
 from Posts P inner join 
 (Users U left outer join Badges B
 on U.Id=B.UserId)
 on P.OwnerUserId=U.Id
 inner join PostTypes PT
 on P.PostTypeId=PT.id

 --14)
 --wrong i missed the where in the end
Select P.Title,auth.DisplayName As [Author Name],auth.Reputation As [ Author repotation ],
C.Text As [Comment text],commentors.DisplayName As [Commmentors Name],
VT.Name [Vote Type], V.CreationDate
from Posts P inner join Users auth
on P.OwnerUserId=auth.Id
left join 
(Votes V inner join VoteTypes VT
on V.VoteTypeId=VT.Id)
on P.Id=V.PostId
left join 
(Comments C inner join Users commentors
on C.UserId=commentors.Id)
on P.Id=C.PostId
where p.Score >5

select 
from Posts p inner join Users u
on p.OwnerUserId=u.Id
left join votes v 
on p.id=v.PostId
left join VoteTypes vt
on v.VoteTypeId=vt.Id
left join 
Comments c
on p.Id=c.PostId
left join Users coment
on c.UserId=coment.Id


