--*************************************************************************--
-- Title: Assignment03DB_TomFerko
-- Author: TomFerko
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2017-01-01,TomFerko,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment03DB_TomFerko')
 Begin 
  Alter Database [Assignment03DB_TomFerko] set Single_user With Rollback Immediate;
  Drop Database Assignment03DB_TomFerko;
 End
go

Create Database Assignment03DB_TomFerko;
go

Use Assignment03DB_TomFerko;
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
,[UnitPrice] [money] NOT NULL
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Alter Table Categories 
 Add Constraint pkCategories 
  Primary Key (CategoryId);
go

Alter Table Categories 
 Add Constraint ukCategories 
  Unique (CategoryName);
go

Alter Table Products 
 Add Constraint pkProducts 
  Primary Key (ProductId);
go

Alter Table Products 
 Add Constraint ukProducts 
  Unique (ProductName);
go

Alter Table Products 
 Add Constraint fkProductsToCategories 
  Foreign Key (CategoryId) References Categories(CategoryId);
go

Alter Table Products 
 Add Constraint ckProductUnitPriceZeroOrHigher 
  Check (UnitPrice >= 0);
go

Alter Table Inventories 
 Add Constraint pkInventories 
  Primary Key (InventoryId);
go

Alter Table Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
go

Alter Table Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
go

Alter Table Inventories 
 Add Constraint ckInventoryCountZeroOrHigher 
  Check ([Count] >= 0);
go

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

Insert Into Inventories
(InventoryDate, ProductID, [Count])
Select '20170101' as InventoryDate, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNION
Select '20170201' as InventoryDate, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNION
Select '20170302' as InventoryDate, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show all of the data in the Categories, Products, and Inventories Tables
Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go

/********************************* Questions and Answers *********************************/
-- Question 1 (5 pts): Select the Category Id and Category Name of the Category 'Seafood'.
select CategoryID, CategoryName from Categories
	where CategoryID = 8
;
go 


--Select CategoryID,CategoryName from Categories
--	where CategoryName = 'Seafood' -- [Seafood] brackets did not work for me for some reason, only single quotes did
--;
--go



-- Question 2 (5 pts):  Select the Product Id, Product Name, and Product Price 
-- of all Products with the Seafood's Category Id. Ordered By the Products Price
-- highest to the lowest 
Select ProductID, ProductName, UnitPrice from Products
	where CategoryID = 8
	order by UnitPrice desc
; 
go

-- Question 3 (5 pts):  Select the Product Id, Product Name, and Product Price 
-- Ordered By the Products Price highest to the lowest. 
-- Show only the products that have a price Greater than $100. 
Select ProductID, ProductName, UnitPrice from Products
	where UnitPrice >= 100
	order by UnitPrice desc
	-- where UnitPrice >= 100 -- originally had the 'where' statement here, but wasnt working
; 
go

-- Question 4 (10 pts): Select the CATEGORY NAME, product name, and Product Price 
-- from both Categories and Products. Order the results by Category Name 
-- and then Product Name, in alphabetical order
-- (Hint: Join Products to Category)
Select CategoryName, ProductName, UnitPrice from Categories
	--order by CategoryName Asc
	--join ProductName, UnitPrice on Products 
	join Products on Categories.CategoryID = Products.CategoryID
	order by CategoryName asc 
; 
go

-- Question 5 (5 pts): Select the Product Id and Number of Products in Inventory
-- for the Month of JANUARY. Order the results by the ProductIDs 
select * from Inventories

Select ProductID, Count --, InventoryDate 
from Inventories
	-- where InventoryDate like 2017-01
	-- where InventoryDate between 2017-01-01 and 2017-02-01
	where InventoryDate between '2017-01-01' and '2017-01-31'
	order by ProductID asc
;
go

-- Question 6 (10 pts): Select the Category Name, Product Name, and Product Price 
-- from both Categories and Products. Order the results by price highest to lowest.
-- Show only the products that have a PRICE FROM $10 TO $20. 
select * from Products

Select CategoryName, ProductName, UnitPrice from Categories
	join Products on Products.CategoryID = Categories.CategoryID
	where UnitPrice between 10 and 20
	order by UnitPrice Desc
; 
go

-- Question 7 (10 pts) Select the Product Id and Number of Products in Inventory
-- for the Month of JANUARY. Order the results by the ProductIDs
-- and where the ProductID are only the ones in the seafood category
-- (Hint: Use a subquery to get the list of productIds with a category ID of 8)

--RETURN TO THIS QUESTION


Select ProductID, count from Inventories
	where  ProductID in (select ProductID from Products where CategoryID = 8) --subqueries are so hard, ask questions about them to figure it out
		and (InventoryDate like '2017-01%')
		--(select CategoryID from Categories
		--where CategoryID = 8
		--) 
	order by ProductID asc
; 
go

-- Question 8 (10 pts) Select the PRODUCT NAME and Number of Products in Inventory
-- for the Month of January. Order the results by the Product Names
-- and where the ProductID as only the ones in the seafood category
-- (Hint: Use a Join between Inventories and Products to get the Name)


Select ProductName, Count--, InventoryDate 
from Inventories
	join Products on Products.ProductID = Inventories.ProductID
	where (InventoryDate like '2017-01%') 
		and (CategoryID = 8) 
	order by ProductName asc
; 
go

-- Question 9 (10 pts) Select the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBURARY. Show what the MAXIMUM AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names. 
-- (Hint: If Jan count was 5, but Feb count was 15, show 15)
select * from Products
Select *from Inventories

Select ProductName, sum(Count) as [Total Quantity] from Inventories
	join Products on Products.ProductID = Inventories.ProductID
	where Products.ProductID in (select ProductID from Products where CategoryID = 8 ) 
		and (InventoryDate between '2017-01-01' and '2017-02-28')
	group by ProductName  
	order by ProductName asc

; 
go

-- Question 10 (10 pts) Select the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBURARY. Show what the MAX AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names. 
-- Restrict the results to rows with a MAXIMUM COUNT OF 10 OR HIGHER


Select ProductName, max(Count) as [Max Quantity] from Inventories
	join Products on Products.ProductID = Inventories.ProductID
	where Products.ProductID in (select ProductID from Products where CategoryID = 8 ) 
		and (InventoryDate between '2017-01-01' and '2017-02-28')
		and count >=10
	group by ProductName  
	order by ProductName asc

; 
go

-- Question 11 (20 pts) Select the CATEGORY NAME, Product Name and Number of Products in Inventory
-- for both JANUARY and FEBURARY. Show what the MAX AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names. 
-- Restrict the results to rows with a maximum count of 10 or higher



--Select (select CategoryName from Categories), (select ProductName from Products), Count from Inventories
Select CategoryName, ProductName, max(Count) as [Max Quantity] from Inventories
	join Products on Products.ProductID = Inventories.ProductID
	join Categories on Categories.CategoryID = Products.CategoryID
	where Products.ProductID in (select ProductID from Products where CategoryID = 8 ) 
		and (InventoryDate between '2017-01-01' and '2017-02-28')
		and count >=10
	group by CategoryName, ProductName
	order by ProductName asc
;
go

/***************************************************************************************/