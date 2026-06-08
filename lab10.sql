begin transaction


declare @curr_timestamp datetime2 = year(GETDATE())
declare @N int = 3

SELECT *
INTO #temp_orders
FROM Orders
WHERE DATEDIFF(year, OrderDate, @curr_timestamp) >= @N


insert into dbo.ArchivedOrders
(OrderId, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, ArchiveDate)
SELECT
    OrderId, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, @curr_timestamp
from dbo.Orders o
    where DATEDIFF(year, OrderDate, @curr_timestamp) >= @N


insert into dbo.ArchivedOrderDetails
(OrderId, ProductID, UnitPrice, Quantity, Discount)
SELECT
    OrderId, ProductID, UnitPrice, Quantity, Discount
FROM dbo.[Order Details] od
    where OrderID IN (SELECT OrderId FROM #temp_orders)


delete from dbo.Orders
where DATEDIFF(year, OrderDate, @curr_timestamp) >= @N



select *
into
    dbo.ArchivedOrders
from dbo.Orders

commit



