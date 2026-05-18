-- Zapytania SQL 1

Select SUBSTRING(UPPER(c.CompanyName),0,10)
From Customers c
go

-------------------------

with Clients_From_France as(
    Select *
    From Customers c
    Where c.Country Like 'France'
)

Select o.*
From Orders o
JOIN Clients_From_France c
ON o.CustomerID = c.CustomerID
go

------------------------------

with Orders_Scottish_Longbreads as (
    Select Distinct o.CustomerID
    From Orders o
    JOIN [Order Details] od
    ON od.OrderID = o.OrderID
    WHERE od.ProductID = (SELECT TOP(1) p.ProductID FROM Products p WHERE p.ProductName = 'Scottish Longbreads')
)

Select *
From Customers c
JOIN Orders_Scottish_Longbreads osl
ON osl.CustomerID = c.CustomerID
go


-------------------------------

with Orders_Scottish_Longbreads as (
    Select o.OrderID, od.ProductID
    From Orders o
    JOIN [Order Details] od
    ON od.OrderID = o.OrderID
    WHERE od.ProductID = (SELECT TOP(1) p.ProductID FROM Products p WHERE p.ProductName = 'Scottish Longbreads')
),
Choc_Orders as(
    Select o.OrderID
    FROM Orders o
    JOIN [Order Details] od
    ON o.OrderID = od.OrderID
    WHERE od.ProductID = (SELECT TOP(1) p.ProductID FROM Products p WHERE p.ProductName = 'Chocolade')
)
,No_Choc_Orders as (
    Select o.OrderID
    FROM Orders o
    LEFT JOIN Choc_Orders co
    ON co.OrderID = o.OrderID
    WHERE co.OrderID IS NULL
)

SELECT *
FROM Orders_Scottish_Longbreads osl
JOIN No_Choc_Orders nco
ON nco.OrderID = osl.OrderID
go

-- INNA WERSJA:

Select *
FROM Orders o
WHERE exists(SELECT * FROM [Order Details] od JOIN Products p on p.ProductID = od.ProductID WHERE ProductName = 'Scottish Longbreads' and od.OrderID = o.OrderID)
and not exists(select * from [Order Details] od join Products p on p.ProductID = od.ProductID where ProductName='Chocolade' and od.OrderID = o.OrderID)
go

------------------ #13

SELECT e.FirstName, e.LastName
FROM Employees e
WHERE exists(SELECT * FROM Orders o JOIN Customers c ON c.CustomerID = o.CustomerID WHERE c.CustomerID = 'ALFKI' AND e.EmployeeID = o.EmployeeID)
go


----------------- #14

with presql1 as(
    SELECT od.OrderID, Count(ProductID) as sum_of_prods
    FROM [Order Details] od
    WHERE ProductID = (SELECT TOP(1) p.ProductID FROM Products p WHERE p.ProductName = 'Chocolade')
    GROUP BY od.OrderID
)
,presql2 as(
    SELECT o.EmployeeID, o.OrderID,  p.sum_of_prods
        FROM Orders o
        JOIN presql1 p ON o.OrderID = p.OrderID
)


SELECT e.FirstName,e.LastName,o.OrderID,o.OrderDate,(case when od.ProductID is NULL then 0 else 1 end) as Had_Chocolate
FROM Employees e
LEFT JOIN Orders [o]
ON e.EmployeeID = o.EmployeeID
LEFT JOIN [Order Details] od
ON od.OrderID = o.OrderID AND od.ProductID = (SELECT p.ProductId from Products p WHERE p.ProductName = 'Chocolade')
go

---------------- #15
SELECT od.OrderID, o.ShipCountry
     , p.ProductName
     , YEAR(o.OrderDate) as year, MONTH(o.OrderDate) as month, o.OrderDate
FROM [Order Details] od
JOIN Orders o ON o.OrderID = od.OrderID
JOIN Products p ON p.ProductID = od.ProductID
WHERE o.CustomerID IN (SELECT c.CustomerID FROM Customers c WHERE c.Country = 'GERMANY')
AND LEFT(p.ProductName,1) < 'S' AND LEFT(p.ProductName,1) > 'c'
Order BY o.OrderDate DESC
go


--- SQL SELECT 2

----------------- #1

SELECT  o.ShipCountry,od.ProductID, SUM(od.Quantity) AS [Total_Quantity]
FROM Orders o
JOIN [Order Details] od ON od.OrderID = o.OrderID
WHERE o.EmployeeID = 1
GROUP BY o.ShipCountry, od.ProductID
ORDER BY o.ShipCountry

--------------------- #2

SELECT e.FirstName, e.LastName, SUM(od.Quantity) as TotalQuantity
FROM Employees e
JOIN Orders o ON o.EmployeeID = e.EmployeeID
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE od.ProductID = (SELECT p.ProductID FROM Products p WHERE p.ProductName = 'Scottish Longbreads') -- bo chocolade nie ma
AND YEAR(o.OrderDate) = 1998
GROUP BY e.FirstName, e.LastName
HAVING SUM(od.Quantity) > 100

--------------------- #3

SELECT
    c.CustomerID,
    c.CompanyName,
    p.ProductID,
    p.ProductName,
    AVG(CAST(od.Quantity AS FLOAT)) AS SredniaSztukNaZamowienie,
    COUNT(DISTINCT o.OrderID) AS LiczbaZamowienNaProdukt
FROM Customers c
JOIN Orders o
    ON o.CustomerID = c.CustomerID
JOIN [Order Details] od
    ON od.OrderID = o.OrderID
JOIN Products p
    ON p.ProductID = od.ProductID
WHERE c.Country = 'Italy'
GROUP BY
    c.CustomerID,
    c.CompanyName,
    p.ProductID,
    p.ProductName
HAVING AVG(CAST(od.Quantity AS FLOAT)) >= 20
ORDER BY LiczbaZamowienNaProdukt DESC;
go


----------------------------- #4
Select c.CompanyName, p.ProductName, o.OrderDate, SUM(od.Quantity) as Quantity
FROM Customers [c]
JOIN Orders o on o.CustomerID = c.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.[ProductID]
WHERE c.City = 'Berlin'
GROUP BY c.CompanyName, p.ProductName, o.[OrderDate]
go

---------------------------- #5
SELECT p.ProductName
FROM Products p
JOIN [Order Details] od on p.ProductID = od.ProductID
JOIN Orders o on o.OrderID = od.[OrderID]
WHERE o.ShipCountry = 'France' AND YEAR(o.OrderDate) = 1998
GROUP BY p.ProductName
go

--------------------------- #9

with max_orders as (
    SELECT od.ProductID, MAX(od.Quantity) as max
    FROM [Order Details] od
    GROUP BY od.ProductID
),
    clients_w_max as(
        SELECT p.ProductName, c.CompanyName, od.Quantity
        FROM Customers c
        JOIN Orders o ON o.CustomerID = c.CustomerID
        JOIN [Order Details] od on o.OrderID = od.OrderID
        JOIN max_orders mo on mo.ProductID = od.ProductID
        JOIN Products p on p.ProductID = od.ProductID
        WHERE od.Quantity = mo.max
    )
SELECT cwm.ProductName, cwm.CompanyName, cwm.Quantity
FROM clients_w_max cwm
go

--------------------------- #10

with orders_per_employee as (
    SELECT o.EmployeeID,  COUNT(o.OrderID) as sum_of_orders
    FROM Orders o
    GROUP BY o.EmployeeID
)

,avg_order as (
    SELECT AVG(ope.sum_of_orders) as avg
    FROM orders_per_employee ope
)

SELECT e.FirstName, e.LastName, ope.sum_of_orders
FROM Employees e
JOIN orders_per_employee ope on ope.EmployeeID = e.EmployeeID
WHERE ope.sum_of_orders >= 1.2* (SELECT ao.avg FROM avg_order ao)
go

SELECT e.FirstName, e.LastName,Count(OrderID),AVG(Count(OrderID)) over ()
FROM Employees e
JOIN Orders o on o.EmployeeID = e.EmployeeID
Group By e.FirstName, e.LastName








----------------------------- #11

SELECT TOP(5) o.OrderID, COUNT(od.ProductID) as ProductCount
FROM Orders o
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.OrderID
ORDER BY ProductCount desc

--------------------------- #12

with products_in_1997 as (
    SELECT p.ProductID, SUM(case when YEAR(o.OrderDate) = 1997 then od.Quantity else 0 end) as sum
    FROM Products p
    LEFT JOIN [Order Details] od  on p.ProductID = od.ProductID
    LEFT JOIN Orders o on o.OrderID = od.OrderID
    GROUP BY p.ProductID
)
,products_in_1996 as (
    SELECT p.ProductID, SUM(case when YEAR(o.OrderDate) = 1996 then od.Quantity else 0 end) as sum
    FROM Products p
    LEFT JOIN [Order Details] od  on p.ProductID = od.ProductID
    LEFT JOIN Orders o on o.OrderID = od.OrderID
    GROUP BY p.ProductID
)

SELECT p.ProductName, p1996.sum as TotalQuantityIn1996, p1997.sum as TotalQuantityIn1997
FROM Products p
JOIN products_in_1996 p1996 on p.ProductID = p1996.ProductID
JOIN products_in_1997 p1997 on p.ProductID = p1997.ProductID
WHERE p1996.sum < p1997.sum
go



--------------------------- #13
with products_in_1997 as (
    SELECT p.ProductID, SUM(case when YEAR(o.OrderDate) = 1997 then 1 else 0 end) as sum
    FROM Products p
    LEFT JOIN [Order Details] od  on p.ProductID = od.ProductID
    LEFT JOIN Orders o on o.OrderID = od.OrderID
    GROUP BY p.ProductID
),products_in_1996 as (
    SELECT p.ProductID, SUM(case when YEAR(o.OrderDate) = 1996 then 1 else 0 end) as sum
    FROM Products p
    LEFT JOIN [Order Details] od  on p.ProductID = od.ProductID
    LEFT JOIN Orders o on o.OrderID = od.OrderID
    GROUP BY p.ProductID
)
SELECT p.ProductName, p1996.sum as NumberOfOrdersIn1996, p1997.sum as NumberOfOrdersIn1997
FROM Products p
JOIN products_in_1996 p1996 on p.ProductID = p1996.ProductID
JOIN products_in_1997 p1997 on p.ProductID = p1997.ProductID
WHERE p1996.sum < p1997.sum
go

--------------------------- #14
create view OrdersTotal as(
SELECT YEAR(o.OrderDate) as OrderYear, MONTH(o.OrderDate) as OrderMonth, o.OrderID, c.CustomerID, c.CompanyName, c.Country as CustomerCountry,
       c.City as CustomerCity, o.ShipCountry, o.ShipCity, p.ProductID, p.ProductName, c2.CategoryName, p.UnitPrice, od.Quantity, (p.UnitPrice * od.Quantity) as ProductValue
FROM Orders o
JOIN [Order Details] od on o.OrderID = od.OrderID
JOIN dbo.Products p on p.ProductID = od.ProductID
JOIN dbo.Customers c on o.CustomerID = c.CustomerID
JOIN dbo.Categories c2 on p.CategoryID = c2.CategoryID);
go

--------------------------- #15
-- with products_quant as(
--     SELECT od.ProductID, Sum(od.Quantity) as TotalProductOrders
--     FROM [Order Details] od
--     GROUP BY od.ProductID
-- )
-- ,cat_quant as (
--     SELECT c.CategoryID, SUM(od.Quantity) as TotalCategoryOrders
--     FROM [Order Details] od
--     JOIN Products p on od.ProductID = p.ProductID
--     JOIN Categories c on c.CategoryID = p.CategoryID
--     Group By c.CategoryID
-- )
-- SELECT o.OrderID, p.ProductName, c2.CategoryName, od.Quantity, pq.TotalProductOrders, cq.TotalCategoryOrders
-- FROM Orders o
-- JOIN [Order Details] od on od.OrderID = o.OrderID
-- JOIN Products p on p.ProductID = od.ProductID
-- JOIN Categories c2 on c2.CategoryID = p.CategoryID
-- JOIN products_quant pq on p.ProductID = pq.ProductID
-- JOIN cat_quant cq on cq.CategoryID = c2.CategoryID
-- go

SELECT OrderID, ProductName, CategoryName, ProductValue, SUM(ProductValue) OVER (PARTITION BY CategoryName) as CategoryTotalSale, SUM(ProductValue) over (partition by ProductName) as ProductTotalSale
FROM OrdersTotal ot
order by ProductName


---------------------------------- #16
SELECT Distinct ProductName, CategoryName, SUM(ProductValue) over (partition by ProductID) as TotalProductValue, SUM(ProductValue) OVER (PARTITION BY CategoryName) as TotalCategoryValue, sum(ProductValue) over () as TotalSale
FROM OrdersTotal ot
go




------------------------------ Zadanie 2 kolos przykładowy

----------------------------- Q1
with avg_BCM as (
    Select AVG(od.Quantity) as avg
    FROM [Order Details] od
    WHERE od.ProductID = (SELECT TOP(1) p.ProductID FROM Products p WHERE p.ProductName = 'Boston Crab Meat')
    )
SELECT e.FirstName, e.LastName -- , o.OrderID, od.Quantity, od.ProductID
FROM Employees e
JOIN Orders o on o.EmployeeID = e.EmployeeID
JOIN [Order Details] od on od.OrderID = o.OrderID
WHERE od.ProductID = (SELECT TOP(1) p.ProductID FROM Products p WHERE p.ProductName = 'Boston Crab Meat')
AND od.Quantity >= (SELECT * FROM avg_BCM)
go

------------------------------ Q2

with sells_in_may_oct as(
    SELECT p.ProductID, SUM(case when od.Quantity is not NULL then od.Quantity else 0 end) as TotalSells
    FROM Products p
    LEFT JOIN [Order Details] od on od.ProductID = p.ProductID
    LEFT JOIN Orders o on o.OrderID = od.OrderID
    WHERE MONTH(o.OrderDate) >= 5 AND MONTH(o.OrderDate) <= 10
    GROUP BY p.ProductID
),
    sells_in_nov_apr as(
    SELECT p.ProductID, SUM(case when od.Quantity is not NULL then od.Quantity else 0 end) as TotalSells
    FROM Products p
    LEFT JOIN [Order Details] od on od.ProductID = p.ProductID
    LEFT JOIN Orders o on o.OrderID = od.OrderID
    WHERE MONTH(o.OrderDate) >= 11 OR MONTH(o.OrderDate) <= 4
    GROUP BY p.ProductID
)

SELECT p.ProductName, mo.TotalSells as May_October, na.TotalSells as November_April
FROM Products p
JOIN sells_in_may_oct mo on mo.ProductID = p.ProductID
JOIN sells_in_nov_apr na on na.ProductID = p.ProductID
WHERE mo.TotalSells > na.TotalSells

---------------------------- Q3

with products_sent_to_france as(
    SELECT Distinct p.ProductID
    FROM Products p
    JOIN [Order Details] od on od.ProductID = p.ProductID
    JOIN Orders o on o.OrderID = od.OrderID
    WHERE o.ShipCountry = 'FRANCE'
)

,products_not_sent_to_france as(
    SELECT DISTINCT p.ProductID
    from products p
    where not exists(SELECT * FROM products_sent_to_france f WHERE f.ProductID = p.ProductID)
)
, orders_matching_criteria as (
    SELECT o.OrderID
    FROM Orders o
    JOIN [Order Details] od on od.OrderID = o.OrderID
    JOIN products_not_sent_to_france pnf on pnf.ProductID = od.ProductID
    GROUP BY o.OrderID
    HAVING COUNT(*) >= 5
)

SELECT *
FROM Orders o
JOIN orders_matching_criteria omc on omc.OrderID = o.OrderID
go

---------------------------- Q4
with presql as(
    SELECT Month(o.OrderDate) as month, COUNT(DISTINCT o.OrderID) amount
    FROM Orders o
    JOIN [Order Details] od on od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY Month(o.OrderDate)
)

SELECT ps.month as Month, SUM(amount) over(ORDER BY ps.month rows between unbounded preceding and current row) as TotalCountForYear,
       SUM(amount) over(ORDER BY ps.month rows between 2 preceding and current row) as TotalCountForLastMonths
FROM presql ps
go























