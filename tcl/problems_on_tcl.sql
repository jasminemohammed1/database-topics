CREATE TABLE AccountBalance (
AccountId INT PRIMARY KEY,
AccountName VARCHAR(100),
Balance DECIMAL(18,2) CHECK (Balance >= 0),
LastUpdated DATETIME DEFAULT GETDATE()
);

CREATE TABLE TransferHistory (
TransferId INT IDENTITY(1,1) PRIMARY KEY,
FromAccountId INT,
ToAccountId INT,
Amount DECIMAL(18,2),
TransferDate DATETIME DEFAULT GETDATE(),
Status VARCHAR(20),
ErrorMessage VARCHAR(500)
);
GO

CREATE TABLE AuditTrail (
AuditId INT IDENTITY(1,1) PRIMARY KEY,
TableName VARCHAR(100),
Operation VARCHAR(50),
RecordId INT,
OldValue VARCHAR(500),
NewValue VARCHAR(500),
AuditDate DATETIME DEFAULT GETDATE(),
UserName VARCHAR(100) DEFAULT SYSTEM_USER)

INSERT INTO AccountBalance (AccountId, AccountName, Balance)
VALUES
(101, 'Checking Account', 10000.00),
(102, 'Savings Account', 25000.00),
(103, 'Investment Account', 50000.00),
(104, 'Emergency Fund', 15000.00);

--Q1
--Write a simple transaction that transfers $500 from Account 101
--to Account 102.
--Use BEGIN TRANSACTION and COMMIT TRANSACTION.
--Display the balances before and after the transfer.


--Q2
--Write a transaction that attempts to transfer $1000 from Account 101
--to Account 102, but then rolls it back using ROLLBACK TRANSACTION.
--Verify that the balances remain unchanged..

select Balance As BalanceAccount101BeforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102BeforeTransfer from AccountBalance where AccountId=102

begin Tran
--oper1
update AccountBalance
set Balance-=1000
where AccountId=101

--oper2
update AccountBalance
set Balance+=1000
where AccountId=102

rollback;

select Balance As BalanceAccount101BeforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102BeforeTransfer from AccountBalance where AccountId=102

--Q3
--Write a transaction that checks if Account 101 has sufficient
--balance before transferring $2000 to Account 102.
--If insufficient, rollback the transaction.
--If sufficient, commit the transaction.

begin tran
declare @balance decimal(18,2)
select @balance=Balance
from AccountBalance where AccountId=101
if @balance<2000
begin 
rollback
end
else 
begin
update AccountBalance
set Balance-=2000
where AccountId=101

update AccountBalance
set Balance+=2000
where AccountId=102
commit
end

--Q4
--Write a transaction using TRY...CATCH that transfers money
--from Account 101 to Account 102. If any error occurs,
--rollback the transaction and display the error message.

select Balance As BalanceAccount101BeforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102BeforeTransfer from AccountBalance where AccountId=102

begin try
 begin tran
 --oper1
 update AccountBalance
 set Balance = Balance - 10 
 where AccountId = 101

 --oper2
 update AccountBalance
 set Balance = Balance + 10
 where AccountId = 102 

 commit tran
end try 
begin catch 
  if @@TRANCOUNT>0
  begin
   rollback 
  end
  print (Error_message()+' At Line: ' + cast(Error_Line() As Varchar(100)))
end catch

select Balance As BalanceAccount101AfterTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102AfterTransfer from AccountBalance where AccountId=102

--Q5
--Write a transaction that uses SAVE TRANSACTION to create
--a savepoint after the first update. Then perform a second
--update and rollback to the savepoint if an error occurs.
select Balance As BalanceAccount101BeforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102BeforeTransfer from AccountBalance where AccountId=102

begin Try
Begin tran
--first update 
update AccountBalance
set Balance -=10
where AccountId =101
SAVE TRANSACTION FistUpdate;

update AccountBalance
set Balance += 10
where AccountId = 102
SAVE TRANSACTION SecondUpdate;
commit
end Try

begin catch 
if @@TRANCOUNT>0
begin 
rollback TRANSACTION FirstUpdate
end
end catch 


select Balance As BalanceAccount101AfterTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102AfterTransfer from AccountBalance where AccountId=102

--Q6
--Write a transaction with nested BEGIN TRANSACTION statements.
--Display @@TRANCOUNT at each level to demonstrate how it changes.
select Balance As BalanceAccount101beforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102beforeTransfer from AccountBalance where AccountId=102
select Balance As BalanceAccount103beforeTransfer from AccountBalance where AccountId=103


print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));

begin try 
begin Tran
print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
update AccountBalance
set Balance -= 10 
where AccountId=101

update AccountBalance
set Balance += 10 
where AccountId=102

print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
 begin tran
 print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
 update AccountBalance
 set Balance -= 10 
 where AccountId=102

 update AccountBalance
 set Balance += 10 
 where AccountId=103

 print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
 commit 
  print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
  commit 
   print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));

end try
begin catch 
if @@TRANCOUNT>0
begin 
rollback 
print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
end
end catch

select Balance As BalanceAccount101AfterTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102AfterTransfer from AccountBalance where AccountId=102
select Balance As BalanceAccount103AfterTransfer from AccountBalance where AccountId=103


--Q7
--Demonstrate ATOMICITY by writing a transaction that performs
--multiple updates.
--Show that if one fails, all are rolled back.

select Balance As BalanceAccount101beforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102beforeTransfer from AccountBalance where AccountId=102
select Balance As BalanceAccount103beforeTransfer from AccountBalance where AccountId=103
go
begin try 
 declare @balance decimal(18,2)
 begin tran 
 update AccountBalance
 set Balance -= 500
 where AccountId = 101 ;

 update AccountBalance
 set Balance+= 300
 where AccountId =102;

 update AccountBalance
 set Balance+=200
 where AccountId=103

 select @balance=Balance
 from AccountBalance
 where AccountId =101
 
 if @balance<0
 begin
  rollback
  return 
  end 

  commit 
end try
begin catch 
if @@TRANCOUNT>0
begin 
 rollback 
end
end catch

select Balance As BalanceAccount101AfterTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102AfterTransfer from AccountBalance where AccountId=102
select Balance As BalanceAccount103AfterTransfer from AccountBalance where AccountId=103


--Q8
--Demonstrate CONSISTENCY by writing a transaction that ensures
--the total balance across all accounts remains constant.
--Calculate total before and after transfer.
declare @BalanceAccount1 decimal(18,2)
declare @BalanceAccount2 decimal(18,2)

select @BalanceAccount1=Balance
from AccountBalance e where AccountId=101 

select @BalanceAccount2=Balance
from AccountBalance e where AccountId=102 

select @BalanceAccount1 + @BalanceAccount2 As TotalAmountBeforeTransfer
--3499$
go
begin try 

begin tran 
declare @BalanceAccount1 decimal(18,2)
declare @BalanceAccount2 decimal(18,2)
--oper1
update AccountBalance
set Balance -= 200
where AccountId = 101

update AccountBalance
set Balance += 200
where AccountId = 102

 select @BalanceAccount1=Balance
 from AccountBalance where AccountId=101

 if @BalanceAccount1 <0
 begin 
 rollback
  return 
 end
 commit 
end try 
begin catch 
if @@TRANCOUNT>0
begin 
rollback
end
end catch 
go

declare @BalanceAccount1 decimal(18,2)
declare @BalanceAccount2 decimal(18,2)

select @BalanceAccount1=Balance
from AccountBalance e where AccountId=101 

select @BalanceAccount2=Balance
from AccountBalance e where AccountId=102 

select @BalanceAccount1 + @BalanceAccount2 As TotalAmountAfterTransfer
--3499$

--Q9
--Demonstrate ISOLATION by setting different isolation levels
--and explaining their effects. Use READ UNCOMMITTED, READ
--COMMITTED, and SERIALIZABLE.

set transaction isolation level read uncommitted
begin tran 
 update AccountBalance
 set Balance+=10
 where AccountId=104
 commit 
 -- here any concurrent transaction need to select the updated column will read even if it has not commited yet 

 set transaction isolation level read committed 
 begin tran 
 update AccountBalance
 set Balance+=10
 where AccountId=104
 commit 
 -- here any concurrent transcation wants to select the updated column will wait or read the old value until it commits 


 set transaction isolation level serializable
 begin tran
 update AccountBalance
 set Balance+=10
 where AccountId=104
 commit 

 -- here any any concurrent transcation needs to access the updated column will block until t1 finish 

 --Q10
 --Demonstrate DURABILITY by committing a transaction and
--explaining that the changes will persist even after
--system restart or failure.

select Balance As BalanceAccount101BeforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102BeforeTransfer from AccountBalance where AccountId=102

Begin Tran 
--oper1
update AccountBalance
set Balance-=500
where AccountId=101

--oper2
update AccountBalance
set Balance+=500
where AccountId=102

commit tran

select Balance As BalanceAccount101AfterTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102AfterTransfer from AccountBalance where AccountId=102

--here after the commit i cannot undo so the data saved permently

--Q11
--Write a stored procedure that uses transactions to transfer
-- money between two accounts. Include parameter validation,
-- error handling, and proper transaction management.
go
create or alter proc TransferMoney
@FromAccountId int,
@ToAccountId int,
@Amount decimal(18,2)
As
Begin
Begin try 
begin tran
 if @Amount<0 or @ToAccountId=@FromAccountId
 begin 
 raiserror('cannot transfer money with the giving peramters',16,1)
 end
update AccountBalance
set Balance= Balance-@Amount
where  AccountId= @FromAccountId

update AccountBalance
set Balance=Balance+@Amount
where  AccountId= @ToAccountId
commit 
end try 
begin catch
if @@TRANCOUNT>0
 rollback 
 print (Error_message()+ 'at '+cast(Error_Line() as varchar(20)))
end catch
End

--Q12
--Write a transaction that uses multiple savepoints to handle
-- a multi-step operation. If step 2 fails, rollback to savepoint 1.
-- If step 3 fails, rollback to savepoint 2.

begin tran

update AccountBalance
set Balance-=600
where AccountId=101
SAVE TRANSACTION point1

update AccountBalance
set Balance+=300
where AccountId=102
SAVE TRANSACTION point2


update AccountBalance
set Balance+=300
where AccountId=103
SAVE TRANSACTION point3

declare @Balance decimal(18,2)
select @Balance=Balance from AccountBalance where AccountId=101

 if @Balance<0
 begin 
 rollback TRANSACTion point2;
 update AccountBalance
 set Balance +=300
 where AccountId=101;

 select @Balance=Balance
 from AccountBalance
 where AccountId=101

 if @Balance<0
 Rollback TRANSACTION Point1
 end

 --Q13
 --Write a transaction that handles a deadlock scenario using
-- TRY...CATCH. Retry the operation if a deadlock is detected.
go
CREATE OR ALTER PROCEDURE sp_TransferWithDeadlockRetry
@FromAccount INT,
@ToAccount INT,
@Amount DECIMAL(18,2),
@MaxRetries INT=3
AS
BEGIN
SET NOCOUNT ON;

DECLARE @Retries INT=0;
DECLARE @Success BIT=0;

    WHILE @Retries< @MaxRetries AND @Success=0
BEGIN
BEGIN TRY
BEGIN TRANSACTION;

UPDATE AccountBalance
SET Balance= Balance-@Amount
WHERE AccountId=@FromAccount;

UPDATE AccountBalance
SET Balance= Balance+@Amount
WHERE AccountId=@ToAccount;

COMMIT TRANSACTION;

SET @Success=1;
            PRINT'Transaction successful';

END TRY
BEGIN CATCH
            IF @@TRANCOUNT>0
ROLLBACK TRANSACTION;

            IF ERROR_NUMBER()=1205
BEGIN
SET @Retries=@Retries+1;
                PRINT'Deadlock detected. Retry '+CAST(@Retries AS  VARCHAR)+' of '+CAST(@MaxRetries AS VARCHAR);
                WAITFOR DELAY'00:00:01';
END
ELSE
BEGIN
  PRINT'Error: '+ ERROR_MESSAGE();
RETURN-1;
END
END CATCH
END

    IF @Success=0
BEGIN
        PRINT'Transaction failed after '+CAST(@MaxRetries AS VARCHAR)+' retries';
RETURN-1;
END

RETURN;
END;
GO

--Q14
--Write a query to check the current transaction count
--(@@TRANCOUNT)
--and demonstrate how it changes within nested transactions.
print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));

begin try 
begin Tran
print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
update AccountBalance
set Balance -= 10 
where AccountId=101

update AccountBalance
set Balance += 10 
where AccountId=102

print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
 begin tran
 print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
 update AccountBalance
 set Balance -= 10 
 where AccountId=102

 update AccountBalance
 set Balance += 10 
 where AccountId=103

 print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
 commit 
  print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
  commit 
   print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));

end try
begin catch 
if @@TRANCOUNT>0
begin 
rollback 
print ('Tranaction count= ' + cast(@@Trancount As varchar(15)));
end
end catch

select Balance As BalanceAccount101AfterTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102AfterTransfer from AccountBalance where AccountId=102
select Balance As BalanceAccount103AfterTransfer from AccountBalance where AccountId=103


--Q15
--Write a transaction that logs all changes to the AuditTrail table.
--Include before and after values for updates.
go
begin tran 
declare @Balance1 decimal(10,2)
select @Balance1=Balance from AccountBalance
where AccountId=101

update AccountBalance
set Balance += 5
where AccountId=101

declare @Balance2 decimal(10,2)
select @Balance2=Balance from AccountBalance
where AccountId=101

insert into AuditTrail(TableName,OldValue,NewValue,Operation)
values ('AccountBalance',@Balance1,@Balance2,'update balance')
commit 

select *from AuditTrail

--Q16
--Write a transaction that demonstrates the difference between
--COMMIT and ROLLBACK by creating two identical transactions,
--committing one and rolling back the other.

--commited one 
select Balance As BalanceAccount101BeforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102BeforeTransfer from AccountBalance where AccountId=102

Begin Tran 
--oper1
update AccountBalance
set Balance-=500
where AccountId=101

--oper2
update AccountBalance
set Balance+=500
where AccountId=102

commit tran

select Balance As BalanceAccount101AfterTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102AfterTransfer from AccountBalance where AccountId=102

--rollback one 
select Balance As BalanceAccount101BeforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102BeforeTransfer from AccountBalance where AccountId=102

begin Tran
--oper1
update AccountBalance
set Balance-=1000
where AccountId=101

--oper2
update AccountBalance
set Balance+=1000
where AccountId=102

rollback;

select Balance As BalanceAccount101BeforeTransfer from AccountBalance where AccountId=101
select Balance As BalanceAccount102BeforeTransfer from AccountBalance where AccountId=102


--Q17
--Write a transaction that enforces a business rule: "Total
--withdrawals in a single transaction cannot exceed $5000".
--If violated, rollback the transaction.

begin tran 
declare @withdraw1 decimal(18,2)=3000;
declare @Withdraw2 decimal(18,2)=2200;
declare @totalwithdraw decimal(18,2) ;
set @totalwithdraw= @withdraw1 + @Withdraw2
if @totalwithdraw >5000
begin 
rollback 
print ('cannot withdraw this amount')
end
update AccountBalance
set  Balance-=@withdraw1
where AccountId=104

update AccountBalance
set  Balance-=@Withdraw2
where AccountId=104

commit 
print ('Withdraw done')

--Q18
--Write a transaction that uses explicit locking hints (WITH (UPDLOCK))
--to prevent concurrent modifications during a transfer.

begin tran 
declare @Balance decimal(18,2)

select @Balance=Balance
from AccountBalance with updlock 
where AccountId=104

update AccountBalance
set @Balance-=100
where AccountId=104

update AccountBalance with (updlock)
set @Balance+=100
where AccountId=103

commit 

--Q19
--Write a comprehensive error handling transaction that catches
--specific error numbers and handles them differently.
--Handle: Constraint violations, insufficient funds, and general errors.
go
begin try
begin tran
declare @amount decimal(18,2)=3000
declare @balance decimal(10,2)

select @balance=Balance
from AccountBalance
where  AccountId=101

if @balance<@amount
begin
raiserror('insuffcient funds',16,1)
end

update AccountBalance
set Balance-=@amount
where AccountId=101

update AccountBalance
set Balance+=@amount
where AccountId=102

commit 
end try 
begin catch 
if @@TRANCOUNT>0
begin 
rollback
end 
if ERROR_NUMBER() in (2627, 547, 515)
begin
print ('constraint violation ')
end
if ERROR_MESSAGE() like '%insuffcient funds%'
print ('not engough balance')

else
print ('general error')
end catch 

--Q20
--Write a transaction monitoring query that shows all active
--transactions in the database, including their status, start time,
--and session information.

 SELECT
    s.session_id,
    s.login_name,
    s.status AS session_status,
    t.transaction_id,
    t.name AS transaction_name,
    t.transaction_begin_time,
    t.transaction_state,
    t.transaction_type
FROM sys.dm_tran_active_transactions t
JOIN sys.dm_tran_session_transactions st
    ON t.transaction_id = st.transaction_id
JOIN sys.dm_exec_sessions s
    ON st.session_id = s.session_id
ORDER BY t.transaction_begin_time DESC;
