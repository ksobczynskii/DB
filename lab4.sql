Select * from dbo.Orders
go

-----------------------------------------------------

Select * from dbo.Orders
WHERE ShipCountry IN ('Mexico', 'Brazil', 'Germany')
go
-----------------------------------------------------

Select DISTINCT ShipCity from dbo.Orders -- distinct lub group by
WHERE ShipCountry = 'Germany'
-- GROUP BY ShipCity
go

-----------------------------------------------------

Select DISTINCT
    Left(UPPER(CompanyName),10) -- tu nie as tylko zmieniamy in place
FROM
    Customers
go

-----------------------------------------------------

Select o.* From dbo.Orders o

JOIN dbo.Customers c

On c.CustomerID = o.CustomerID

where c.Country != o.ShipCountry
go
-----------------------------------------------------

Select c.* FROM dbo.Customers c

Full Join dbo.Orders o

ON o.CustomerID = c.CustomerID
Where o.CustomerID IS NULL


Select * FROM dbo.Customers c
WHERE CustomerID not in -- lub not exist
(
    Select CustomerID FROm dbo.Orders o

)
go
-----------------------------------------------------

-- Common Table Expression (CTE) - Sposób pisania zapytań z ustanawianiem tabel pre_sql do pozniejszego join


Select DISTINCT c.* FROM dbo.Customers c

JOIN dbo.Orders o
    ON o.CustomerID = c.CustomerID
JOIN dbo.[Order Details] od
    ON od.OrderID = o.OrderID
JOIN dbo.Products p
    ON p.ProductID = od.ProductID
WHERE ProductName = 'Scottish Longbreads'

go
-----------------------------------------------------

-- Wersja CTE

with pre_products as (Select *
                      From dbo.Products
                      Where ProductName = 'Scottish Longbreads')
, pre_customer as(
    Select Distinct
        o.CustomerID
    FROM
        dbo.Orders o
    join dbo.[Order Details] od
    ON od.OrderID = o.OrderID
    join pre_products p
    ON p.ProductID = od.ProductID
)
Select * FROM Customers
Where CustomerID IN (select customerID from pre_customer)

go
-----------------------------------------------------
with pre_orders as (Select
                        o.EmployeeID, od.ProductID, ProductName, YEAR(o.OrderDate) as year
                    From Orders o
                    Join dbo.[Order Details] od
                    ON od.OrderID = o.OrderID
                    Join dbo.Products p
                    ON p.ProductID = od.ProductID
                    WHERE ProductName LIKE 'Chocolade'  -- AND YEAR(o.OrderDate) = '1998'
                    )
, pre_employees as (Select e.FirstName, e.LastName, Count(ProductID) as Total
                       from Employees e
                        JOIN pre_orders po
                        On po.EmployeeID = e.EmployeeID
                        GROUP BY e.FirstName, e.LastName
                        HAVING Count(ProductId) > 100
                                                   )
Select *
FROM pre_employees

go
------------------------------------------------------


with pre_customers as (Select c.ContactName, CustomerID
                    FROM Customers c
                    WHERE c.City = 'Berlin')
Select o.OrderDate, o.CustomerID, ContactName, Quantity
                    FROM pre_customers pc

                    JOIN Orders o
                    ON o.CustomerID = pc.CustomerID

                    JOIN dbo.[Order Details] od
                    ON od.OrderID = o.OrderID

                    JOIN Products p
                    ON p.ProductID = od.ProductID

                    ORDER BY ContactName, ProductName, OrderDate
go

------------------------------------------------------


with pre_orders as (

    Select CompanyName, o.OrderID, cast(COUNT(Distinct (od.ProductID)) as DECIMAL(10,2)) as ProductCount
    FROM Orders o

    JOIN dbo.[Order Details] od on o.OrderID = od.OrderID

    -- JOIN dbo.Products p ON p.ProductID = od.ProductID

    JOIN Customers c
    ON c.CustomerID = o.CustomerID

    WHERE c.Country = 'France'

    GROUP BY o.OrderID, CompanyName
    HAVING COUNT(Distinct (od.ProductID)) >= 4
)


Select *
FROM pre_orders
go

------------------------------------------------------


with pre_products as (SELECT ProductName, p.ProductID, MAX(od.Quantity) as biggest
                      FROM [Order Details] od
                      JOIN Products p
                      ON od.ProductID = p.ProductID
                      GROUP BY ProductName, p.ProductID
                      )
, pre_clients as (SELECT CompanyName, ProductName, biggest
                      FROM Customers c
                      JOIN Orders o
                      ON c.CustomerID = o.CustomerID

                      JOIN [Order Details] od
                      ON od.OrderID = o.OrderID

                      JOIN pre_products pp
                      ON pp.ProductID = od.ProductID
                      WHERE od.Quantity = biggest
                      )
Select * from pre_clients
go

SELECT TOP 5 o.OrderID, COUNT(od.ProductID) as ProductCount
    FROM Orders o

    JOIN [Order Details] od
    ON od.OrderID = o.OrderID

--         JOIN Products p
--         ON p.ProductID = od.ProductID

    GROUP BY o.OrderID
    ORDER BY COUNT(od.ProductID) desc
go



with get_sum as(SELECT o.EmployeeID, COUNT(OrderID) as order_count
                    FROM Orders o
                    GROUP BY o.EmployeeID
                    )
, pre_avg as (
    SELECT AVG(order_count) as avg
    FROM get_sum
)

SELECT e.FirstName, e.LastName, gs.order_count, (SELECT * FROM pre_avg) as avg

    FROM Employees e
    JOIN get_sum gs
    ON e.EmployeeID = gs.EmployeeID
    WHERE order_count > 1.2 * (SELECT * FROM pre_avg)
go




