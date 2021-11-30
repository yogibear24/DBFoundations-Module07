--*************************************************************************--
-- Title: Assignment07
-- Author: Everet Wang
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
-- 2021-11-28,Everet Wang, Completed Questions 1 through 5
-- 2021-11-29,Everet Wang, Completed Questions 6 through 8
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_EveretWang')
	 Begin 
	  Alter Database [Assignment07DB_EveretWang] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_EveretWang;
	 End
	Create Database Assignment07DB_EveretWang;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_EveretWang;

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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

GO
CREATE VIEW vProductsByPrices
AS
	SELECT TOP 1000000000 ProductName, Format(UnitPrice, 'C', 'en-US') AS UnitPrice
	FROM vCategories
	INNER JOIN vProducts
		ON vCategories.CategoryID = vProducts.CategoryID
	ORDER BY ProductName;
GO

-- DROP VIEW vProductsByPrices;
SELECT * FROM vProductsByPrices;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

GO
CREATE VIEW vCategoriesByProductsByPrices
AS
	SELECT TOP 1000000000 CategoryName, ProductName, 
		Format(UnitPrice, 'C', 'en-US') AS UnitPrice
	FROM vCategories
	INNER JOIN vProducts
		ON vCategories.CategoryID = vProducts.CategoryID
	ORDER BY CategoryName, ProductName;
GO

SELECT * FROM vCategoriesByProductsByPrices;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

GO
CREATE VIEW vProductsByDateByCount
AS
	SELECT TOP 1000000000 ProductName, 
	DateName(mm, InventoryDate) + ', ' + LTrim(Str(Year(InventoryDate))) 
		AS InventoryDate, 
	Count AS InventoryCount
	FROM vProducts
	INNER JOIN vInventories
		ON vProducts.ProductID = vInventories.ProductID
	ORDER BY ProductName, Month(InventoryDate);
GO

-- DROP VIEW vProductsByDateByCount;
SELECT * FROM vProductsByDateByCount;
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

GO
CREATE VIEW vProductInventories
AS
	SELECT TOP 1000000000 ProductName, 
	DateName(mm, InventoryDate) + ', ' + LTrim(Str(Year(InventoryDate))) 
		AS InventoryDate, 
	Count AS InventoryCount
	FROM vProducts
	INNER JOIN vInventories
		ON vProducts.ProductID = vInventories.ProductID
	ORDER BY ProductName, Month(InventoryDate);
GO

-- DROP VIEW vProductInventories;
SELECT * FROM vProductInventories;
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

GO
CREATE VIEW vCategoryInventories
AS
	SELECT TOP 1000000000 CategoryName, 
	DateName(mm, InventoryDate) + ', ' + LTrim(Str(Year(InventoryDate))) 
		AS InventoryDate,  
	Sum(Count) AS InventoryCountByCategory
	FROM vCategories
	INNER JOIN vProducts
		ON vCategories.CategoryID = vProducts.CategoryID
	INNER JOIN vInventories
		ON vProducts.ProductID = vInventories.ProductID
	GROUP BY InventoryDate, CategoryName;
GO

-- DROP VIEW vCategoryInventories;
SELECT * FROM vCategoryInventories;
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

GO
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
AS 
	SELECT TOP 1000000000 
		ProductName, InventoryDate, InventoryCount,
		IIF(Month(InventoryDate) = 1, 0, Lag(InventoryCount) 
			OVER (ORDER BY ProductName, Month(InventoryDate))) AS PreviousMonthCount
	FROM vProductInventories
	ORDER BY ProductName, Month(InventoryDate);
GO

-- DROP VIEW vProductInventoriesWithPreviousMonthCounts;
 SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
 GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Verify that the results are ordered by the Product and Date.
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

GO
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS 
	SELECT TOP 1000000000 
		ProductName, InventoryDate, InventoryCount, PreviousMonthCount,
		Case
			When InventoryCount > PreviousMonthCount Then 1
			When InventoryCount = PreviousMonthCount Then 0
			When InventoryCount < PreviousMonthCount Then -1
		End AS CountVsPreviousCountKPI
	FROM vProductInventoriesWithPreviousMonthCounts
	ORDER BY ProductName, Month(InventoryDate);
GO

-- DROP VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs;
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Verify that the results are ordered by the Product and Date.

CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPIValue int)
RETURNS Table
AS
RETURN(
		SELECT TOP 1000000000
			ProductName, InventoryDate, InventoryCount, PreviousMonthCount,
			CountVsPreviousCountKPI
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
		WHERE CountVsPreviousCountKPI = @KPIValue
		ORDER BY ProductName, Month(InventoryDate)
		);
GO

SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
GO

/***************************************************************************************/