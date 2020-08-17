--*************************************************************************--
-- Title: Assignment04
-- Author: TomFerko
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2017-01-01,TomFerko,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment04DB_TomFerko')
 Begin 
  Alter Database [Assignment04DB_TomFerko] set Single_user With Rollback Immediate;
  Drop Database Assignment04DB_TomFerko;
 End
go

Create Database Assignment04DB_TomFerko;
go

Use Assignment04DB_TomFerko;
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


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go

/********************************* TASKS *********************************/

-- Add the follow data to this database.
-- All answers must include the Begin Tran, Commit Tran, and Rollback Tran transaction statements. 
-- All answers must include the Try/Catch blocks around your transaction processing code.
-- Display the Error message it the catch block is envoked.

/* Add the following data to this database:
Beverages	Chai	18.00	2017-01-01	61
Beverages	Chang	19.00	2017-01-01	87
Condiments	Aniseed Syrup	10.00	2017-01-01	19
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-01-01	81

Beverages	Chai	18.00	2017-02-01	13
Beverages	Chang	19.00	2017-02-01	2
Condiments	Aniseed Syrup	10.00	2017-02-01	1
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-02-01	79

Beverages	Chai	18.00	2017-03-02	18
Beverages	Chang	19.00	2017-03-02	12
Condiments	Aniseed Syrup	10.00	2017-03-02	84
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-03-02	72
*/

-- Task 1 (20 pts): Add data to the Categories table
begin try
	begin tran AddCategories
		insert into Categories
			(CategoryName
			)
		values
			('Beverages'
			),
			('Condiments'
			)

	commit tran AddCategories
end try
begin catch
	rollback tran AddCategories
	print 'insert into Categories Failed, check import'
end catch
;
go

select * from Categories
-- Task 2 (20 pts): Add data to the Products table

begin try
	begin tran AddProducts
		insert into Products
			(ProductName,
			UnitPrice,
			CategoryID
			)
		values
			('Chai', 18, 1
			),
			('Chang', 19, 1
			),
			('Aniseed Syrup', 10, 2
			),
			('Chef Anton''s Cajun Seasoning', 22, 2
			)

	commit tran AddProducts
end try
begin catch
	rollback tran AddProducts
	print 'insert into Products Failed, check import'
end catch
;
go

select * from Products

-- Task 3 (20 pts): Add data to the Inventories table

begin try
	begin tran AddInventory
		insert into Inventories
			(InventoryDate,
			ProductID,
			Count
			)
		values
			('2017-01-01', 1, 61
			),
			('2017-01-01', 2, 87
			),
			('2017-01-01', 3, 19
			),
			('2017-01-01', 4, 81
			),
			('2017-02-01', 1, 13
			),
			('2017-02-01', 2, 2
			),
			('2017-02-01', 3, 1
			),
			('2017-02-01', 4, 79
			),
			('2017-03-01', 1, 18
			),
			('2017-03-01', 2, 12
			),
			('2017-03-01', 3, 84
			),
			('2017-03-01', 4, 72
			)
	commit tran AddInventory
end try
begin catch
	rollback tran AddInventory
	print 'insert into Inventories Failed, check import'
end catch
;

select * from Inventories
select * from Categories
select * from Products
-- Task 4 (10 pts): Write code to update the Category "Beverages" to "Drinks"

begin try
	begin tran UpdateDrinks
		update Categories
			set CategoryName = 'Drinks'
			where CategoryName = 'Beverages'
	commit tran UpdateDrinks
end try
begin catch
	rollback tran UpdateDrinks
	print 'UpdateDrinks failed, check data type'
end catch
;
go

-- Task 5 (30 pts): Write code to delete all Condiments data from the database (in all three tables!)  

begin try
	begin tran DeleteCondiments
		delete from Inventories
			where ProductID in (3, 4) 
	save tran DeleteCategory1

		delete from Products
			where CategoryID = 2
	save tran DeleteCategory2

		delete from Categories
			where CategoryID = 2

	commit tran DeleteCondiments
end try
begin catch
	rollback tran DeleteCondiments
	print 'Unable to delete'
end catch
;
go

--drop table Inventories
--drop table Products
--drop table Categories

select * from Inventories
select * from Categories
select * from Products

/***************************************************************************************/