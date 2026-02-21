
create database HotelReservation;
use HotelReservation;


 
create table Hotel(
HotelId int primary key,
[Name] varchar(20),
[Address] varchar(30),
StarRating int ,
ContactNumber char(12),
ManagerId int ,
)

create table Staff(
StaffId int primary key,
FullName varchar(20),
Position varchar(20),
Salary decimal(10,2),
HotelId int 
);

--Add FK constraint on Hotel table on ManagerID
Alter table Hotel
Add Constraint FK_ManagerID foreign key (ManagerID) references Staff(StaffId);

-- Add unique constraint on ManagerID
Alter Table Hotel 
Add Constraint UQ_ManagerID unique (ManagerID);

--Add FK constraint on Staff on HotelID
Alter table Staff
Add Constraint FK_HotelID foreign key (HotelID) references Hotel(HotelID);

-- Add Check constraint on Staff on Position
Alter table Staff
Add constraint CK_Position check (Position in ('cleaner','manager','receptionist'));

create table Rooms(
RoomNum int primary key,
[type] varchar(20) check( [type] in ('single','double','suite')),
Capacity int ,
DailyRate int ,
[Availability] bit ,
HotelId int references Hotel(HotelId)
);

create table Room_Amentities(
RoomNum int references Rooms(RoomNum) ,
Amenty varchar(20) check (Amenty in ('seeview','balcony','kitchen')),
Primary key (RoomNum,Amenty)
);

create table Reservation (
ReservationId int primary key,
TotalPrice decimal (10,2),
NumberOfAdults int,
NumberOfChildren int,
[Status] varchar(20) check ([Status] in ('confirmed','checkedin','canceled','compeleted')),
CheckInDate Date,
CheckOutDate Date,
);

create table Room_Reservation(
ReservationId int references Reservation (ReservationId),
RoomId int references Rooms (RoomNum),
Primary key (ReservationId,RoomID),

)

create table Payment (
PayId int primary key,
Method varchar(20) check (Method in ('cash','card','online')) not null,
PaymentDate Date,
Amount decimal (10,2) not null,
ConfirmationNumber int not null,

)

create table Payment_Reservation (
PayId int references Payment(PayId),
ReservationId int  references Reservation (ReservationId),
primary key (PayId,ReservationId)

)

create table Guest(
GuestId int primary key,
FullName varchar(20),
Nationality varchar(20) not null,
DateOfBirth Date,
PassportNumber int
)

create table Gues_Contact_Details(
GuestId int references Guest (GuestId),
ContactDetail varchar(40),
Primary key (GuestId,ContactDetail)
)

create table Guest_Reservation(
GuestId int references Guest (GuestId),
ReservationId int references Reservation(ReservationId),
primary key (GuestId,ReservationId)
);

create table [Service](
ServiceId int Primary key,
RequestDate Date not null,
Charge decimal (10,2),
ServiceName Varchar(20),
StaffId int references Staff(StaffId)
)

create table Service_Reservation(
ReservationId int references Reservation(ReservationId),
ServiceId int references [Service](ServiceId),
primary key (ServiceId,ReservationId)

);


go
create Schema Finance
go
Alter Schema Finance transfer Payment;
Alter Schema Finance transfer  Payment_Reservation;
Alter Schema Finance transfer Reservation;
Alter Schema Finance transfer Guest_Reservation;
Alter Schema Finance transfer [Service];
Alter Schema Finance transfer Service_Reservation;
Alter Schema Finance transfer Room_Reservation;
go
create schema Resources
go

Alter Schema Resources transfer Staff;
Alter Schema Resources Transfer Rooms;
Alter Schema Resources Transfer Room_Amentities;
Alter Schema Resources Transfer Guest;
Alter Schema Resources Transfer Gues_Contact_Details;

--simple insert
insert into Resources.Guest(GuestId,FullName,Nationality,PassportNumber,DateOfBirth)
values (1,'Mohamed Ashraf','Eygpt',1234567890,'2005-12-17')

--row constructor insert 
insert into Resources.Guest(GuestId,FullName,Nationality,PassportNumber,DateOfBirth)
values (2,'jasmine mohamed','Eygpt',123456789,'2005-4-17'),
(3,'alaa mostafa','Eygpt',23456789,'2005-1-1')

-- insert into staff
insert into Resources.Staff (StaffId,Salary)
values (1,4000),
(2,5000)
--insert into hotel
insert into Hotel (HotelId,[Name],ManagerId)
values (1,'Cairo Hotel',1),
(2,'Alex Hotel',2)

--insert into rooms
insert into Resources.Rooms(RoomNum,[type],DailyRate)
values (1,'single',5),
(2,'suite',7),
(3,'double',10),
(4,'suite',1)

-- Increase DailyRate by 15% for all suites
update Resources.Rooms
set DailyRate+=0.15*DailyRate
where [type]='suite';


select * from Resources.Rooms

--insert into reservation 
insert into Finance.Reservation(ReservationId,CheckInDate,CheckOutDate)
values (1,'2025-4-1','2025-4-20'),
(2,'2025-7-1','2025-7-30');

--update reservation status
update Finance.Reservation
set Status = case 
when CheckOutDate<GETDATE() then 'completed'
when CheckInDate>GETDATE() then 'upcoming'
else 'active'
end

-- insert into reservation guest 
insert into Finance.Guest_Reservation(GuestId,ReservationId)
values (1,1),
(2,1),
(3,1)

-- Delete Reservation_Guest for a reservation
delete from Finance.Guest_Reservation where GuestId=1 and ReservationId=1

update Resources.Staff
set Position='manager' , FullName= 'Ahmed Mahmoud '
where StaffId =1

update Resources.Staff
set Position='manager' , FullName= 'mohamed nabil'
where StaffId =2

create table #StaffUpdates(
Staffid int primary key,
FullName varchar(20),
Position varchar(20),
Salary decimal (10,2)
)
insert into #StaffUpdates values (1,'Ahmed Mahmoud','cleaner',100000),
(2,'jasmine mohamed','manager',1234567),
(10,'Amir Ahmed','manager',180)

merge into Resources.Staff As Target 
using #StaffUpdates As Source 
on Target.Staffid=Source.Staffid
when matched then 
update set Target.Salary=Source.Salary,
Target.Position=Source.Position

when not matched by Target then 
insert  (Staffid ,FullName,Position,Salary)
values (Source.StaffId,Source.FullName,Source.Position,Source.Salary)

when not matched by source then 
delete;


