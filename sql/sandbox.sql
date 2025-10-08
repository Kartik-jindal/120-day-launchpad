PRAGMA foreign_keys = ON;

-- Customers
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (customer_id INTEGER PRIMARY KEY, name TEXT, created_at TEXT);
INSERT INTO customers VALUES
  (1,'Alice','2025-01-05'),
  (2,'Bob','2024-12-15'),
  (3,'Carol','2025-02-20'),
  (4,'Dan',NULL);

-- Orders
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER, status TEXT, created_at TEXT);
INSERT INTO orders VALUES
  (10,1,'paid','2025-02-10'),
  (11,1,'paid','2025-03-01'),
  (12,2,'cancelled','2025-02-05'),
  (13,3,'paid','2025-03-15'),
  (14,3,'pending','2025-03-20');

-- Order items
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (order_item_id INTEGER PRIMARY KEY, order_id INTEGER, sku TEXT, qty INTEGER, price REAL);
INSERT INTO order_items VALUES
  (1,10,'A',2,50.0),
  (2,10,'B',1,25.0),
  (3,11,'A',1,50.0),
  (4,12,'C',3,20.0),
  (5,13,'D',2,40.0),
  (6,14,'E',1,100.0);

-- LeetCode 175 sample
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Address;
CREATE TABLE Person (PersonId INTEGER PRIMARY KEY, FirstName TEXT, LastName TEXT);
CREATE TABLE Address (AddressId INTEGER PRIMARY KEY, PersonId INTEGER, City TEXT, State TEXT);
INSERT INTO Person VALUES (1,'John','Doe'),(2,'Jane','Roe'),(3,'Max','Mustermann');
INSERT INTO Address VALUES (101,1,'Seattle','WA'),(102,3,'Austin','TX');

-- LeetCode 181 sample
DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee (Id INTEGER PRIMARY KEY, Name TEXT, Salary INTEGER, ManagerId INTEGER);
INSERT INTO Employee VALUES
  (1,'Alice',1000,NULL),
  (2,'Bob',800,1),
  (3,'Carol',1200,1),
  (4,'Dan',900,2);
