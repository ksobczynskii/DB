update dbo.Orders
set EmployeeID = 4
where EmployeeID = 1
go
-------------------------------

update dbo.Orders
    set
       EmployeeID =
        case
            when EmployeeID = 2
                then 5
            when EmployeeID = 3
                then 1
        end
where EmployeeID IN (2,3)

-------------------------------

with orders_with_chocolate as (Select od.OrderID FROM [Order Details] od WHERE od.ProductID = (SELECT TOP 1 p.ProductID FROM Products p WHERE p.ProductName = 'Chocolade'))

SELECT TOP(1) *
FROM Orders o
    Join Customers c ON c.CustomerID = o.CustomerID
    Left Join orders_with_chocolate oc
        on o.OrderID = oc.OrderID
WHERE c.CustomerID = 'ALFKI'
    and oc.OrderID is null
ORDER BY o.OrderDate desc
go

--------------------------------









