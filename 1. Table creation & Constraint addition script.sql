-- ----------------------------- Library Management System ---------------------------------

-- Database and Table creation script 

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


-- TASK 4: ER Diagram for Relationship or Cardinality

-- branch to employee : 1:N
-- employee to issued_status: 1:N


-- TASK 5: Sequence for Deleting Table

                                     books             
							        /     \
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


-- TASK 6: Insert data into the tables

-- we can either use BULK INSERT command for postgresql (try giving file path in single quotes)
-- or Try Import/Export 

-- Since, there are dependencies. We have to uploade data according to dependency.

-- Insert data in the below order
-- branch --> books --> members --> employees -->issued_status --> return_status

Select * from branch;
Select * from books;
Select * from members;
Select * from employees;
Select * from issued_status;
Select * from return_status;