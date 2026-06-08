CREATE PROCEDURE MoveOlderThanN
    @Years INT
AS
BEGIN

declare @curr_timestamp datetime2 = GETDATE()
BEGIN TRANSACTION

    INSERT INTO ArchivedOrders
    (OrderId, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, ArchiveDate)
    SELECT OrderId, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, @curr_timestamp
    FROM Orders o
    WHERE DATEDIFF(yy,OrderDate,GETDATE()) > @Years

    INSERT INTO ArchivedOrderDetails
    (OrderId, ProductID, UnitPrice, Quantity, Discount)
    SELECT
        od.OrderId, ProductID, UnitPrice, Quantity, Discount
    FROM [Order Details] od
    JOIN dbo.Orders o on od.OrderID = o.OrderID
    WHERE DATEDIFF(yy,OrderDate,GETDATE()) > @Years


    DELETE od
    FROM [Order Details] od
    JOIN Orders o ON od.OrderID = o.OrderID
    WHERE DATEDIFF(yy,OrderDate,GETDATE()) > @Years

    DELETE o
    FROM Orders o
    WHERE DATEDIFF(yy,OrderDate,GETDATE()) > @Years

COMMIT
END


EXEC MoveOlderThanN
    @Years = 10



---------------------- #2
ALTER TABLE [Order Details]
    ADD Discount INT
CREATE OR ALTER PROCEDURE UpdateDiscount
    @CustomerID NCHAR(5)
AS
BEGIN
    BEGIN TRANSACTION
        Update od
        SET Discount =
            CASE
                WHEN (SELECT COUNT(*)
                       FROM Orders o2
                                JOIN [Order Details] od2 on o2.OrderID = od2.OrderID
                       WHERE o2.CustomerID = @CustomerID
                         AND od2.ProductID = od.ProductID
                         AND o2.OrderDate < o.OrderDate
                       ) = 0 THEN 0
                WHEN (SELECT COUNT(*)
                       FROM Orders o2
                                JOIN [Order Details] od2 on o2.OrderID = od2.OrderID
                       WHERE o2.CustomerID = @CustomerID
                         AND od2.ProductID = od.ProductID
                         AND o2.OrderDate < o.OrderDate
                       ) BETWEEN 1 AND 2 THEN 0.05
                WHEN (SELECT COUNT(*)
                       FROM Orders o2
                                JOIN [Order Details] od2 on o2.OrderID = od2.OrderID
                       WHERE o2.CustomerID = @CustomerID
                         AND od2.ProductID = od.ProductID
                         AND o2.OrderDate < o.OrderDate
                       ) = 3 THEN 0.1
            ELSE 0.2
            END
        FROM [Order Details] od
        JOIN Orders o on o.OrderID = od.OrderID
        WHERE o.CustomerID = @CustomerID
    COMMIT
END
GO
EXEC UpdateDiscount @CustomerID = N'ALFKI';

------------- przydatene !!!
SELECT
    o.CustomerID,
    od.ProductID,
    o.OrderID,
    o.OrderDate,
    rn = ROW_NUMBER() OVER (
        PARTITION BY o.CustomerID, od.ProductID
        ORDER BY o.OrderDate, o.OrderID
    )
FROM Orders o
JOIN [Order Details] od
    ON od.OrderID = o.OrderID
FROM Orders





----------------------------------- Sc #1, Transakcje



