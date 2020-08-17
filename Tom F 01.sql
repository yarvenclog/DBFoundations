create database Assignment01DB_TomFerko
go -- use go to separate batches of code that will be run separately 

use Assignment01DB_TomFerko
go
-- use drop comment to get rid of the table quickly and easily if needed, just highlight from remove to table name and run code
create -- drop
table customer 
(	ID int primary key not null, 
	FirstName varchar(50) not null, -- nvarchar and varchar are essentially the same, but nvarchar saves at 2 bits per character where as varchar saves at 1 bit
	LastName varchar(50) not null, 
	Address varchar(100) null, -- do we need to specify null and not null? it was my assumption that it would default to null if unspecified
	City varchar(50) null, 
	State char(2) null 
);
go

create -- drop
table food
(	ID int primary key not null, 
	Product varchar(100) not null, 
	Price money null, 
	Units int null,
	Date date null
);
go

insert into customer 
	values 
(	1, 'Bob', 'Smith', '123 Main', 'Bellevue', 'WA' -- use single quotes for text, not double quotes
);

insert into food values
(	1, 'Apples', 0.89, 12, '5/5/2006' -- date will automatically reformat into the proper YYYY-MM-DD
),
(	2, 'Milk', 1.59, 2, '5/5/2006'
),
(	3, 'Bread', 2.28, 1, '5/5/2006'
);
go

select * from food