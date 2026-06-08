---------------------- zapytanie # 19
with monthly_sales as (
    select
        p.ProductName,
        p.ProductID,
        year(o.OrderDate) as [year],
        month(o.OrderDate) as [month],
        sum(od.Quantity * p.UnitPrice) as monthly_total
    from Products p
    join [Order Details] od on p.ProductID = od.ProductID
    join Orders o on od.OrderID = o.OrderID
    group by
        p.ProductName,
        p.ProductID,
        year(o.OrderDate),
        month(o.OrderDate)
),
presql as (
    select
        ProductName,
        ProductID,
        [year],
        [month],
        monthly_total,
        sum(monthly_total) over (
            partition by ProductID, [year]
            order by [month]
            rows between unbounded preceding and current row
        ) as until_now_sum,
        row_number() over (
            partition by ProductID, [year]
            order by [month]
        ) as selling_months
    from monthly_sales
)
select *
from presql
order by ProductID, [year], [month]
go



-------------------- #18

SELECT o.OrderID, p.ProductID, od.Quantity * p.UnitPrice as ProductValue,
       SUM(od.Quantity * p.UnitPrice) OVER(
           order by o.OrderID, p.ProductID
           rows between 2 preceding and current row
           ) as last3sum
FROM Orders o
JOIN dbo.[Order Details] od on o.OrderID = od.OrderID
JOIN Products p on od.ProductID = p.ProductID
go




