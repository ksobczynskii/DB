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



--------- b)

ALTER TABLE users
ADD phone_number varchar(25)

ALTER TABLE users
DROP COLUMN age

ALTER TABLE course
ADD CONSTRAINT CH_course_dates CHECK(date_start < date_end)
go

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