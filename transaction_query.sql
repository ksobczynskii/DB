begin transaction
update Orders
set CustomerID='ALFKI'
where orderId=10407
rollback

----------------------------------- #4

set transaction
isolation level
repeatable read
begin transaction
select * from Customers
where CustomerID = 'ALFKI'
go
rollback

---------------------------
select * from Customers
Where CustomerID='ALFKI'


