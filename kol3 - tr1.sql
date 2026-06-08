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


