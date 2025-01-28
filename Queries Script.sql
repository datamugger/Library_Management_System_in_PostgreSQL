-- part 1: https://www.youtube.com/watch?v=6X2-P9fNVvw 
-- part 2: https://www.youtube.com/watch?v=h-s_kQIqndg
-- Zero Analyst YouTube Channel

-- Library Management System using PostgreSQL

-- Task 1. Create a New Book Record 

-- ("978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher) VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

Select * from books where isbn = '978-1-60129-456-2'

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '321 Main St'
WHERE member_id = 'C101';

Select * from members where member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

Select * from issued_status where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT issued_id, issued_book_isbn, issued_book_name, issued_emp_id
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT *
FROM issued_status

SELECT A.issued_member_id, B.member_name
FROM issued_status A
JOIN members B ON A.issued_member_id = B.member_id
GROUP BY A.issued_member_id, B.member_name
HAVING COUNT(*) > 1;

SELECT issued_member_id
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(DISTINCT issued_book_isbn) > 1;


3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables: 
-- Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

-- Creating a new_table from an existing table based on conditions
-- Method 1: CREATE TABLE AS
CREATE TABLE book_issued_count AS
SELECT issued_book_name as book_name, COUNT(*) AS issued_count
FROM issued_status
GROUP BY issued_book_name;

select * from book_issued_count;
Drop table issued_status_copy;

-- Method 2: SELECT INTO 
SELECT issued_book_name as book_name, COUNT(*) AS issued_count INTO book_total
FROM issued_status
GROUP BY issued_book_name

select * from book_total;
Drop table book_total;


-- 4. Data Analysis & Findings
-- The following SQL queries were used to address specific questions:

-- Task 7: Retrieve All Books in a Specific Category:

SELECT * 
FROM books
WHERE category = 'Classic';


-- Task 8: Find Total Rental Income by Category:

SELECT A.category, A.rental_price, B.issued_id, B.issued_book_isbn
FROM books A
LEFT JOIN issued_status B
ON A.isbn = B.issued_book_isbn;

-- answer 1
SELECT A.category
, SUM(CASE WHEN B.issued_id IS NOT NULL THEN A.rental_price ELSE 0 END) AS total_rental_price 
FROM books A
LEFT JOIN issued_status B
	ON A.isbn = B.issued_book_isbn
GROUP BY A.category;

-- answer 2 (both have same answer)
SELECT B.category, SUM(B.rental_price) as total_rental_price
FROM issued_status A
LEFT JOIN books B
	ON A.issued_book_isbn = B.isbn
GROUP BY B.category;

-- Task 9: List Members Who Registered in the Last 180 Days:

Select current_date;

SELECT *
FROM members
WHERE CURRENT_DATE - INTERVAL '300 day' < reg_date;


-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT A.emp_name, A.branch_id, B.branch_id, B.manager_id, C.emp_id, C.emp_name, B.branch_address, B.contact_no
FROM employees A
JOIN branch B 
	ON A.branch_id = B.branch_id
JOIN employees C 
	ON B.manager_id = C.emp_id;


SELECT 
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


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE high_rental_books AS
SELECT *
FROM books
WHERE rental_price > 7;

Select * from high_rental_books;


-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT A.issued_book_name
FROM issued_status A
LEFT JOIN return_status B
	ON A.issued_id = B.issued_id
WHERE B.issued_id IS NULL;


-- =================== Advanced SQL Operations ==============

-- Task 13: Identify Members with Overdue Books

/*Write a query to identify members who have overdue books (assume a 30-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue.*/

-- Insert some records in issued_status table for this problem
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status
ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;

Select * from return_status;

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
	CASE WHEN C.issued_id IS NULL THEN (CURRENT_DATE - A.issued_date)
 	  ELSE (C.return_date - A.issued_date)
  	END AS Overdue_in_days
FROM issued_status A
JOIN members B
	ON A.issued_member_id = B.member_id
LEFT JOIN return_status C
	ON A.issued_id = C.issued_id
WHERE C.issued_id IS NULL -- 20 rows
OR A.issued_date + INTERVAL '30 day' < C.return_date; -- 34 rows
  

-- Task 14: Update Book Status on Return

/*Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).*/

-- When a book is issued, it is status is set to 'No' meaning it is not available for issuing
-- When returned, it's status must be set to 'Yes'

-- We want to create a function, that when a book is returned, should set the status to 'Yes' in books table

return_status(issued_id) <-> issued_status(issued_id, issued_book_isbn) <-> books(isbn)
Select * from return_status;
select * from issued_status;
select * from books;

-- Let's suppose a book = 'The Kite Runner' is being issued
select * from books where book_title = 'The Kite Runner'; -- right now, it's status is 'yes'

-- 1. insert a record in issued_status
select * from issued_status 
where issued_book_name = 'The Kite Runner';

-- 2. change book_status to 'no'
update books 
set status = 'no' 
where book_title = 'The Kite Runner';

select * from books where book_title = 'The Kite Runner'; -- after being issued, it's status is now changed to 'no'

-- When this book will be returned
--1. insert a record in return_status TABLE
INSERT INTO return_status(return_id, issued_id, return_date)
VALUES ('R123', 'IS115', CURRENT_DATE);

--2. change book status to 'yes' in books TABLE
update books 
set status = 'yes' 
where book_title = 'The Kite Runner'; -- after return, it's status is back to 'yes'

-- Doing it for multiple columns

-- first change the status to 'no' for issued book
select count(distinct isbn) from books; -- 35 distinct books
select count(distinct issued_book_isbn) from issued_status; -- 32 books are already issues

-- Below method was used by AlextheAnalyst in MySQL workbench. But, it won't work in PostgreSQL.
UPDATE `layoffs_staging2` t1
JOIN `layoffs_staging2` t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry is NULL
AND t2.industry IS NOT NULL;

UPDATE books B
JOIN issued_status I 
	ON I.issued_book_isbn = B.isbn
SET B.status = 'no'
WHERE B.status = 'yes';

-- Below method used by Ankit Bansal in SQL Server.
UPDATE emp 
SET dep_name = d.dept_name
FROM emp e
INNER JOIN dept d 
ON e.dept_id = d.dept_id;

-- Syntax for PostgreSQL

-- MySQL workbench syntax                      -- Corresponding PostgreSQL syntax
UPDATE vehicles_vehicle v                       UPDATE vehicles_vehicle v
JOIN shipments_shipment s                       SET price = s.price_per_vehicle
	ON v.shipment_id=s.id                       FROM shipments_shipment s
SET v.price=s.price_per_vehicle;                WHERE v.shipment_id = s.id;


UPDATE books B
SET status = 'no'    
FROM issued_status I 
WHERE
	I.issued_book_isbn = B.isbn
	AND B.status = 'yes'; -- 29 records updates

select * from books where status = 'yes'; -- now, books table has only 3 books available

-- Now, based on return_status table, set status='yes' in the books table

-- before running UPDATE statement, it is better to run SELECT statement to check the output
Select * 
--R.return_id, R.issued_id, R.return_date, I.issued_book_name, B.status
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
	 
select * from books where status = 'yes'; -- 17 books are available now

-- Creating Stored Procedure to do this job.

-- Since, we've to do changes in the database, we should use Store Procedure, not function

-- Creating a Store Procedure
-- As soon as a record is inserted in the return_status table, when a book is returned
-- We should also change the book status to 'yes' in books table

CREATE OR REPLACE procedure book_return(p_return_id varchar(10), p_issued_id varchar(10))
LANGUAGE plpgsql  
AS $$
DECLARE
	v_isbn varchar(50);
	v_book_name varchar(75);
BEGIN
	-- TASK 1: insert a record into return_status table based on user_input
	INSERT INTO return_status(return_id,issued_id, return_date)
	VALUES (p_return_id, p_issued_id, CURRENT_DATE);
	
	-- TASK 2: update book status to 'yes' in books table
	-- method 1:
	/*
	UPDATE books B 
	SET status = 'yes'
	FROM return_status R 
		JOIN issued_status I 
		ON R.issued_id = I.issued_id
	WHERE
		 I.issued_book_isbn = B.isbn
	*/
	
	-- method 2:
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

-- Let's check for issued_id = 'IS135'
select * from issued_status where issued_id = 'IS135';
select * from return_status where issued_id = 'IS135'; -- no record 

-- return_id will be taken care of by IDENTITY data type in SQL Server or SERIAL data type in PostgreSQL
-- but, here we are doing it manually, RS118 is the last value

CALL book_return('RS119', 'IS135'); -- NOTICE:  Thank you for returning the book: Sapiens: A Brief History of Humankind


-- Task 15: Branch Performance Report

/*Create a query that generates a performance report for each branch, showing the number of books
issued, the number of books returned, and the total revenue generated from book rentals.*/

branch, no_of_issued_books, no_of_returned_books, revenue
                                     books             
							        /     \
branch <-> employees <-> issued_status <-> return_status  
							 |
						   members
Select Count(*) from branch; -- 5 branch

Select count(distinct B.branch_id)
from issued_status A
join employees B
ON A.issued_emp_id = B.emp_id;

Select * from employees; -- (emp_id, branch_id)
Select * from issued_status; -- (issued_id,issued_book_isbn, issued_emp_id)
Select * from books; -- (isbn, rental_price)
Select * from return_status; -- (return_id, issued_id,)
Select * from members;

SELECT *
FROM issued_status I
JOIN employees E
	ON I.issued_emp_id = E.emp_id
JOIN books B
	ON I.issued_book_isbn = B.isbn 
JOIN return_status R
	ON I.issued_id = R.issued_id;


SELECT 
	E.branch_id,
	COUNT(issued_book_isbn) AS no_of_issued_books,
	COUNT(R.return_id) AS no_of_returned_books,
	SUM(B.rental_price) AS revenue
FROM issued_status I
LEFT JOIN employees E
	ON I.issued_emp_id = E.emp_id
LEFT JOIN books B
	ON I.issued_book_isbn = B.isbn 
LEFT JOIN return_status R
	ON I.issued_id = R.issued_id
GROUP BY E.branch_id;
	

-- Task 16: CTAS: Create a Table of Active Members

/*Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months.*/

select * from issued_status;
select * from members;

SELECT * 
FROM issued_status I
LEFT JOIN members M
ON I.issued_member_id = M.member_id;


-- Task 17: Find Employees with the Most Book Issues Processed

/* Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.*/

SELECT emp_name, branch_id, no_book_issued
FROM (
	SELECT E.emp_name, E.branch_id, COUNT(issued_id) AS no_book_issued
	, DENSE_RANK() OVER(ORDER BY COUNT(issued_id) DESC) DRNK
	FROM issued_status I
	LEFT JOIN employees E
		ON I.issued_emp_id = E.emp_id
	GROUP BY E.emp_name, E.branch_id
	ORDER BY 3 DESC
	) t
WHERE DRNK <=3;


-- Task 18: Identify Members Issuing High-Risk Books

/* Write a query to identify members who have issued books more than twice with the 
   status "damaged" in the books table. 
  Display the member name, book title, and the number of times they've issued damaged books.*/

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
	
SELECT * FROM return_status;

                                     books             
							        /     \
branch <-> employees <-> issued_status <-> return_status  
							 |
						   members
Select * from branch;
Select * from employees; 
Select * from books; 
Select * from issued_status; -- (issued_id, issued_member_id, issued_book_name, issued_date)
Select * from members; -- (member_id, member_name)
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
GROUP BY M.member_name;
-- wrong question, data is not according to question



-- Task 19: Stored Procedure 
/*
Objective: Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based
on its issuance. The procedure should function as follows: The stored procedure should take 
the book_id as an input parameter. The procedure should first check if the book is available 
(status = 'yes'). If the book is available, it should be issued, and the status in the books 
table should be updated to 'no'. If the book is not available (status = 'no'), the procedure 
should return an error message indicating that the book is currently not available.
*/
Select * from books; 
CREATE OR REPLACE PROCEDURE book_issue(p_book_id VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE
	v_book_status VARCHAR(15);
	v_book_name
BEGIN
	-- check book status
	SELECT status, book_title 
		INTO v_book_status, v_book_name
	FROM books
	WHERE isbn = p_book_id;
	
	IF (v_book_status = 'yes') THEN
	BEGIN
		-- issued the book and insert a record in issued_status
		-- we can create separate store procedure for inserting record into issued_status
		-- and call here
		-- CALL insert_in_issued_status(p_book_title);
		
		-- change the status to no in books
		UPDATE books
		SET status = 'no'
		WHERE isbn = v_book_id;
	END
	ELSE
	BEGIN
		RAISE NOTICE 'Book % is not available at the moment', v_book_name 
	END IF;
END
$$;


-- Task 20: Create Table As Select (CTAS) 
/*
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they 
have issued but not returned within 30 days. The table should include: The number of overdue books.
The total fines, with each day's fine calculated at $0.50. The number of books issued by each member.
The resulting table should show: Member ID Number of overdue books Total fines
*/

CREATE TABLE overdue_records AS
SELECT *
FROM issued_status I
JOIN books B
	ON I.issued_book_isbn = B.isbn
