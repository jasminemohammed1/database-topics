create database OnlineRetailDB;
use OnlineRetailDB;

create table Supplier (
SupplierId int primary key,
[Address] varchar(20),
Email varchar(20) not null,
ContactNumber Varchar(12) not null,
[Name] varchar(20),
Countery varchar(20),
)
Create Table Category (
CategoryId int Primary Key,
[Description] Varchar(30),
[Name] Varchar(10) check ([Name] in ('clothing','electroncics','Home Appliance')),
MainCategoryId int references Category(CategoryId)

)
create table [Product](
ProductId int primary key,
UnitPrice Decimal (10,2) not null,
[Description] varchar(20),
AddedDate Date,
[Name] varchar(20),
StockQuantity int,
CategoryId int references Category (CategoryId)

)

create table Product_Supplier(
ProductId int references [Product] (ProductId),
SupplierId int references Supplier(SupplierId),
Primary key (ProductId,SupplierId)

)

Create table Stock_Transaction(
TransactionId int primary key,
[type] varchar(30),
QuantityCharge decimal (10,6),
TransactionDate date,
ProductId int references [Product](ProductId),
)

create table Customer(
CustomerId int primary key,
Email varchar(20) not null,
Phone Varchar(14) not null,
FullName varchar(20) ,
ShippingAddress varchar(20),
RegistrationDate date
)

create table Review(
ReviewId int primary key,
Rating int not null,
ReviewDate date not null,
Comment varchar(40),
ProductId int references [Product](ProductId),
CustomerId int references Customer(CustomerId)
)

create table [Order](
OrderId int primary key,
OrderStatus varchar(20) check (OrderStatus in (
'Pending','Shipped','Delivered','Canceled')),
TotalAmount decimal (12,5) not null,
OrderDate date,
CustomerId int references Customer(CustomerId)
)

Create table OrderItem(
OrderItemId int primary key,
UnitPrice Decimal(10,2) not null,
Quantity int not null,
OrderId int references [Order](OrderId),
ProductId int references [Product](ProductId),

)
create table Shipment(
ShipmentId int identity  primary key,
ShipmentDate date not null,
ShipmentStatus varchar(10),
TakingNumber int ,
CarrierName varchar(10),
DeliveryDate date not null,
OrderId int references [Order](OrderId)

)

create table Payment(
PaymentId int identity Primary key,
PaymentDate date,
Amount decimal (10,2) not null,
[Status] varchar(10),
Mathod varchar(20) check (Mathod in ('creditcard','wallet','bank transfer'))

)

create table Oder_Payment(
OrderId int references [Order](OrderId),
PaymentId int references Payment(PaymentId),
primary key (OrderId,PaymentId)

)
go
create schema Finance 
go

Alter Schema Finance transfer Payment;
Alter Schema Finance transfer Oder_Payment;

go
create schema Market 
go

Alter Schema Market transfer [Order] ;
Alter Schema Market transfer OrderItem ;
Alter Schema Market transfer Shipment ;
Alter Schema Market transfer Review ;

go
create schema Products 
go

Alter Schema Products transfer [Product] ;
Alter Schema Products transfer Category ;
Alter Schema Products transfer Stock_Transaction ;

go
create schema Suppliers 
go
Alter Schema Suppliers transfer Supplier ;
 Alter Schema Suppliers transfer Product_Supplier;


 --insert into Customer in dbo 
 insert into Customer (CustomerId,FullName,Phone,Email,ShippingAddress,RegistrationDate)
 values (1,'menna mohamed','01032792816','menna@gmail.com','Obour city','2025-12-8')
 -- see updates
 select * from Customer

 -- insert 3 supppliers int Supplier
 insert into Suppliers.Supplier (SupplierId,[Name],ContactNumber,Countery,Email,[Address])
 values (1,'Jasmine Mohamed','01032792818','cairo','Jasmine@gmail.com','Obour city'),
 (2,'Alaa Mostafa','011223456','cairo','Alaa@gmail.com','Dokii city'),
 (3,'Nada Amin','0124667788','cairo','Nada@gmail,com','6 October')

 -- show updates
 select * from Suppliers.Supplier

-- update column name  data type to fit the data in it 

 Alter table Products.Category
 Alter column  [Name] varchar(30)

 -- insert into 2 rows in Category in Products
 insert into Products.Category (CategoryId,[Description],[Name],MainCategoryId)
 values (1,'Trendy Clothes','clothing',1),
 (2,'Useful Electronics','electroncics',2)

 -- insert 1 product in Products 
 insert into Products.[Product] (ProductId,[Name],UnitPrice)
 values (1,'Black Jacket',1000);
 
 -- insert data in stock transaction in Products 
 insert into Products.Stock_Transaction (TransactionId,TransactionDate,QuantityCharge,[type])
 values (1,'2022-12-1',1000,'in'),
 (2,'2025-4-17',2000,'out'),
 (3,'2020-12-17',5000,'in')

--create ArchivedStock (TranId, ProductId, QuantityChange,TranDate) before 2023
create table ArchivedStock (
TranId int primary key,
ProductId int ,
Quantitychange decimal(10,4),
TranDate date,
)

insert into ArchivedStock(TranId,Quantitychange,TranDate,ProductId)
select TransactionId,QuantityCharge,TransactionDate,ProductId 
from Products.Stock_Transaction
where TransactionDate < '2023-1-1'

--insert into Junction table product-supplier
insert into Suppliers.Product_Supplier(ProductId,SupplierId)
values (1,2),(1,3)

-- create local temp table #CustomerOrders
create table #CustomerOrders(
OrderId int ,
CustomerId int primary key ,
TotalAmount decimal (10,2),
)

Alter table #CustomerOrders
Add constraint FK_Order foreign key(OrderId) references Market.[Order](OrderId)

Alter table #CustomerOrders
Add constraint FK_Customer foreign key(CustomerId) references Customer(CustomerId)

-- add records in orders before add data in #CustomerOrders
insert into Market.[Order]
(OrderId,CustomerId,TotalAmount)
values (1,1,5000),
(2,1,10000)
insert into Market.[Order]
(OrderId,CustomerId,TotalAmount)
values (3,1,70000)

-- add records in #CustomerOrders
insert into #CustomerOrders (CustomerId,OrderId,TotalAmount)
select OrderId,CustomerId,TotalAmount from Market.[Order]
where TotalAmount>5000

-- see updates
select * from #CustomerOrders 

-- create ##TopRatedProducts with productid,rating
create table ##TopRating (
ProductId int references Products.[Product](ProductId),
Rating int,
Primary key(ProductId)
)

-- add data in review table and products 
insert into Products.[Product](ProductId,[Name],CategoryId,UnitPrice)
values (2,'Blue Jacket',1,1000)

insert into Market.Review (ReviewId,ProductId,Rating,ReviewDate)
values (1,2,8,'2025-6-1'),
(2,1,6,'2025-4-11')

-- add data into ##topRating
insert into ##TopRating(ProductId,Rating)
select ProductId,Rating from Market.Review
where Rating >=4.5

-- see updates
select * from ##TopRating
-- add products under  their unit price <100

insert into Products.[Product](ProductId,UnitPrice,[Name],CategoryId)
values (3,99,'Skirt',1),
(4,40,'ring',1)
-- select before update 
select * from Products.[Product]

update Products.[Product]
set UnitPrice+=UnitPrice*0.1
where UnitPrice <100

-- select after update
select * from Products.[Product]

--insert data in payment 
insert into Finance.Payment (PaymentDate,Amount)
values ('2025-12-4',550),
('2025-4-17',600),
('2025-4-17',400)

update Finance.Payment
set Status=case 
When Amount>500 then 'Premium'
else 'Standard'
end;

-- delete a review by id 
delete from Market.Review where ReviewId=1;

-- add orders with status cancelled 
insert into Market.[Order] (OrderId,CustomerId,OrderStatus,OrderDate,TotalAmount)
values (4,1,'canceled','2024-12-1',10000),
(5,1,'pending','2023-4-12',4000)

-- delete order with status = canceled
delete from Market.[Order] where OrderStatus='canceled'

--insert into OrderItem
insert into Market.OrderItem(OrderItemId,OrderId,UnitPrice,Quantity)
values(1,1,60,1),
(2,2,70,2),
(3,3,80,3)
--insert another orderitem with orderid =1
insert into Market.OrderItem(OrderItemId,OrderId,UnitPrice,Quantity)
values(4,1,60,4)

--  Delete OrderItems for a given OrderId

delete from Market.OrderItem where OrderId=1
--merge 
create table #ProductsUpdate(
ProductId int primary key,
[Name] varchar(20),
UnitPrice decimal (10,2),
StockQuantity int 
)

insert into #ProductsUpdate values (1,'jeans',170,4),
(2,'hodey',190,10),
(10,'laptop',1000000,10);

merge into Products.[Product] As Target
using #ProductsUpdate As Source 
on Target.ProductId=Source.ProductId
when matched then
  update set 
 Target.[Name]=Source.[Name],
 Target.UnitPrice=Source.UnitPrice,
 Target.StockQuantity =Source.StockQuantity
when not Matched by target then 
insert (ProductId,[Name],UnitPrice,StockQuantity) values (
source.ProductId,source.[Name],source.UnitPrice,Source.StockQuantity)

when not Matched by source then 
delete;

