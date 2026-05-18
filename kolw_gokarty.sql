CREATE TABLE GOKARTY
(id int IDENTITY(1,1) NOT NULL, model nvarchar(100), opis nvarchar(MAX), data_zakupu datetime, cena_za_godzine money, stan_magazynu int, wartosc_zapasow money,
CONSTRAINT PK_Gokarty PRIMARY KEY(id)
)
go