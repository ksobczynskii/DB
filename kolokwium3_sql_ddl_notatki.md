# Kolokwium 3 — SQL / DDL / procedury / transakcje

Materiał do druku na kolokwium. Plik powstał z przesłanych skryptów SQL i DDL.

## Spis treści

1. Miniściąga składni T-SQL
2. DDL — baza `edu_courses`
3. ALTER TABLE i ograniczenia
4. Dane testowe
5. Indeksy
6. Procedura `SignUpForCourse`
7. DDL — schematy `fact` i `dim`
8. Funkcje okna: `SUM() OVER`, `ROW_NUMBER()`
9. Transakcje i procedury
10. Pułapki / rzeczy do zapamiętania

---

## 1. Miniściąga składni T-SQL

### Tworzenie bazy i przełączanie kontekstu

```sql
CREATE DATABASE nazwa_bazy;
GO

USE nazwa_bazy;
GO
```

### Tworzenie tabeli

```sql
CREATE TABLE nazwa_tabeli (
    id INT IDENTITY(1,1),
    nazwa NVARCHAR(100) NOT NULL,
    cena MONEY,
    aktywny BIT DEFAULT 1,
    CONSTRAINT PK_nazwa PRIMARY KEY (id)
);
```

### Klucz obcy

```sql
CONSTRAINT FK_dziecko_rodzic
FOREIGN KEY (kolumna_id) REFERENCES tabela_rodzic(kolumna_id)
```

### CHECK

```sql
ALTER TABLE tabela
ADD CONSTRAINT CH_nazwa CHECK (data_start < data_end);
```

### Indeks

```sql
CREATE INDEX IX_tabela_kolumna
ON tabela(kolumna);
```

### Indeks unikalny

```sql
CREATE UNIQUE INDEX UX_tabela_email
ON tabela(email);
```

### Transakcja z TRY/CATCH

```sql
BEGIN TRY
    BEGIN TRANSACTION;

    -- operacje INSERT / UPDATE / DELETE

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    THROW;
END CATCH;
```

### JOIN w UPDATE

```sql
UPDATE alias_tabeli
SET kolumna = nowa_wartosc
FROM tabela alias_tabeli
JOIN inna_tabela i ON i.id = alias_tabeli.id
WHERE warunek;
```

### DELETE z JOIN-em

```sql
DELETE alias_tabeli
FROM tabela alias_tabeli
JOIN inna_tabela i ON i.id = alias_tabeli.id
WHERE warunek;
```

### Funkcje okna

```sql
SUM(wartosc) OVER (
    PARTITION BY grupa
    ORDER BY data
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS suma_narastajaco
```

---

## 2. DDL — baza `edu_courses`

Ten fragment tworzy bazę kursów: kursy, grupy, plan zajęć, użytkowników i zapisy na kursy.

Najważniejsze relacje:

- `grupa.course_id` wskazuje na `course.course_id`,
- `course_enrollment.user_id` wskazuje na `users.user_id`,
- `course_enrollment.group_id` wskazuje na `grupa.group_id`.


```sql
---------- zad 1

----- a)


CREATE DATABASE edu_courses
go

Use edu_courses
go

CREATE TABLE course
(
    course_id int IDENTITY (1,1),
    course_name nvarchar(100),
    base_price money,
    planned_groups_amount int DEFAULT 1,
    date_start date,
    date_end date,
    is_active bit default 1,
    CONSTRAINT PK_course PRIMARY KEY (course_id)
)

CREATE TABLE grupa(
    group_id int IDENTITY (1,1),
    group_type nvarchar(25) default 'zajęciowa',
    course_id int,
    max_group_capacity int,
    CONSTRAINT PK_group PRIMARY KEY(group_id),
    CONSTRAINT FK_group_course FOREIGN KEY (course_id) REFERENCES course(course_id)
)

CREATE TABLE group_timetable(
    group_id int,
    room nvarchar(10),
    datetime_start datetime,
    datetime_end datetime,
    CONSTRAINT FK_groupttb_group FOREIGN KEY(group_id) REFERENCES grupa(group_id)
)

CREATE TABLE users(
    user_id integer IDENTITY(1,1),
    email nvarchar(255),
    first_name nvarchar(200),
    last_name nvarchar(200),
    is_active bit,
    age int,
    CONSTRAINT PK_users PRIMARY KEY(user_id)
)
CREATE TABLE course_enrollment
(
    user_id int ,
    group_id int,
    enrollment_date date,
    total_cost money,
    discount_type varchar(100) default 'bezwarunkowy',
    discount_value money,
    is_completed bit default 0,
    is_dropped bit default 0,
    CONSTRAINT FK_ce_user FOREIGN KEY(user_id) REFERENCES users(user_id),
    CONSTRAINT FK_ce_group FOREIGN KEY(group_id) REFERENCES grupa(group_id)
)
go
```

---

## 3. ALTER TABLE i ograniczenia

Tutaj dodawana jest kolumna `phone_number`, usuwana kolumna `age` oraz dodawany warunek poprawności dat kursu.


```sql
--------- b)

ALTER TABLE users
ADD phone_number varchar(25)

ALTER TABLE users
DROP COLUMN age

ALTER TABLE course
ADD CONSTRAINT CH_course_dates CHECK(date_start < date_end)
go
```

**Do zapamiętania:** `CHECK(date_start < date_end)` pilnuje, żeby kurs nie kończył się przed rozpoczęciem.

---

## 4. Dane testowe

Przykładowe inserty po 3 rekordy do każdej tabeli. Przydatne, gdy trzeba szybko pokazać, że schemat działa.


```sql
--------- c)
USE edu_courses;
GO

INSERT INTO users
    (email, first_name, last_name, is_active, phone_number)
VALUES
    ('jan.kowalski@mail.com', 'Jan', 'Kowalski', 1, '123456789'),
    ('anna.nowak@mail.com', 'Anna', 'Nowak', 1,  '987654321'),
    ('piotr.zielinski@mail.com', 'Piotr', 'Zielinski', 1,  '555666777');
GO


INSERT INTO course
    (course_name, base_price, planned_groups_amount, date_start, date_end, is_active)
VALUES
    ('SQL podstawy', 1200.00, 2, '2026-07-01', '2026-08-01', 1),
    ('Programowanie w C#', 1800.00, 3, '2026-07-10', '2026-09-10', 1),
    ('JavaScript od podstaw', 1500.00, 2, '2026-08-01', '2026-09-15', 1);
GO


INSERT INTO grupa
    (group_type, course_id, max_group_capacity)
VALUES
    ('stacjonarna', 1, 15),
    ('zajeciowa', 2, 20),
    ('online', 3, 25);
GO


INSERT INTO group_timetable
    (group_id, room, datetime_start, datetime_end)
VALUES
    (1, 'A101', '2026-07-01 10:00:00', '2026-07-01 12:00:00'),
    (2, 'B202', '2026-07-10 14:00:00', '2026-07-10 16:00:00'),
    (3, 'ONLINE', '2026-08-01 18:00:00', '2026-08-01 20:00:00');
GO


INSERT INTO course_enrollment
    (user_id, group_id, enrollment_date, total_cost, discount_type, discount_value, is_completed, is_dropped)
VALUES
    (1, 1, '2026-06-20 09:30:00', 1200.00, 'bezwarunkowy', 0.00, 0, 0),
    (2, 2, '2026-06-21 11:15:00', 1600.00, 'promocja', 200.00, 0, 0),
    (3, 3, '2026-06-22 13:45:00', 1350.00, 'student', 150.00, 0, 0);
GO
```

---

## 5. Indeksy

Indeksy z pliku:

| Indeks | Tabela | Kolumny | Po co |
|---|---|---|---|
| `i1_users_enrollment` | `course_enrollment` | `user_id` | szybkie wyszukiwanie zapisów użytkownika |
| `i1_users_email` | `users` | `email` | unikalność i szybkie szukanie po emailu |
| `i1_course_start_end` | `course` | `date_start, date_end` | filtrowanie po zakresie dat kursu |
| `ic_course_enrollment` | `course_enrollment` | `user_id, group_id` | złożony indeks unikalny/klastrowany |
| `i2_users_name_filter` | `users` | `first_name, last_name` | filtrowanie po imieniu i nazwisku |


```sql
---------------- 2 - Indeksy

CREATE INDEX i1_users_enrollment
ON course_enrollment(user_id)
go

CREATE UNIQUE INDEX i1_users_email
ON users(email)
go

CREATE INDEX i1_course_start_end
ON course(date_start,date_end)
go

CREATE UNIQUE CLUSTERED INDEX ic_course_enrollment
ON course_enrollment(user_id, group_id)
go


CREATE INDEX i2_users_name_filter
ON users(first_name, last_name)
go
```

**Uwaga:** indeks złożony `(first_name, last_name)` najlepiej pomaga dla zapytań po `first_name` albo po `first_name + last_name`. Dla samego `last_name` może być mniej przydatny.

---

## 6. Procedura `SignUpForCourse`

Cel procedury:

1. Sprawdza, czy kurs istnieje i jest aktywny.
2. Szuka pierwszej grupy z wolnym miejscem.
3. Sprawdza, czy użytkownik istnieje. Jeśli nie istnieje — dodaje go.
4. Blokuje zapis użytkownika nieaktywnego.
5. Liczy rabat zależny od liczby wcześniejszych zapisów.
6. Dodaje rekord do `course_enrollment`.
7. Całość robi w transakcji z `TRY/CATCH`.


```sql
-------------- 3 - Procedura


CREATE PROCEDURE SignUpForCourse(
    @email nvarchar(255),
    @course_id int
)
AS
BEGIN

--     DECLARE group_cursor CURSOR FOR
--     SELECT group_id, COUNT(*) as enrolled
--     FROM course_enrollment
--     GROUP BY group_id


    DECLARE @empty_group_id int --, @group_id int, @group_enrollment int;

--     open group_cursor
    set transaction isolation level read committed
    BEGIN TRY
        BEGIN TRANSACTION
        if((SELECT COUNT(*) FROM course WHERE course_id = @course_id AND is_active = 1) != 1)
        BEGIN
            PRINT('There is no such active course')
            ROLLBACK
            RETURN
        end
        ELSE
        BEGIN
    --         FETCH NEXT FROM group_cursor into @group_id, @group_enrollment
    --
    --         WHILE @@FETCH_STATUS = 0
    --         BEGIN
    --             if((SELECT COUNT(*) FROM grupa WHERE group_id = @group_id) < @group_enrollment)
    --             BEGIN
    --                 SET @empty_group_id = @group_id
    --                 BREAK;
    --             end
    --         end
            SELECT TOP (1) @empty_group_id = g.group_id

            FROM grupa g

            LEFT JOIN course_enrollment ce

                ON ce.group_id = g.group_id

            WHERE g.course_id = @course_id

            GROUP BY g.group_id, g.max_group_capacity

            HAVING COUNT(ce.user_id) < g.max_group_capacity

            ORDER BY g.group_id;
        end


        if(@empty_group_id is null)
            BEGIn
                PRINT('No Empty Group Available')
                ROLLBACK
                RETURN
            end

        if((SELECT COUNT(*) FROM users WHERE email = @email)=1)
        BEGIN
            if((SELECT COUNT(*) FROM users WHERE email = @email AND is_active=0)=1)
            BEGIN
                PRINT('Inactive User')
                ROLLBACK
                RETURN
            end
        end
        ELSE
        BEGIN
            INSERT INTO users
            (email, is_active)
            VALUES (@email, 1)
        END

        DECLARE @user_id INT;

        SELECT @user_id = user_id
        FROM users
        WHERE email = @email;

        DECLARE @discount money =
            (
                CASE WHEN(SELECT COUNT(*) FROM course_enrollment WHERE user_id = @user_id) = 0
                    THEN 100

                    WHEN (SELECT COUNT(*) FROM course_enrollment WHERE user_id = @user_id) = 1
                    THEN (SELECT TOP(1) base_price FROM course WHERE course_id = @course_id) * 0.05

                    ELSE (SELECT COUNT(*) FROM course_enrollment WHERE user_id = @user_id) * 0.01 * (SELECT TOP(1) base_price FROM course WHERE course_id = @course_id)
                END
            )
        DECLARE @typ_rabatu varchar(100) =
            (
                CASE WHEN(SELECT COUNT(*) FROM course_enrollment WHERE user_id = @user_id) = 0
                    THEN 'bezwarunkowy'

                    WHEN (SELECT COUNT(*) FROM course_enrollment WHERE user_id = @user_id) = 1
                    THEN 'stały'

                    ELSE 'lojalnościowy'
                END
            )

        INSERT INTO course_enrollment
            (user_id, group_id, enrollment_date, total_cost, discount_value, discount_type)
        VALUES (@user_id, @empty_group_id, GETDATE(), (SELECT TOP(1) base_price FROM course WHERE course_id = @course_id) - @discount, @discount, @typ_rabatu )

        COMMIT
    PRINT('Pomyślnie dodano!')
    END TRY
    BEGIN CATCH
        Print('Błąd!')
        ROLLBACK
        THROW
    end catch
end


EXEC SignUpForCourse 'jas.sosen@gmail.com',2
go
```

**Na kolokwium warto umieć wytłumaczyć:**

- `SELECT TOP (1) @empty_group_id = ...` przypisuje do zmiennej pierwszą pasującą grupę,
- `LEFT JOIN` pozwala uwzględnić też grupy bez zapisanych osób,
- `HAVING COUNT(ce.user_id) < g.max_group_capacity` sprawdza pojemność grupy,
- `ROLLBACK` wycofuje zmiany po błędzie albo po niespełnionym warunku,
- `THROW` przekazuje błąd dalej.

---

## 7. DDL — schematy `fact` i `dim`

To wygląda jak prosty model hurtowniany / gwiazda:

- `fact.Orders` — tabela faktów, czyli zamówienia/pozycje zamówień,
- `dim.Customers` — wymiar klientów,
- `dim.Products` — wymiar produktów.


```sql
create schema [fact]
GO

create schema [dim]
GO
-----

CREATE TABLE [fact].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [nchar](5) NULL,
	[EmployeeID] [int] NULL,
	[OrderDate] [datetime] NULL,
	[RequiredDate] [datetime] NULL,
	[ShippedDate] [datetime] NULL,
	[ShipVia] [int] NULL,
	[Freight] [money] NULL,
	[ShipName] [nvarchar](40) NULL,
	[ShipAddress] [nvarchar](60) NULL,
	[ShipCity] [nvarchar](15) NULL,
	[ShipRegion] [nvarchar](15) NULL,
	[ShipPostalCode] [nvarchar](10) NULL,
	[ShipCountry] [nvarchar](15) NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [fact].[Orders]  WITH NOCHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])
REFERENCES dim.[Customers] ([CustomerID])
GO


ALTER TABLE [fact].[Orders]  WITH NOCHECK ADD  CONSTRAINT [FK_Orders_Products] FOREIGN KEY([ProductID])
REFERENCES dim.[Products] ([ProductID])
GO



--------------------------------------


CREATE TABLE dim.[Customers](
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE dim.[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[SupplierID] [int] NULL,
	[CategoryID] [int] NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	[ReorderLevel] [smallint] NULL,
	[Discontinued] [bit] NOT NULL,
CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
```

**Uwaga praktyczna:** w tym skrypcie klucze obce do `dim.Customers` i `dim.Products` są dodawane przed utworzeniem tych tabel. W realnym wykonaniu SQL Server może zgłosić błąd, jeśli tabele wymiarów jeszcze nie istnieją. Bezpieczna kolejność to najpierw `dim.Customers` i `dim.Products`, potem `fact.Orders`, a na końcu `ALTER TABLE ... ADD CONSTRAINT FK`.

---

## 8. Funkcje okna: `SUM() OVER`, `ROW_NUMBER()`

### 8.1. Suma miesięczna i suma narastająca sprzedaży produktu

`PARTITION BY ProductID, year` oznacza: licz osobno dla każdego produktu i roku.

`ORDER BY month` oznacza: narastająco miesiąc po miesiącu.

`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` oznacza: od początku partycji do aktualnego wiersza.


```sql
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
```

### 8.2. Schemat myślenia przy funkcjach okna

```sql
FUNKCJA(...) OVER (
    PARTITION BY kolumna_grupująca
    ORDER BY kolumna_sortująca
    ROWS BETWEEN ... AND ...
)
```

- `PARTITION BY` dzieli dane na niezależne grupy.
- `ORDER BY` ustala kolejność wewnątrz grupy.
- `ROWS BETWEEN` wybiera okno wierszy, np. ostatnie 3 wiersze.

---

## 9. Transakcje i procedury

### 9.1. Archiwizacja starych zamówień

Procedura przenosi stare zamówienia i szczegóły zamówień do tabel archiwalnych, a potem usuwa je z głównych tabel.


```sql
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
```

**Ważna kolejność przy usuwaniu:** najpierw usuwasz rekordy z tabeli zależnej, czyli `[Order Details]`, potem z tabeli nadrzędnej, czyli `Orders`. Inaczej klucz obcy może zablokować usunięcie.

### 9.2. Transakcja przy rezerwacji kilku wycieczek


```sql
CREATE TABLE [Tabela Wycieczek]
(tour_id INT NOT NULL, tour_date DATE NOT NULL, location NVARCHAR(100), numberofpersons int,
    CONSTRAINT PK_Constraint PRIMARY KEY
(
tour_id
))

CREATE PROCEDURE BookHotel
    @tour_id1 int = NULL,
    @tour_id2 int = NULL,
    @tour_id3 int = NULL
AS
BEGIN
    set transaction
    isolation level
    read committed
    BEGIN TRANSACTION
    UPDATE tw
    SET numberofpersons = numberofpersons + 1
    FROM [Tabela Wycieczek] tw
    WHERE tw.tour_id IN (@tour_id1, @tour_id2, @tour_id3)
    COMMIT
end

----------------- Istnieje ryzyko zakleszczenia gdybyśmy rozpatrywali kwerendy jedna po jednej, u nas kwerenda update blokuje rekordy,
-------- wiec jedna na raz ma wszystkie 3. ale w optymalnym rozwiazaniu powinno się sortować po id zeby brac od najmniejszego.
```

**Zakleszczenie / deadlock:** ryzyko rośnie, gdy dwie transakcje biorą te same rekordy, ale w różnej kolejności. Typowy trik: zawsze aktualizować rekordy w tej samej kolejności, np. po rosnącym `tour_id`.

---

## 10. Pułapki / rzeczy do zapamiętania

### `COUNT(*)` kontra `COUNT(kolumna)`

- `COUNT(*)` liczy wszystkie wiersze.
- `COUNT(kolumna)` liczy tylko wiersze, gdzie `kolumna IS NOT NULL`.
- Przy `LEFT JOIN` często lepiej dać `COUNT(ce.user_id)`, bo wtedy puste dopasowania nie są liczone jako zapisane osoby.

### `WHERE` kontra `HAVING`

- `WHERE` filtruje przed grupowaniem.
- `HAVING` filtruje po grupowaniu, np. po `COUNT`, `SUM`, `AVG`.

```sql
SELECT group_id, COUNT(*)
FROM course_enrollment
GROUP BY group_id
HAVING COUNT(*) < 10;
```

### `BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`

- `BEGIN TRANSACTION` zaczyna transakcję.
- `COMMIT` zatwierdza zmiany.
- `ROLLBACK` cofa zmiany od początku transakcji.

### Poziomy izolacji — bardzo krótko

| Poziom | Co dopuszcza / blokuje | Kiedy kojarzyć |
|---|---|---|
| `READ UNCOMMITTED` | pozwala czytać niezatwierdzone dane | bardzo ryzykowne odczyty, dirty reads |
| `READ COMMITTED` | czytasz tylko zatwierdzone dane | domyślny, najczęstszy |
| `REPEATABLE READ` | ten sam rekord nie zmieni się w trakcie transakcji | gdy kilka razy czytasz te same rekordy |
| `SERIALIZABLE` | blokuje też pojawienie się nowych pasujących rekordów | najbezpieczniej, ale najwięcej blokad |
| `SNAPSHOT` | czytasz spójny obraz danych z początku transakcji | mniej blokowania przy odczytach |

### `UPDATE` z `CASE`

```sql
UPDATE tabela
SET kolumna = CASE
    WHEN warunek1 THEN wartosc1
    WHEN warunek2 THEN wartosc2
    ELSE wartosc_domyslna
END
WHERE warunek;
```

### `ROW_NUMBER()` do numerowania wystąpień

```sql
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
JOIN [Order Details] od ON od.OrderID = o.OrderID;
```

To daje numer kolejnego zakupu danego produktu przez danego klienta. Potem można na podstawie `rn` liczyć rabat.

---

## 11. Poprawiona wersja pomysłu z rabatem po kolejnym zakupie produktu

Zamiast wielokrotnie liczyć podzapytaniem wcześniejsze zamówienia, można użyć `ROW_NUMBER()` albo `COUNT() OVER`. Przykładowy schemat:

```sql
WITH numbered AS (
    SELECT
        od.OrderID,
        od.ProductID,
        rn = ROW_NUMBER() OVER (
            PARTITION BY o.CustomerID, od.ProductID
            ORDER BY o.OrderDate, o.OrderID
        )
    FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE o.CustomerID = @CustomerID
)
UPDATE od
SET Discount = CASE
    WHEN n.rn = 1 THEN 0
    WHEN n.rn BETWEEN 2 AND 3 THEN 0.05
    WHEN n.rn = 4 THEN 0.10
    ELSE 0.20
END
FROM [Order Details] od
JOIN numbered n
    ON n.OrderID = od.OrderID
   AND n.ProductID = od.ProductID;
```

Interpretacja: `rn = 1` to pierwszy zakup danego produktu przez klienta, `rn = 2` drugi itd.

---

## 12. Minimalny szablon procedury na kolokwium

```sql
CREATE OR ALTER PROCEDURE NazwaProcedury
    @parametr INT
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM tabela WHERE id = @parametr)
        BEGIN
            ROLLBACK;
            RETURN;
        END;

        -- właściwa logika

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH;
END;
GO
```
