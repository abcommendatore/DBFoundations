--*************************************************************************--
-- Title: Assignment06
-- Author: ACommendatore
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2026-11-17,ACommendatore,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ACommendatore')
	 Begin 
	  Alter Database [Assignment06DB_ACommendatore] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ACommendatore;
	 End
	Create Database Assignment06DB_ACommendatore;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ACommendatore;

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
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
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
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

go
Create View vCategories WITH SCHEMABINDING AS
Select CategoryID, CategoryName
	from dbo.Categories
go
Create View vEmployees WITH SCHEMABINDING AS
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	from dbo.Employees
go
Create View vInventories WITH SCHEMABINDING AS
Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	from dbo.Inventories
go
Create View vProducts WITH SCHEMABINDING AS
Select ProductID, ProductName, CategoryID, UnitPrice
	from dbo.Products
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
go
Deny Select On dbo.Categories to Public;
Grant Select On vCategories to Public;
go
Deny Select On dbo.Products to Public;
Grant Select On vProducts to Public;
go
Deny Select On dbo.Inventories to Public;
Grant Select On vInventories to Public;
go
Deny Select On dbo.Employees to Public;
Grant Select On vEmployees to Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

go
Create View vProductsByCategories AS
Select c.CategoryName,
	   p.ProductName,
	   p.UnitPrice
	from vCategories as C
		join vProducts as p
			on c.CategoryID = p.CategoryID
go
Select CategoryName, ProductName, UnitPrice
	from vProductsByCategories
	order by CategoryName, ProductName
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

go
Create View vInventoriesByProductsByDates AS
Select p.ProductName,
	   i.Count,
	   i.InventoryDate
	from vProducts as p
		join vInventories as i
			on p.ProductID = i.ProductID
go
Select ProductName, InventoryDate, Count
	from vInventoriesByProductsByDates
	order by ProductName, InventoryDate DESC, Count
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

go
Create View vInventoriesByEmployeesByDates AS
Select i.InventoryDate,
	   CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) as EmployeeName
	from vInventories as i
		join vEmployees as e
			on i.EmployeeID = e.EmployeeID
go
Select distinct InventoryDate, EmployeeName
	from vInventoriesByEmployeesByDates
	order by InventoryDate
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

go
Create View vInventoriesByProductsByCategories AS
Select c.CategoryName,
	   p.ProductName,
	   i.InventoryDate,
	   i.Count
	from vCategories as c
		join vProducts as p
			on c.CategoryID = p.CategoryID
		join vInventories as i
			on i.ProductID = p.ProductID
go
Select CategoryName, ProductName, InventoryDate, Count
	from vInventoriesByProductsByCategories
	order by CategoryName, ProductName, InventoryDate DESC, Count
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

go
Create View vInventoriesByProductsByEmployees AS
Select c.CategoryName,
	   p.ProductName,
	   i.InventoryDate,
	   i.Count
	from vCategories as c
		join vProducts as p
			on c.CategoryID = p.CategoryID
		join vInventories as i
			on i.ProductID = p.ProductID
go
Select CategoryName, ProductName, InventoryDate, Count
	from vInventoriesByProductsByEmployees
	order by CategoryName, ProductName, InventoryDate DESC, Count
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

go
Create View vInventoriesForChaiAndChangByEmployees AS
Select c.CategoryName,
	   p.ProductName,
	   i.InventoryDate,
	   i.Count,
	   CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS EmployeeName
	from vCategories as c
		join vProducts as p
			on c.CategoryID = p.CategoryID
		join vInventories as i
			on i.ProductID = p.ProductID
		join vEmployees as e
			on i.EmployeeID = e.EmployeeID
go
Select CategoryName, ProductName, InventoryDate, Count, EmployeeName
	from vInventoriesForChaiAndChangByEmployees
	where ProductName IN ('Chai','Chang')
	order by ProductName, InventoryDate DESC
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
go
Create View vEmployeesByManager AS
Select m.EmployeeLastName AS ManagerLastName,
	   CONCAT(m.EmployeeFirstName, ' ', m.EmployeeLastName) AS ManagerFullName,
	   CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS EmployeeFullName
	from vEmployees as e
		left join vEmployees as m
			on e.ManagerID = m.EmployeeID
go
Select EmployeeFullName, ManagerFullName
	from vEmployeesByManager
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
go
Create View vInventoriesByProductsByCategoriesByEmployees AS
Select c.CategoryID,
	   c.CategoryName,
	   p.ProductID,
	   p.ProductName,
	   p.UnitPrice,
	   i.InventoryID,
	   i.InventoryDate,
	   i.Count,
	   i.EmployeeID as InventoryEmployeeID,
	   e.EmployeeID,
	   CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS EmployeeName,
	   e.ManagerID,
	   CONCAT(m.EmployeeFirstName, ' ', m.EmployeeLastName) AS ManagerName
	from vCategories as c
		full join vProducts as p
			on c.CategoryID = p.CategoryID
		full join vInventories as i
			on p.ProductID = i.ProductID
		full join vEmployees as e
			on i.EmployeeID = e.EmployeeID
		left join vEmployees as m
			on e.ManagerID = m.EmployeeID
go
Select * from vInventoriesByProductsByCategoriesByEmployees
	order by CategoryName, ProductName, InventoryID, EmployeeName
go


/***************************************************************************************/

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/