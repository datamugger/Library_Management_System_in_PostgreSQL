# Library Management System using SQL Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_management_system`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/datamugger/Library_Management_System_in_PostgreSQL/blob/main/Library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/datamugger/Library_Management_System_in_PostgreSQL/blob/main/Library%20ER-Diagram.png)

- **Database Creation**: Created a database named `library_management_system`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql

-- Reveiw the csv file
/*
branch       : 4 columns [branch_id, manager_id, branch_address, contact_no]
books        : 7 columns [isbn, book_title, category, rental_price, status, author, publisher]
employees    : 5 columns [emp_id, emp_name, position, salary, branch_id]
issued_status: 6 columns [issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id]
members      : 4 columns [member_id, member_name, member_address, reg_date]
return_status: 5 columns [return_id, issued_id, return_book_name, return_date, return_book_isbn]
*/

-- TASK 1: Creating Database and Tables

-- database
CREATE DATABASE library_management_system;

-- branch
Drop table if exists branch;
Create table branch (
	branch_id varchar(10),
	manager_id varchar(10),
	branch_address varchar(100),
	contact_no varchar(20)
);

-- books
Drop table if exists books;
Create table books (
	isbn varchar(20),        -- pk
	book_title varchar(75),  -- = MAX(LEN(B2:B36))
	category varchar(20),
	rental_price decimal(10,2),
	status varchar(15),
	author varchar(30),
	publisher varchar(50)
);

Alter table books
Alter Column rental_price type decimal(10,2);

-- members
Drop table if exists members;
Create table members (
	member_id varchar(10),
	member_name varchar(30),
	member_address varchar(100),
	reg_date date
);

-- employess
Drop table if exists employees;
Create table employees (
	emp_id	 varchar(10),
	emp_name varchar(30),
	position varchar(20),
	salary decimal(10,2),
	branch_id varchar(10) -- pk
);

Alter table employee
Alter Column salary type decimal(10,2);

-- issued_status (our transaction table)
Drop table if exists issued_status;
Create table issued_status (
	issued_id varchar(10),
	issued_member_id varchar(10), --fk
	issued_book_name varchar(75),
	issued_date date,
	issued_book_isbn varchar(25), --fk
	issued_emp_id varchar(10)     -- fk
);

-- return_status
Drop table if exists return_status;
Create table return_status (
	return_id varchar(10),         -- pk
	issued_id varchar(10),         -- fk
	return_book_name varchar(75),
	return_date date,
	return_book_isbn varchar(20)   -- fk
);

-- Query to find all tables present in the database
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema='public' 
AND table_type='BASE TABLE';
```

```sql
-- TASK 2: Adding Primary Key Constraints

-- Syntax
Alter table <table_name>
Add Primary Key(column_list);

-- if you want to give a name to your primary key, use below syntax
Alter table branch
Add Constraint pk_branch Primary Key(branch_id);

Alter table books
Add Constraint pk_books Primary Key (isbn);

Alter table employees
Add Constraint pk_employees Primary Key (emp_id);

Alter table issued_status
Add Constraint pk_issued_status Primary Key (issued_id);

Alter table members
Add Constraint pk_members Primary Key (member_id);

Alter table return_status
Add Constraint pk_return_status Primary Key (return_id);

-- run below query to check the 'is_nullable' column
SELECT * -- column_name, is_nullable
FROM information_schema.COLUMNS  
WHERE TABLE_NAME = 'issued_status';  
```

```sql
-- TASK 3: Adding Foreign Key Constraints

Alter table employees
Add Constraint fk_employees 
Foreign Key (branch_id) REFERENCES branch(branch_id);

Alter table issued_status
Add Constraint fk1_issued_status 
Foreign Key (issued_member_id) REFERENCES members(member_id);

Alter table issued_status
Add Constraint fk2_issued_status 
Foreign Key (issued_book_isbn) REFERENCES books(isbn);

Alter table issued_status
Add Constraint fk3_issued_status 
Foreign Key (issued_emp_id) REFERENCES employees(emp_id);

Alter table return_status
Add Constraint fk1_return_status 
Foreign Key (return_book_isbn) REFERENCES books(isbn);

Alter table return_status
Add Constraint fk2_return_status 
Foreign Key (issued_id) REFERENCES issued_status(issued_id);
	
-- ERROR: insert or update on table "return_status" violates foreign key constraint "fk1_return_status"
-- DETAIL: Key (return_book_isbn)=(NULL) is not present in table "books".
Alter table return_status
Drop constraint fk1_return_status; 
```

```sql
-- TASK 4: ER Diagram for Relationship or Cardinality

-- branch to employee : 1:N
-- employee to issued_status: 1:N


-- TASK 5: Sequence for Deleting Table

                                     books             
                                    /    \
branch <-> employees <-> issued_status <-> return_status  
                           |
                         members
						   
-- branch, books and members are independent
-- employees depends on branch
-- issued_status depends on members/books/employees
-- return_status depends on books and issued_status

-- Order of Deletion: return_status -> issued_status -> employees -> members, branch, books
DROP Table return_status;
DROP Table issued_status;
DROP Table employees;
DROP Table books;
```

```sql
-- TASK 6: Insert data into the tables

-- we can either use BULK INSERT command for postgresql (try giving file path in single quotes)
-- or Try Import/Export 

-- Since, there are dependencies. We should uploade data accordingly.

-- Insert data in the below sequence
-- branch --> books --> members --> employees -->issued_status --> return_status

Select * from branch;
Select * from books;
Select * from members;
Select * from employees;
Select * from issued_status;
Select * from return_status;
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books WHERE isbn = '978-1-60129-456-2';
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '321 Main St'
WHERE member_id = 'C101';

Select * from members where member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**

**Objective:** Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';

Select * from issued_status where issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**

**Objective:** Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

SELECT
  issued_id,
  issued_book_isbn,
  issued_book_name,
  issued_emp_id
FROM issued_status
WHERE issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**

**Objective:** Use GROUP BY to find members who have issued more than one book.

```sql
SELECT * FROM issued_status

SELECT issued_member_id
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(DISTINCT issued_book_isbn) > 1;


SELECT
  A.issued_member_id,
  B.member_name
FROM issued_status A
JOIN members B
  ON A.issued_member_id = B.member_id
GROUP BY A.issued_member_id, B.member_name
HAVING COUNT(*) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**:

Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
-- Creating a new_table from an existing table based on conditions

-- Method 1: CREATE TABLE AS
CREATE TABLE book_issued_count AS
SELECT 
  issued_book_name as book_name,
  COUNT(*) AS issued_count
FROM issued_status
GROUP BY issued_book_name;

SELECT * FROM book_issued_count;
DROP TABLE book_issued_count;

-- Method 2: SELECT INTO 
SELECT 
  issued_book_name as book_name,
  COUNT(*) AS issued_count 
INTO book_total
FROM issued_status
GROUP BY issued_book_name

SELECT * FROM book_total;
DROP TABLE book_total;

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

- **Task 7. Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

- **Task 8: Find Total Rental Income by Category**:

```sql
SELECT A.category, A.rental_price, B.issued_id, B.issued_book_isbn
FROM books A
LEFT JOIN issued_status B
ON A.isbn = B.issued_book_isbn;

-- answer 1
SELECT 
  A.category
  , SUM(CASE WHEN B.issued_id IS NOT NULL THEN A.rental_price ELSE 0 END) AS total_rental_price 
FROM books A
LEFT JOIN issued_status B
	ON A.isbn = B.issued_book_isbn
GROUP BY A.category;

-- answer 2 (both have same answer)
SELECT 
  B.category, 
  SUM(B.rental_price) AS total_rental_price,
  COUNT(*) AS rent_cnt
FROM issued_status A
LEFT JOIN books B
	ON A.issued_book_isbn = B.isbn
GROUP BY B.category;
```

- **Task 9. List Members Who Registered in the Last 180 Days**:
```sql
Select current_date;

SELECT * FROM members
WHERE CURRENT_DATE - INTERVAL '300 day' < reg_date;

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '300 days';
```

- **Task 10. List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT
	A.emp_id AS Employee_ID,
	A.emp_name AS Employee_Name,
	C.emp_name AS Manager_Name,
	B.branch_id,
	B.branch_address,
	B.contact_no
FROM employees A
JOIN branch B 
	ON A.branch_id = B.branch_id
JOIN employees C 
	ON B.manager_id = C.emp_id;
```

- **Task 11. Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

SELECT * FROM expensive_books;
```

- **Task 12: Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
	A.issued_book_name
FROM issued_status A
LEFT JOIN return_status B
	ON A.issued_id = B.issued_id
WHERE B.issued_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**

Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
-- Insert some records in issued_status table for this problem
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Adding new column book_quality with default value Good in return_status table
ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');

SELECT * FROM return_status;

-------

SELECT A.issued_id, A.issued_member_id, B.member_name, A.issued_book_name, A.issued_date
, A.issued_date + INTERVAL '30 day' AS return_date1
, A.issued_date + 30 AS return_date2
FROM issued_status A
JOIN members B
ON A.issued_member_id = B.member_id;


SELECT A.issued_id, A.issued_member_id, B.member_name, A.issued_book_name, A.issued_date
, A.issued_date + 30 AS return_date2
, C.return_id, C.issued_id, C.return_date
FROM issued_status A
JOIN members B
	ON A.issued_member_id = B.member_id
LEFT JOIN return_status C
	ON A.issued_id = C.issued_id;

-- answer
SELECT 
	A.issued_member_id,
	B.member_name,
	A.issued_date,
	A.issued_book_name,
	CASE
	     WHEN C.issued_id IS NULL THEN (CURRENT_DATE - (A.issued_date + INTERVAL + '30 Day'))
	     ELSE (C.return_date - A.issued_date)
	END AS Overdue_in_days
FROM issued_status A
JOIN members B
	ON A.issued_member_id = B.member_id
LEFT JOIN return_status C
	ON A.issued_id = C.issued_id
WHERE C.issued_id IS NULL                             -- 20 rows
OR A.issued_date + INTERVAL '30 day' < C.return_date; -- 34 rows
```


- **Task 14: Update Book Status on Return**
  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
-- When a book is issued, it's status is set to 'No' meaning it is not available for issuing.
-- When it's returned, the status must be set to 'Yes'

-- We want to create a function, which set the status to 'Yes' in books table when a book is returned.

return_status(issued_id) <-> issued_status(issued_id, issued_book_isbn) <-> books(isbn)

-- Suppose a customer wants to issue book = 'The Kite Runner'. So, it's status must be yes.
select * from books where book_title = 'The Kite Runner'; -- right now, it's status is 'yes'

-- 1. insert a record in issued_status table
insert into issued_status(<column names>) values (, , ,..);
select * from issued_status where issued_book_name = 'The Kite Runner';

-- 2. change book_status to 'no' in books table
update books 
set status = 'no' 
where book_title = 'The Kite Runner';

select * from books where book_title = 'The Kite Runner'; -- after being issued, it's status is now changed to 'no'

-- When this book will be returned
--1. insert a record in return_status table
INSERT INTO return_status(return_id, issued_id, return_date) VALUES ('R123', 'IS115', CURRENT_DATE);

--2. change book status to 'yes' in books table
update books 
set status = 'yes' 
where book_title = 'The Kite Runner'; -- after being returned, it's status is back to 'yes'

-- Sorting our given data, as it is not correct

-- first changing the status to 'no' for issued book 
select count(distinct isbn) from books;                     -- 35 distinct books
select count(distinct issued_book_isbn) from issued_status; -- 32 books were already issued

-- Since, we've to update a column based on values of a column of another table, we have to use JOIN with UPDATE

-- Below method was used by AlextheAnalyst in MySQL workbench. But, it won't work in PostgreSQL.
UPDATE `layoffs_staging2` t1
JOIN `layoffs_staging2` t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry is NULL
AND t2.industry IS NOT NULL;

-- MySQL workbench syntax                 -- Corresponding PostgreSQL syntax         -- SQL Server syntax used by Ankit Bansal
UPDATE vehicles_vehicle v                 UPDATE vehicles_vehicle v                  UPDATE emp 
JOIN shipments_shipment s                 SET price = s.price_per_vehicle            SET dep_name = d.dept_name
	ON v.shipment_id=s.id             FROM shipments_shipment s                  FROM emp e
SET v.price=s.price_per_vehicle;          WHERE v.shipment_id = s.id;                INNER JOIN dept d
                                                                                     ON e.dept_id = d.dept_id;

-- Setting status to 'no' in book table, when a book is issued
UPDATE books B
SET status = 'no'    
FROM issued_status I 
WHERE
	I.issued_book_isbn = B.isbn
	AND B.status = 'yes'; -- 29 records updated

select * from books where status = 'yes'; -- now, books table has only 3 books available

-- Meanwhile, books are also being returned, so we've to set their status to 'yes' in the book table based on return_status table
-- Before running an UPDATE statement, it is better to run SELECT statement to check the output

Select * 
FROM return_status R 
JOIN issued_status I 
	ON R.issued_id = I.issued_id
JOIN books B
    ON I.issued_book_isbn = B.isbn; -- 14 rows, so 14 books has been returned

UPDATE books B 
SET status = 'yes'
FROM return_status R 
	JOIN issued_status I 
	ON R.issued_id = I.issued_id
WHERE
     I.issued_book_isbn = B.isbn; -- Yes, 14 rows UPDATED
	 
select * from books where status = 'yes'; -- 14 + 3 = 17 books are available now

-- **Creating Stored Procedure to do this job.**

-- Since, we've to do changes in the database, we should use Store Procedure, not function
-- Task is, to insert a record for book being returned in return_status table and we should also change the book status to 'yes' in books table

-- answer
CREATE OR REPLACE PROCEDURE book_return(p_return_id varchar(10), p_issued_id varchar(10))
LANGUAGE plpgsql  
AS $$
DECLARE
	v_isbn varchar(50);
	v_book_name varchar(75);
BEGIN
	-- TASK 1: Insert a record into return_status table based on user_input
	INSERT INTO return_status(return_id, issued_id, return_date)
	VALUES (p_return_id, p_issued_id, CURRENT_DATE);
	
	-- TASK 2: Update book status to 'yes' in books table
	-- First, we've to extract book_id based on issued_id from issued_status table
	SELECT issued_book_isbn, issued_book_name
	INTO v_isbn, v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;
	
	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$

-- TESTING OUR STORE PROCEDURE

-- Let's check for issued_id = 'IS135'
select * from issued_status where issued_id = 'IS135';
select * from return_status where issued_id = 'IS135'; -- no record 

-- return_id will be taken care of by IDENTITY data type in SQL Server or SERIAL data type in PostgreSQL
-- but, here we are doing it manually, RS118 is the last value

CALL book_return('RS119', 'IS135');
-- NOTICE:  Thank you for returning the book: Sapiens: A Brief History of Humankind
```

- **Task 15: Branch Performance Report**
  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
                                     books
                                    /     \
branch <-> employees <-> issued_status <-> return_status  
                               |
                             members

Select Count(*) from branch; -- total 5 branches

Select count(distinct B.branch_id)
from issued_status A
join employees B
ON A.issued_emp_id = B.emp_id;

Select * from issued_status; -- (issued_id, issued_book_isbn, issued_emp_id)
Select * from employees;     -- (emp_id, branch_id)
Select * from branch;        -- (branch_id)
Select * from books;         -- (isbn, rental_price)
Select * from return_status; -- (return_id, issued_id,)

-- answer
CREATE TABLE branch_report 
AS 
SELECT 
	B.branch_id,
	B.manager_id
	COUNT(I.issued_book_isbn) AS no_of_issued_books,
	COUNT(R.return_id) AS no_of_returned_books,
	SUM(BK.rental_price) AS total_revenue
FROM issued_status I
LEFT JOIN employees E
	ON I.issued_emp_id = E.emp_id
LEFT JOIN branch as B
	ON B.branch_id = E.branch_id
LEFT JOIN books BK
	ON I.issued_book_isbn = BK.isbn 
LEFT JOIN return_status R
	ON I.issued_id = R.issued_id
GROUP BY B.branch_id;
	
SELECT * FROM branch_reports;
```

- **Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
CREATE TABLE active_members 
AS
SELECT *
FROM member 
WHERE member_id IN (
	SELECT DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month'
)

SELECT * FROM active_members;
```


- **Task 17: Find Employees with the Most Book Issues Processed**
 
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT emp_name, branch_id, no_book_issued
FROM (
	SELECT 
		E.emp_name
		, B.branch_id
		, COUNT(issued_id) AS no_book_issued
		, DENSE_RANK() OVER(ORDER BY COUNT(issued_id) DESC) AS DRNK
	FROM issued_status I
	LEFT JOIN employees E
		ON I.issued_emp_id = E.emp_id
	LEFT JOIN branch B 
		ON E.branch_id = E.branch_id
	GROUP BY E.emp_name, B.branch_id
	ORDER BY 3 DESC
	) t
WHERE DRNK <=3;
```

- **Task 18: Identify Members Issuing High-Risk Books**

Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
-- Adding new column 'book_quality' in return_status table

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
	
SELECT * FROM return_status;

-----------
                                     books             
                                   /      \
branch <-> employees <-> issued_status <-> return_status  
			     |				 
                           members

Select * from issued_status; -- (issued_id, issued_member_id, issued_book_name, issued_date)
Select * from members;       -- (member_id, member_name)
Select * from return_status; -- (return_id, issued_id, return_date, book_quality)

SELECT *
FROM issued_status I
LEFT JOIN members M
	ON I.issued_member_id = M.member_id
LEFT JOIN return_status R
	ON R.issued_id = I.issued_id;

-- member name, book title, and the number of times they've issued damaged books.
SELECT *
FROM issued_status I
LEFT JOIN members M
	ON I.issued_member_id = M.member_id
LEFT JOIN return_status R
	ON R.issued_id = I.issued_id
WHERE 
GROUP BY M.member_name; -- wrong question, data is not according to question
```

- **Task 19: Stored Procedure**
 
**Objective:** Create a stored procedure to manage the status of books in a library system.

**Description:**
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

Select * from books; 

-- CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
CREATE OR REPLACE PROCEDURE issue_book(p_book_id VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE
-- all the variables
	v_book_status VARCHAR(15);
	v_book_name
BEGIN
-- All the code
	-- check if book is avaiable
	SELECT status, book_title 
		INTO v_book_status, v_book_name
	FROM books
	WHERE isbn = p_book_id;
	
	IF (v_book_status = 'yes') THEN
	BEGIN
		-- Task1: issued the book and insert a record in issued_status
		-- we can create separate store procedure for inserting record into issued_status
		-- and call here
		-- CALL insert_in_issued_status(p_book_title);
		-- or
		--INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        	--VALUES
        	--(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
		
		-- Task 2: change the status to 'no' in books
		UPDATE books
		SET status = 'no'
		WHERE isbn = v_book_id;

		--RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;
	END
	ELSE
	BEGIN
		RAISE NOTICE 'Book % is not available at the moment', v_book_name 
	END IF;
END
$$;

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books WHERE isbn = '978-0-375-41398-8'
```

**Task 20: Create Table As Select (CTAS)**

**Objective:** Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

**Description:** Write a CTAS query to create a new table that lists each member and the books they 
have issued but not returned within 30 days. The table should include: 
the number of overdue books, total fines, with each day's fine calculated at $0.50 and 
the number of books issued by each member.

The resulting table should show: Member ID, Number of overdue books,  Total fines

```sql
-- We've 2 scenarios for overdue, if book is not returned past return_date (issued_date + 30 days)
-- and if book was returned past return_date

                                     books             
							        /     \
branch <-> employees <-> issued_status <-> return_status  
							 |
						   members

Select * from issued_status; -- (issued_id, issued_member_id, issued_book_name, issued_date)
Select * from members;       -- (member_id, member_name)
Select * from return_status; -- (return_id, issued_id, return_date)

CREATE TABLE overdue_records 
AS
SELECT 
	Member_id, COUNT(*) AS no_of_overdue_books, SUM(fine) AS total_fine
FROM 
(
SELECT
	M.member_id,
	M.member_name,
	I.issued_book_isbn,
	I.issued_book_name,
	I.issued_date, R.return_date,
	CASE WHEN R.return_date is NULL THEN (CURRENT_DATE - (I.issued_date + INTERVAL + '30 Day'))
		ELSE (R.return_date - (I.issued_date + INTERVAL '30 Days'))
	END AS overdue_in_days,
	0.5 * CASE WHEN R.return_date is NULL THEN (CURRENT_DATE - (I.issued_date + INTERVAL + '30 Day'))
		ELSE (R.return_date - (I.issued_date + INTERVAL '30 Days'))
	END AS fine
FROM issued_status I
LEFT JOIN members M 
	ON I.issued_member_id = M.member_id
LEFT JOIN return_status R 
	ON R.issued_date = I.issued_date
WHERE R.issued_id IS NULL                              -- condition for when book is not returned
OR R.return_date > I.issued_date + INTERVAL '30 Days'  -- condition for when book was returned past return_date
) t
GROUP BY member_id;
```
 
## Report

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## Author - Animesh Mishra

This project showcases SQL skills essential for database management and analysis.

