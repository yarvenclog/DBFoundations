--*************************************************************************--
-- Title: Assignment05
-- Author: TomFerko
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log: When,Who,What
-- 2020-08-08,TomFerko,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_TomFerko')
 Begin 
  Alter Database [Assignment05DB_TomFerko] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_TomFerko;
 End
go

Create Database Assignment05DB_TomFerko;
go

Use Assignment05DB_TomFerko;
go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go


Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

begin tran
	select CategoryName, ProductName, UnitPrice from Categories
		join Products on Products.CategoryID = Categories.CategoryID
		order by CategoryName, ProductName asc
commit tran
;
go


-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

begin tran
	select ProductName, InventoryDate, sum(Count) as Total from Inventories
		join Products on Products.ProductID = Inventories.ProductID
		group by InventoryDate, ProductName
		order by InventoryDate, ProductName, Count asc
commit tran
;
go




-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Select EmployeeID from Employees
--select (EmployeeFirstName + ' ' + EmployeeLastName) as employee from Employees


begin tran
	select InventoryDate, sum(Count) as [Total Counted], (select (EmployeeFirstName + ' ' + EmployeeLastName)) as Employee from Inventories
		join Employees on Employees.EmployeeID = Inventories.EmployeeID
		group by InventoryDate, EmployeeFirstName, EmployeeLastName
		order by InventoryDate asc
commit tran
;
go


-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

begin tran
	select CategoryName, ProductName, InventoryDate, Count from Inventories
		join Products on Products.ProductID = Inventories.ProductID
		join Categories on Products.CategoryID = Categories.CategoryID
		order by CategoryName asc, ProductName asc, InventoryDate asc, Count asc

commit tran
;
go



-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

begin tran
	select CategoryName, ProductName, InventoryDate, Count, (select (EmployeeFirstName + ' ' + EmployeeLastName)) as Employee 
	from Employees
		join Inventories on Inventories.EmployeeID = Employees.EmployeeID
		join Products on Products.ProductID = Inventories.ProductID
		join Categories on Products.CategoryID = Categories.CategoryID
		order by InventoryDate asc, CategoryName asc, ProductName asc, Employee asc
commit tran
;
go


-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

begin tran
	select CategoryName, ProductName, InventoryDate, Count, (select (EmployeeFirstName + ' ' + EmployeeLastName)) as Employee 
	from Inventories
		join Employees on Inventories.EmployeeID = Employees.EmployeeID
		join Products on Inventories.ProductID = Products.ProductID
		join Categories on Categories.CategoryID = Products.CategoryID
		where Products.ProductID in (select ProductID from Products where ProductName in ('Chai', 'Chang'))
		order by InventoryDate asc, CategoryName asc, ProductName asc
commit tran
;
go



-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--select * from Northwind.dbo.Employees

begin tran
	select (m.EmployeeFirstName + ' ' + m.EmployeeLastName) as Manager
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) as Employee
	from Employees as e
	inner join Employees m on m.EmployeeID = e.ManagerID
	order by Manager asc, Employee asc
commit tran
; 
go


/***************************************************************************************/