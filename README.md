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

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/najirh/Library-System-Management---P2.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Animesh Mishra

This project showcases SQL skills essential for database management and analysis.

