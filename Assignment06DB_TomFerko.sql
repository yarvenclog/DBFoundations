--*************************************************************************--
-- Title: Assignment06
-- Author: TomFerko
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,TomFerko,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_TomFerko')
	 Begin 
	  Alter Database [Assignment06DB_TomFerko] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_TomFerko;
	 End
	Create Database Assignment06DB_TomFerko;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_TomFerko;

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
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
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
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

go
create -- drop
view vCategories
	with schemabinding
as
	select CategoryID, CategoryName from dbo.Categories
;
go

create -- drop
view vProducts
	with schemabinding
as
	select ProductID, ProductName, CategoryID, UnitPrice from dbo.Products
;
go

create -- drop
view vEmployees
	with schemabinding
as
	select EmployeeID, EmployeeFirstName,EmployeeLastName, ManagerID from dbo.Employees
;
go

create -- drop
view vInventories
	with schemabinding
as
	select InventoryID, InventoryDate,EmployeeID, ProductID, Count from dbo.Inventories
;
go

Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go
-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

grant select on vCategories to Public
deny select on Categories to Public

grant select on vProducts to Public
deny select on Products to Public

grant select on vEmployees to Public
deny select on Employees to Public

grant select on vInventories to Public
deny select on Inventories to Public

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

go
create -- drop
view vProductsAndPrice
as
	select top 100000000
		CategoryName, ProductName, UnitPrice from Products
	join Categories on Categories.CategoryID = Products.CategoryID
	order by CategoryName asc, ProductName asc
;
go

select * from vProductsAndPrice

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
go
create --drop
view vProductAndInventory
as
	select top 1000000
		ProductName, sum(Count) as Count, InventoryDate from Inventories
	join Products on Products.ProductID = Inventories.ProductID
	group by InventoryDate, ProductName
	order by ProductName, InventoryDate, Count
;
go

select * from vProductAndInventory


-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

go
create --drop
view vInventoryEmployeeCount
as
	select top 10000000 
		EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName, InventoryDate from Employees
	join Inventories on Inventories.EmployeeID = Employees.EmployeeID
	group by InventoryDate, EmployeeFirstName, EmployeeLastName
	order by InventoryDate asc
;
go

select * from vInventoryEmployeeCount

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

go
create --drop
view vProductCategoryInventory
as
	select top 1000000
		categoryName, ProductName, sum(Count) as Count, InventoryDate from Inventories
	join Products on Products.ProductID = Inventories.ProductID
	join Categories on Products.CategoryID = Categories.CategoryID
	group by InventoryDate, CategoryName, ProductName
	order by CategoryName, ProductName, InventoryDate, Count
;
go

select * from vProductCategoryInventory
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

go
create --drop
view vProductCategoryInventoryEmployee
as
	select top 1000000
		categoryName, ProductName, sum(Count) as Count, InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName 
		from Inventories
	join Products on Products.ProductID = Inventories.ProductID
	join Categories on Products.CategoryID = Categories.CategoryID
	join Employees on Employees.EmployeeID = Inventories.EmployeeID
	group by ProductName, InventoryDate, CategoryName, ProductName, EmployeeFirstName, EmployeeLastName
	order by InventoryDate, CategoryName, ProductName, Count, EmployeeFirstName, EmployeeLastName
;
go

select * from vProductCategoryInventoryEmployee
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

go
create --drop
view vChaiChangInventory
as
	select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		from Employees
	join Inventories on Inventories.EmployeeID = Employees.EmployeeID
	join Products on Products.ProductID = Inventories.ProductID
	join Categories on Categories.CategoryID = Products.ProductID
	where ProductName in ('Chai','Chang')

;
go

select * from vChaiChangInventory

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
go
create --drop
view vEmployeeManager
as
	select m.EmployeeFirstName + ' ' + m.EmployeeLastName as ManagerName
		, e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName 
		from Employees as e
	inner join Employees as m on m.EmployeeID = e.ManagerID

;
go

select * from vEmployeeManager
-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?
go
create -- drop
view vAllViews
as
	select Categories.CategoryID, CategoryName, Products.ProductID, ProductName, UnitPrice, Inventories.InventoryID
		, InventoryDate, Count, m.EmployeeFirstName + ' ' + m.EmployeeLastName as ManagerName
		, e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
		from Categories
		join Products on Products.CategoryID = Categories.CategoryID
		join Inventories on Inventories.ProductID = Products.ProductID
		join Employees as e on Inventories.EmployeeID = e.EmployeeID
		join employees as m on m.EmployeeID = e.ManagerID

; 
go


select * from vAllViews
-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From vProductsAndPrice
Select * From vProductAndInventory
Select * From vInventoryEmployeeCount
Select * From vProductCategoryInventory
Select * From vProductCategoryInventoryEmployee
Select * From vChaiChangInventory
Select * From vEmployeeManager
Select * From vAllViews
/***************************************************************************************/