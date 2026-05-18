-------------------------------------#1

SELECT *
FROM Orders
WHERE
    EmployeeID = 1
go

Update Orders
SET EmployeeID = 4
WHERE EmployeeID = 1
go

------------------------------ #2



Update od
SET od.Quantity = CEILING(od.Quantity * 0.8)
FROM [Order Details] od
JOIN Products p ON od.ProductID = p.ProductID
JOIN dbo.Orders o on od.OrderID = o.OrderID
WHERE o.OrderDate > '1997-05-15' AND p.ProductName = 'Ikura'
go



----------------------------- #3

with no_choc_orders as (SELECT o.OrderID
                        FROM Orders o
                        WHERE NOT EXISTS(SELECT od.OrderID
                                         FROM [Order Details] od
                                                  JOIN Products p on od.ProductID = p.ProductID
                                         WHERE ProductName = 'Chocolade' AND od.OrderID = o.OrderID)),
last_alfki_choc as (
    SELECT TOP(1) o.OrderID
    FROM Orders o
    JOIN no_choc_orders nco on nco.OrderID = o.OrderID
    WHERE CustomerID = 'ALFKI'
    ORDER BY o.OrderDate DESC
),
choc_id as (
    SELECT TOP(1) p.ProductID
    FROM Products p
    WHERE p.ProductName = 'Chocolade'
),
ready_to_insert as (
    SELECT TOP(1) lac.OrderID, ci.ProductID, Quantity = 1,p.UnitPrice
    FROM choc_id ci
    CROSS JOIN last_alfki_choc lac
    JOIN Products p ON p.ProductID = ci.ProductID
)

INSERT INTO [Order Details]
(OrderID, ProductID, Quantity, UnitPrice)
SELECT *
FROM ready_to_insert
go

---------------------------- #4
with alfki_no_choc as(
    SELECT o.OrderID
            FROM Orders o
            WHERE NOT EXISTS(SELECT od.OrderID
                             FROM [Order Details] od
                                      JOIN Products p on od.ProductID = p.ProductID
                             WHERE ProductName = 'Chocolade' AND od.OrderID = o.OrderID)
            AND
                CustomerID = 'ALFKI'

),
pre_insert as (
    SELECT o.OrderID, pid = (SELECT TOP (1) ProductID FROM Products WHERE ProductName='Chocolade'),Quantity=1, up = (SELECT TOP (1) UnitPrice FROM Products WHERE ProductName='Chocolade')
    FROM Orders o
    JOIN alfki_no_choc anc on anc.OrderID = o.OrderID
)
--
-- SELECT *
-- FROM pre_insert

INSERT INTO [Order Details]
(OrderID, ProductID, Quantity, UnitPrice)
SELECT * FROm pre_insert
go


---------------------------- #5

DELETE c
FROM Customers c
WHERE NOT EXISTS(SELECT 1 FROM Orders o WHERE o.CustomerID = c.CustomerID)
go


------------------------- #6



SELECT SUM(od.Quantity)
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Chocolade' AND YEAR(OrderDate) = 1997

BEGIN TRANSACTION
INSERT INTO Products
(ProductName, SupplierID, CategoryID, QuantityPerUnit)
VALUES
('Programming in Java', 1, 1,'1 course')

UPDATE od
SET od.Quantity = CEILING(od.Quantity*1.5)
FROM [Order Details] od
JOIN Products p on od.ProductID = p.ProductID
JOIN Orders o on od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1997 AND p.ProductName = 'Chocolade'
COMMIT

SELECT SUM(od.Quantity)
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Chocolade' AND YEAR(OrderDate) = 1997
go

----------------------- #7

SELECT SUM(od.Quantity)
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Chocolade' AND YEAR(OrderDate) = 1997

BEGIN TRANSACTION

UPDATE od
SET od.Quantity = od.Quantity*2
FROM [Order Details] od
JOIN Products p on od.ProductID = p.ProductID
JOIN Orders o on od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1997 AND p.ProductName = 'Chocolade'

SELECT SUM(od.Quantity)
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Chocolade' AND YEAR(OrderDate) = 1997


ROLLBACK

SELECT SUM(od.Quantity)
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Chocolade' AND YEAR(OrderDate) = 1997
go


------------------------ #8
UPDATE od
SET od.Quantity = od.Quantity*2
FROM [Order Details] od
JOIN Products p on od.ProductID = p.ProductID
JOIN Orders o on od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1997 AND p.ProductName = 'Chocolade'

SELECT SUM(od.Quantity) as 'Sum of ikura'
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Ikura' AND YEAR(OrderDate) = 1997

BEGIN TRANSACTION
-- del no choc

DELETE od
FROM [Order Details] od
WHERE NOT EXISTS (SELECT 1 FROM [Order Details] od2 WHERE od2.OrderID = od.OrderId AND ProductID = (SELECT TOP(1) ProductId FROM Products p WHERE p.ProductName = 'Chocolade'))

DELETE o
FROM Orders o
WHERE NOT EXISTS (SELECT 1 FROM [Order Details] od WHERE od.OrderID = o.OrderId AND ProductID = (SELECT TOP(1) ProductId FROM Products p WHERE p.ProductName = 'Chocolade'))
-- add no ikura

INSERT INTO [Order Details]

    (OrderID, ProductID, UnitPrice, Quantity, Discount)

SELECT

    o.OrderID,

    p.ProductID,

    p.UnitPrice,

    1,

    0

FROM Orders o

JOIN Products p ON p.ProductName = 'Ikura'

WHERE NOT EXISTS (

    SELECT 1

    FROM [Order Details] od

    WHERE od.OrderID = o.OrderID

      AND od.ProductID = p.ProductID

);

SELECT SUM(od.Quantity) as 'Sum of ikura'
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Ikura' AND YEAR(OrderDate) = 1997

ROLLBACK

SELECT SUM(od.Quantity) as 'Sum of ikura'
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Ikura' AND YEAR(OrderDate) = 1997


UPDATE od
SET od.Quantity = od.Quantity*2
FROM [Order Details] od
JOIN Products p on od.ProductID = p.ProductID
JOIN Orders o on od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1997 AND p.ProductName = 'Ikura'

SELECT SUM(od.Quantity) as 'Sum of ikura'
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE ProductName='Ikura' AND YEAR(OrderDate) = 1997

go

------------------------------- Scenariusz #1
CREATE TABLE ArchivedOrders
(OrderId int NOT NULL, CustomerID nchar(5) NOT NULL, EmployeeID int NOT NULL, OrderDate datetime, RequiredDate datetime, ShippedDate datetime, ShipVia int, Freight money
,ShipName nvarchar(40), ShipAddress nvarchar(60), ShipCity nvarchar(15), ShipRegion nvarchar(15), ShipPostalCode nvarchar(10), ShipCountry nvarchar(15), ArchiveDate datetime
CONSTRAINT PK_Constraint PRIMARY KEY
(
    OrderId
),
CONSTRAINT FKC_Orders_Customers FOREIGN KEY(CustomerID) REFERENCES dbo.Customers(CustomerID),
CONSTRAINT FKC_Orders_Employees FOREIGN KEY(EmployeeID) REFERENCES dbo.Employees(EmployeeID),
CONSTRAINT FKC_Orders_Shippers FOREIGN KEY(ShipVia) REFERENCES dbo.Shippers(ShipperID))


CREATE TABLE ArchivedOrderDetails
(OrderId int NOT NULL, ProductID int NOT NULL, UnitPrice money CHECK(UnitPrice >= 0), Quantity smallint CHECK(Quantity > 0), Discount real CHECK (Discount >= 0 AND Discount <= 1),
CONSTRAINT PK_Archived_Order_Details_Constraint PRIMARY KEY(OrderId, ProductID),
CONSTRAINT FK_Archive_Order_Details_Order FOREIGN KEY(OrderId) REFERENCES dbo.ArchivedOrders(OrderId),
CONSTRAINT FK_Archive_Order_Details_Products FOREIGN KEY(ProductID) REFERENCES dbo.Products(ProductId),
)


BEGIN TRANSACTION

INSERT INTO ArchivedOrders
(OrderId, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, ArchiveDate)
SELECT *, GETDATE()
FROM Orders o
WHERE YEAR(o.OrderDate) = 1997


INSERT INTO ArchivedOrderDetails
(OrderId, ProductID, UnitPrice, Quantity, Discount)
SELECT *
FROM [Order Details] od
WHERE EXISTS(SELECT 1 FROM ArchivedOrders ao WHERE od.OrderID = ao.OrderId)

DELETE od
FROM [Order Details] od
WHERE EXISTS(SELECT 1 FROM ArchivedOrders ao WHERE od.OrderID = ao.OrderId)

DELETE o
FROM Orders o
WHERE EXISTS(SELECT 1 FROM ArchivedOrders ao WHERE o.OrderID = ao.OrderId)

COMMIT



------------------------------ #2
BEGIN TRANSACTION

UPDATE o
SET
    o.IsCancelled = CASE WHEN o.CustomerID = 'ALFKI' THEN 1 ELSE 0 END
FROM Orders o

UPDATE od
SET Quantity = CASE WHEN o.CustomerID = 'ALFKI' THEN 0 ELSE od.Quantity END
FROM [Order Details] od
JOIN Orders o ON od.OrderID = o.OrderID

COMMIT
go



--------------------------- #3


BEGIN TRANSACTION

CREATE TABLE PriceList
(ProductID int NOT NULL, Price money, DateFrom datetime, DateTo datetime

CONSTRAINT FK_PriceList_Products FOREIGN KEY(ProductID) REFERENCES dbo.Products(ProductID)
)

INSERT INTO PriceList
(ProductID, Price, DateFrom, DateTo)
SELECT p.ProductID, p.UnitPrice, DATEFROMPARTS(1997,1,1), DATEFROMPARTS(1997,12,31)
FROM Products p

INSERT INTO PriceList
(ProductID, Price, DateFrom, DateTo)
SELECT p.ProductID, price = p.UnitPrice *1.2, DATEFROMPARTS(1998,1,1), DATEFROMPARTS(1998,12,31)
FROM Products p


INSERT INTO PriceList
(ProductID, Price, DateFrom, DateTo)
SELECT p.ProductID, price = p.UnitPrice*0.8, DATEFROMPARTS(1996,1,1), DATEFROMPARTS(1996,12,31)
FROM Products p


ALTER TABLE Orders
ADD TotalValue money

COMMIT

UPDATE o

SET o.TotalValue = x.TotalValue

FROM Orders o

JOIN (

    SELECT

        o.OrderID,

        SUM(od.Quantity * pl.Price) AS TotalValue

    FROM Orders o

    JOIN [Order Details] od

        ON od.OrderID = o.OrderID

    JOIN PriceList pl

        ON pl.ProductID = od.ProductID

       AND o.OrderDate >= pl.DateFrom

       AND o.OrderDate <  pl.DateTo

    GROUP BY o.OrderID

) x ON x.OrderID = o.OrderID
go



--------------------- #4
BEGIN TRANSACTION

ALTER TABLE Customers
ALTER COLUMN CompanyName nvarchar(100)
go

ALTER TABLE Customers
ADD TotalOrderCount int
go

with clients_order_count as (
SELECT c.CustomerID, sum_of_orders = Count(o.OrderID)
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID
)

UPDATE c
SET c.TotalOrderCount = coc.sum_of_orders
FROM Customers c
JOIN clients_order_count coc on coc.CustomerID = c.CustomerID
go

COMMIT
go

BEGIN TRANSACTION
ALTER TABLE Products
ADD LastOrder datetime
go
with last_order_of_product as(

SELECT p.ProductID, last_order = MAX(o.OrderDate)
FROM Products p
JOIN [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o on o.OrderID = od.OrderID
GROUP BY p.ProductID
)

-- SELECT * FROM last_order_of_product

UPDATE p
SET p.LastOrder = loop.last_order
FROM Products p
JOIN last_order_of_product loop on loop.ProductID = p.ProductID

COMMIT
go




ALTER TABLE Products
ADD IsCancelled int
go


with products_ordered_lately as (

SELECT p.ProductID, cancel = CASE WHEN EXISTS(SELECT 1 FROM Orders o JOIN [Order Details] od on od.OrderID = o.OrderID WHERE YEAR(o.OrderDate) != 1996 AND od.ProductID = p.ProductID)
                            THEN 0 ELSE 1 END
FROM Products p
)

UPDATE p
SET p.IsCancelled = pol.cancel
FROM Products p
JOIN products_ordered_lately pol ON pol.ProductID = p.ProductID
go









