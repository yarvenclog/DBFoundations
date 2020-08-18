select * from Northwind.sys.Tables where type = 'u' order by Name;
go

select * from Northwind.dbo.Customers

create database Mod06LabsTomFerko
go
use Mod06LabsTomFerko
go

create --drop
view vCustomersByLocation
as
	select top 100 percent
		ContactName, City, isnull(Region, Country) as Region, Country 
	from Northwind.dbo.Customers
	order by ContactName
;
go

select * from vCustomersByLocation
select * from Northwind.dbo.Orders
go

create --drop
view vNumberOfCustomerOrdersByLocation
as
	select top 100 percent
		ContactName
		, City
		, isnull(Region, Country) as Region
		, Country
		, count(OrderID) as NumberOfOrders
		, year(OrderDate) as OrderDate
	from Northwind.dbo.Customers as c
	join Northwind.dbo.Orders as o
		on c.CustomerID = o.CustomerID
	group by 
		ContactName
		, City
		, isnull(Region, Country)
		, Country
		, year(OrderDate)
;
go

select * from vNumberOfCustomerOrdersByLocation

select * from SysComments