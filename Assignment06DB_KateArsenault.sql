--*************************************************************************--
-- Title: Assignment06
-- Author: KateArsenault
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-11-21, KateArsenault, Created File
-- 2021-11-21, KateArsenault, Answered Questions 1-10
-- 2021-11-21, KateArsenault, Modified Question 5 based on feedback & review of Module 5
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KateArsenault')
	 Begin 
	  Alter Database [Assignment06DB_KateArsenault] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KateArsenault;
	 End
	Create Database Assignment06DB_KateArsenault;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KateArsenault;

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

--Look at Categories to get all column names
	--Select * From Categories;
--Write View for Categories
go
CREATE VIEW vCategories 
WITH SCHEMABINDING
AS
	SELECT 
		CategoryID
		,CategoryName 
	FROM 
		dbo.Categories
;
go
--Test view
	--SELECT * FROM vCategories;
	--go

--Look at Products to get column names
	--Select * From Products;
--Write View for Products
go
CREATE VIEW vProducts
WITH SCHEMABINDING
AS
	SELECT 
		ProductID
		,ProductName
		,CategoryID
		,UnitPrice
	FROM
		dbo.Products
;
go
--Test view
	--Select * from vProducts;
	--go

--Look at Employees to get column names
	--Select * From Employees;
--Write view for Employees
go
CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT
		EmployeeID
		,EmployeeFirstName
		,EmployeeLastName
		,ManagerID
	FROM
		dbo.Employees
;
go
--Test view
	--SELECT * FROM vEmployees;
	--go

--Look at Inventories to get column names
	--Select * From Inventories;
--Write view for Inventories
go
CREATE VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT
		InventoryID
		,InventoryDate
		,EmployeeID
		,ProductID
		,Count
	FROM
		dbo.Inventories
;
go
--Test view
	--Select * From vInventories;
	--go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_KateArsenault;

Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;

go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

--Start with code from Module 5 Question 1
	--SELECT 
	--	C.CategoryName
	--	,P.ProductName
	--	,P.UnitPrice 
	--FROM 
	--	Products as P 
	--	inner join Categories as C on P.CategoryID=C.CategoryID 
	--ORDER BY 
	--	C.CategoryName asc
	--	,P.ProductName asc
	--;
	--go
--Modify to use views
	--SELECT 
	--	C.CategoryName
	--	,P.ProductName
	--	,P.UnitPrice 
	--FROM 
	--	vProducts as P 
	--	inner join vCategories as C on P.CategoryID=C.CategoryID 
	--ORDER BY 
	--	C.CategoryName asc
	--	,P.ProductName asc
	--;
	--go
--Add new view name & TOP
go
CREATE VIEW vProductsByCategories
AS
	SELECT TOP 10000
		C.CategoryName
		,P.ProductName
		,P.UnitPrice 
	FROM 
		vProducts as P 
		inner join vCategories as C on P.CategoryID=C.CategoryID 
	ORDER BY 
		C.CategoryName asc
		,P.ProductName asc
;
go
--Test View
	--Select * from vProductsByCategories;


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

--Start with code from Module 5 Question 2
	--SELECT 
	--	P.ProductName
	--	,I.InventoryDate
	--	,I.Count 
	--FROM 
	--	Inventories as I 
	--	inner join Products as P on I.ProductID=P.ProductID 
	--ORDER BY 
	--	I.InventoryDate asc
	--	,P.ProductName asc
	--	,I.Count asc
	--;
	--go
--Modify to use views
	--SELECT 
	--	P.ProductName
	--	,I.InventoryDate
	--	,I.Count 
	--FROM 
	--	vInventories as I 
	--	inner join vProducts as P on I.ProductID=P.ProductID 
	--ORDER BY 
	--	I.InventoryDate asc
	--	,P.ProductName asc
	--	,I.Count asc
	--;
	--go
--Add view name & TOP
	--CREATE VIEW vInventoriesByProductsByDates
	--AS
	--	SELECT TOP 10000
	--		P.ProductName
	--		,I.InventoryDate
	--		,I.Count 
	--	FROM 
	--		vInventories as I 
	--		inner join vProducts as P on I.ProductID=P.ProductID 
	--	ORDER BY 
	--		I.InventoryDate asc
	--		,P.ProductName asc
	--		,I.Count asc
	--;
	--go
--Rearrange Order By
go
CREATE VIEW vInventoriesByProductsByDates
AS
	SELECT TOP 10000
		P.ProductName
		,I.InventoryDate
		,I.Count 
	FROM 
		vInventories as I 
		inner join vProducts as P on I.ProductID=P.ProductID 
	ORDER BY 
		P.ProductName asc
		,I.InventoryDate asc
		,I.Count asc
;
go
--Test view
	--Select * from vInventoriesByProductsByDates;


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

--Start with code from Module 5 Question 3
	--SELECT 
	--	I.InventoryDate
	--	,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	--FROM 
	--	Inventories as I 
	--	inner join Employees as E on I.EmployeeID=E.EmployeeID 
	--GROUP BY 
	--	InventoryDate
	--	,E.EmployeeFirstName 
	--	,E.EmployeeLastName
	--;
	--go
-- Modify code to use distinct instead of group by (I had actually forgotten about DISTINCT as it is not a thing I use routinely at work)
	--SELECT DISTINCT
	--	I.InventoryDate
	--	,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	--FROM 
	--	Inventories as I 
	--	inner join Employees as E on I.EmployeeID=E.EmployeeID 
	--;
	--go
-- Modify to use views
	--SELECT DISTINCT
	--	I.InventoryDate
	--	,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	--FROM 
	--	vInventories as I 
	--	inner join vEmployees as E on I.EmployeeID=E.EmployeeID 
	--;
	--go
--Add view name (no top needed because there is no order by)
CREATE VIEW vInventoriesByEmployeesByDates
AS
	SELECT DISTINCT
		I.InventoryDate
		,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	FROM 
		vInventories as I 
		inner join vEmployees as E on I.EmployeeID=E.EmployeeID 
;
go
--Test view
	--SELECT * FROM vInventoriesByEmployeesByDates;


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

--Start with code from Module 5 Question 4
	--SELECT 
	--	C.CategoryName
	--	,P.ProductName
	--	,I.InventoryDate
	--	,I.Count 
	--FROM 
	--	Inventories as I 
	--	inner join Products as P on I.ProductID=P.ProductID 
	--	inner join Categories as C on P.CategoryID=C.CategoryID 
	--ORDER BY 
	--	C.CategoryName asc
	--	,P.ProductName asc
	--	,I.InventoryDate asc
	--	,I.Count asc
	--;
	--go
--Modify to use views
	--SELECT 
	--	C.CategoryName
	--	,P.ProductName
	--	,I.InventoryDate
	--	,I.Count 
	--FROM 
	--	vInventories as I 
	--	inner join vProducts as P on I.ProductID=P.ProductID 
	--	inner join vCategories as C on P.CategoryID=C.CategoryID 
	--ORDER BY 
	--	C.CategoryName asc
	--	,P.ProductName asc
	--	,I.InventoryDate asc
	--	,I.Count asc
	--;
	--go
--Add view name and TOP
CREATE VIEW vInventoriesByProductsByCategories
AS
	SELECT TOP 100000
		C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count 
	FROM 
		vInventories as I 
		inner join vProducts as P on I.ProductID=P.ProductID 
		inner join vCategories as C on P.CategoryID=C.CategoryID 
	ORDER BY 
		C.CategoryName asc
		,P.ProductName asc
		,I.InventoryDate asc
		,I.Count asc
;
go
--Test view 
	--SELECT * FROM vInventoriesByProductsByCategories;


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

--Start with code from Module 5 Question 5
	--SELECT 
	--	C.CategoryName
	--	,P.ProductName
	--	,I.InventoryDate
	--	,I.Count
	--	,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	--FROM 
	--	Inventories as I 
	--	inner join Products as P on I.ProductID=P.ProductID 
	--	inner join Categories as C on P.CategoryID=C.CategoryID 
	--	inner join Employees as E on I.EmployeeID=E.EmployeeID
	--ORDER BY 
	--	I.InventoryDate asc
	--	,C.CategoryName asc
	--	,P.ProductName asc
	--	,[Employee Name] asc
	--;
	--go
--modify to use views
	--SELECT 
	--	C.CategoryName
	--	,P.ProductName
	--	,I.InventoryDate
	--	,I.Count
	--	,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	--FROM 
	--	vInventories as I 
	--	inner join vProducts as P on I.ProductID=P.ProductID 
	--	inner join vCategories as C on P.CategoryID=C.CategoryID 
	--	inner join vEmployees as E on I.EmployeeID=E.EmployeeID
	--ORDER BY 
	--	I.InventoryDate asc
	--	,C.CategoryName asc
	--	,P.ProductName asc
	--	,[Employee Name] asc
	--;
	--go
--Add view name and TOP
CREATE VIEW vInventoriesByProductsByEmployees
AS
	SELECT TOP 100000
		C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count
		,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	FROM 
		Inventories as I 
		inner join Products as P on I.ProductID=P.ProductID 
		inner join Categories as C on P.CategoryID=C.CategoryID 
		inner join Employees as E on I.EmployeeID=E.EmployeeID
	ORDER BY 
		I.InventoryDate asc
		,C.CategoryName asc
		,P.ProductName asc
		,[Employee Name] asc
;
go
--Test view
	--SELECT * FROM vInventoriesByProductsByEmployees;


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

--Start with code from Module 5 Question 6
	--SELECT 
	--	C.CategoryName
	--	,P.ProductName
	--	,I.InventoryDate
	--	,I.Count
	--	,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	--FROM 
	--	Inventories as I 
	--	inner join Products as P on I.ProductID=P.ProductID
	--	inner join Categories as C on P.CategoryID=C.CategoryID 
	--	inner join Employees as E on I.EmployeeID=E.EmployeeID
	--WHERE 
	--	I.ProductID in (SELECT ProductID FROM PRODUCTS WHERE ProductName in ('Chai','Chang'))
	--ORDER BY 
	--	I.InventoryDate asc
	--	,C.CategoryName asc
	--	,P.ProductName asc
	--;
	--go
--Modify to use views
	--SELECT 
	--	C.CategoryName
	--	,P.ProductName
	--	,I.InventoryDate
	--	,I.Count
	--	,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	--FROM 
	--	vInventories as I 
	--	inner join vProducts as P on I.ProductID=P.ProductID
	--	inner join vCategories as C on P.CategoryID=C.CategoryID 
	--	inner join vEmployees as E on I.EmployeeID=E.EmployeeID
	--WHERE 
	--	I.ProductID in (SELECT ProductID FROM PRODUCTS WHERE ProductName in ('Chai','Chang'))
	--ORDER BY 
	--	I.InventoryDate asc
	--	,C.CategoryName asc
	--	,P.ProductName asc
	--;
	--go
--Add view name & TOP
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
	SELECT TOP 100000
		C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.Count
		,(E.EmployeeFirstName+' '+E.EmployeeLastName) as [Employee Name] 
	FROM 
		vInventories as I 
		inner join vProducts as P on I.ProductID=P.ProductID
		inner join vCategories as C on P.CategoryID=C.CategoryID 
		inner join vEmployees as E on I.EmployeeID=E.EmployeeID
	WHERE 
		I.ProductID in (SELECT ProductID FROM PRODUCTS WHERE ProductName in ('Chai','Chang'))
	ORDER BY 
		I.InventoryDate asc
		,C.CategoryName asc
		,P.ProductName asc
;
go
--Test view
	--SELECT * from vInventoriesForChaiAndChangByEmployees;


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

--Start with code from Module 5 Question 7
	--SELECT 
	--	M.EmployeeFirstName+' '+M.EmployeeLastName as [Manager Name]
	--	,E.EmployeeFirstName+' '+E.EmployeeLastName as [Employee Name]
	--FROM 
	--	Employees as E inner join Employees as M on E.ManagerID=M.EmployeeID
	--ORDER By 
	--	[Manager Name] asc
	--	,[Employee Name] asc
	--;
	--go
--Modify Code to use views
	--SELECT 
	--	M.EmployeeFirstName+' '+M.EmployeeLastName as [Manager Name]
	--	,E.EmployeeFirstName+' '+E.EmployeeLastName as [Employee Name]
	--FROM 
	--	vEmployees as E inner join vEmployees as M on E.ManagerID=M.EmployeeID
	--ORDER By 
	--	[Manager Name] asc
	--	,[Employee Name] asc
	--;
	--go
-- Add view name and TOP
CREATE VIEW vEmployeesByManager
AS
	SELECT TOP 1000
		M.EmployeeFirstName+' '+M.EmployeeLastName as [Manager Name]
		,E.EmployeeFirstName+' '+E.EmployeeLastName as [Employee Name]
	FROM 
		vEmployees as E inner join vEmployees as M on E.ManagerID=M.EmployeeID
	ORDER By 
		[Manager Name] asc
		,[Employee Name] asc
;
go
--Test View
	--SELECT * FROM vEmployeesByManager;


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

--Do a select from all 4 basic views to get column naames
	--SELECT * FROM vCategories;
	--SELECT * FROM vProducts;
	--SELECT * FROM vInventories;
	--SELECT * FROM vEmployees;
--Add all column names to SELECT, ignoring duplicates (FKs), with table aliases --This part won't run by itself, it was just to help organize myself
	--SELECT 
	--	C.CategoryID
	--	,C.CategoryName
	--	,P.ProductID
	--	,P.ProductName
	--	,P.UnitPrice
	--	,I.InventoryID
	--	,I.InventoryDate
	--	,I.[Count]
	--	,E.EmployeeID
	--	,E.EmployeeFirstName+' '+E.EmployeeLastName as [Employee]
	--	,M.EmployeeFirstName+' '+M.EmployeeLastName as [Manager]
--Add views and joins
	--go
	--SELECT 
	--	C.CategoryID
	--	,C.CategoryName
	--	,P.ProductID
	--	,P.ProductName
	--	,P.UnitPrice
	--	,I.InventoryID
	--	,I.InventoryDate
	--	,I.[Count]
	--	,E.EmployeeID
	--	,E.EmployeeFirstName+' '+E.EmployeeLastName as [Employee]
	--	,M.EmployeeFirstName+' '+M.EmployeeLastName as [Manager]
	--FROM
	--	vCategories as C
	--	inner join  vProducts as P on C.CategoryID=P.CategoryID
	--	inner join vInventories as I on P.ProductID=I.ProductID
	--	inner join vEmployees as E on I.EmployeeID=E.EmployeeID
	--	inner join vEmployees as M on E.ManagerID=M.EmployeeID
	--;
	--go
--Add Order By
	--go
	--SELECT 
	--	C.CategoryID
	--	,C.CategoryName
	--	,P.ProductID
	--	,P.ProductName
	--	,P.UnitPrice
	--	,I.InventoryID
	--	,I.InventoryDate
	--	,I.[Count]
	--	,E.EmployeeID
	--	,E.EmployeeFirstName+' '+E.EmployeeLastName as [Employee]
	--	,M.EmployeeFirstName+' '+M.EmployeeLastName as [Manager]
	--FROM
	--	vCategories as C
	--	inner join  vProducts as P on C.CategoryID=P.CategoryID
	--	inner join vInventories as I on P.ProductID=I.ProductID
	--	inner join vEmployees as E on I.EmployeeID=E.EmployeeID
	--	inner join vEmployees as M on E.ManagerID=M.EmployeeID
	--ORDER BY  --Category, Product, InventoryID, and Employee.
	--	C.CategoryName asc
	--	,P.ProductName asc
	--	,I.InventoryID asc
	--	,E.EmployeeLastName asc
	--	,E.EmployeeFirstName asc
	--;
	--go
--Add view name and TOP
go
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
	SELECT TOP 100000
		C.CategoryID
		,C.CategoryName
		,P.ProductID
		,P.ProductName
		,P.UnitPrice
		,I.InventoryID
		,I.InventoryDate
		,I.[Count]
		,E.EmployeeID
		,E.EmployeeFirstName+' '+E.EmployeeLastName as [Employee]
		,M.EmployeeFirstName+' '+M.EmployeeLastName as [Manager]
	FROM
		vCategories as C
		inner join  vProducts as P on C.CategoryID=P.CategoryID
		inner join vInventories as I on P.ProductID=I.ProductID
		inner join vEmployees as E on I.EmployeeID=E.EmployeeID
		inner join vEmployees as M on E.ManagerID=M.EmployeeID
	ORDER BY 
		C.CategoryName asc
		,P.ProductName asc
		,I.InventoryID asc
		,E.EmployeeLastName asc
		,E.EmployeeFirstName asc
;
go
--Test view
	--SELECT * FROM vInventoriesByProductsByCategoriesByEmployees;



-- Test your Views (NOTE: You must change the names to match yours as needed!)
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