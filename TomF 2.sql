--*************************************************************************--
-- Title: Assignment02
-- Author: TomFerko
-- Desc: This file demonstrates common database options
-- Change Log: When,Who,What
-- 2020-07-20,TomFerko,Created File
--**************************************************************************--

create database Assignment02DB_TomFerko
go

use Assignment02DB_TomFerko
go

create --drop
table Categories --identity (x,y) sets the base value for x, and increases that value with each entry by y. identity should be renamed autonumber, because thats what it does
(					
	CategoryID int identity (1,1) not null, --identity is not a constraint, and cant be added to alter table
	CategoryName nvarchar (100) not null,
-- CONSTRAINTS
constraint PK_CategoryID 
	primary key clustered (CategoryID),
constraint U_CategoryName 
	unique nonclustered (CategoryName)
);
go

--select * from Categories

--the alter table below is commented out because setting the constraints through an alter table seems like a waste of space as opposed to declaring it in the table
--alter 
--table Categories
--	add constraint PK_CategoryID 
--		primary key clustered (CategoryID), --primary key added to ensure it is a unique value and cant accept a null value
--	constraint U_CategoryName 
--		unique nonclustered (CategoryName) -- unique added in order to ensure that values never repeat throughout the column
--;
--go

create --drop
table Products
(
	ProductID int identity (1,1) not null,
	ProductName nvarchar (100) not null,
	CategoryID int null, 	
	UnitPrice money not null,
-- CONSTRAINTS	
constraint PK_ProductID 
	primary key clustered (ProductID),
constraint U_ProductName 
	unique nonclustered (ProductName),
constraint FK_CategoryID 
	foreign key (CategoryID) references Categories (CategoryID), -- foreign key added in order to connect this column over to the categories table so it will reference the information from that table over here
constraint CK_UnitPrice check (UnitPrice > 0)
);
go

--alter 
--table Products
--	add constraint PK_ProductID 
--		primary key clustered (ProductID),
--	constraint U_ProductName 
--		unique nonclustered (ProductName),
--	constraint FK_CategoryID 
--		foreign key (CategoryID) references Categories (CategoryID), -- foreign key added in order to connect this column over to the categories table so it will reference the information from that table over here
--	constraint CK_UnitPrice check (UnitPrice > 0)
--;
--go


create --drop
table Inventories
(
	InventoryID int identity (1,1) not null,
	InventoryDate date not null, 
	ProductID int not null,
	ProductCount int not null,
--CONSTRAINTS
constraint PK_InventoryID
	primary key clustered (InventoryID),
--constraint D_InventoryDate 
--	default getdate (), -- default sets the date to today if no other value is specified
constraint FK_ProductID
	foreign key (productID) references Products (ProductID),
constraint CK_Count check (ProductCount > 0)
);
go

--I could only get the getdate function to work in an alter table... I am not quite sure why
alter 
table Inventories
	add constraint D_InventoryDate 
		default getdate () for InventoryDate
;
go
