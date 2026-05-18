select * from orders
Where OrderID = 10407
go

------------------------

set transaction
isolation level
read committed
begin transaction
update customers set ContactTitle='piotr p'
where customerID ='ALFKI'
commit

go


---------------------
