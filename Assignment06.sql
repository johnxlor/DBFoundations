--*************************************************************************--
-- Title: Assignment06
-- Author: John Lor
-- Desc: This file demonstrates how to use Views
-- 2020-11-25
--**************************************************************************--

/********************************* Questions and Answers *********************************/

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View vCategories
with SchemaBinding as
Select CategoryID, CategoryName
from dbo.Categories
go
;

Create View vProducts
with SchemaBinding as
Select ProductID, ProductName, CategoryID, UnitPrice
from dbo.Products
go
;

Create View vInventories
with SchemaBinding as
Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
from dbo.Inventories
go
;

Create View vEmployees
with SchemaBinding as
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
from dbo.Employees
go
;

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select on Categories to Public
Deny Select on Products to Public
Deny Select on Inventories to Public
Deny Select on Employees to Public
go
;

Grant Select on vCategories to Public
Grant Select on vProducts to Public
Grant Select on vInventories to Public
Grant Select on vEmployees to Public
go
;

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View vProductsByCategories as
Select Top 100000
	CategoryName
	,ProductName
	,UnitPrice
from vCategories 
Inner Join vProducts
on vCategories.CategoryID = vProducts.CategoryID
Order by
	CategoryName
	,ProductName
	,UnitPrice
go
;

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View vInventoriesByProductsByDates as
Select Top 100000
	ProductName
	,[Count]
	,InventoryDate
from vProducts
Inner Join vInventories
on vProducts.ProductID= vInventories.ProductID
Order by
	ProductName
	,InventoryDate
	,[Count]
go
;

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create View vInventoriesByEmployeesByDates as
Select Distinct Top 100000
	InventoryDate
	,CONCAT(EmployeeFirstName, ' ', EmployeeLastName) as EmployeeName
from vInventories
Inner Join vEmployees
on vInventories.EmployeeID = vEmployees.EmployeeID
Order by
	InventoryDate
go
;

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View vInventoriesByProductsByCategories as
Select Top 100000
	CategoryName
	,ProductName
	,InventoryDate
	,[Count]
From vProducts
	Inner Join vCategories
		On vCategories.CategoryID = vProducts.ProductID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
Order by
	CategoryName
	,ProductName
	,InventoryDate
	,[Count]
go
;

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vInventoriesByProductsByEmployees as
Select Top 100000
	CategoryName
	,ProductName
	,InventoryDate
	,[Count]
	,CONCAT(EmployeeFirstName, ' ', EmployeeLastName) as EmployeeName
From vProducts
	Inner Join vCategories
		On vCategories.CategoryID = vProducts.ProductID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Inner Join vEmployees
		On vEmployees.EmployeeID = vInventories.EmployeeID
Order by
	InventoryDate
	,CategoryName
	,ProductName
	,EmployeeName
go
;

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vInventoriesForChaiAndChangByEmployees as
Select Top 100000
	CategoryName
	,ProductName
	,InventoryDate
	,[Count]
	,CONCAT(EmployeeFirstName, ' ', EmployeeLastName) as EmployeeName
From vProducts
	Inner Join vCategories
		On vCategories.CategoryID = vProducts.ProductID
	Inner Join vInventories
		On vProducts.ProductID = vInventories.ProductID
	Inner Join vEmployees
		On vEmployees.EmployeeID = vInventories.EmployeeID
Where vProducts.ProductID in (Select ProductID From vProducts Where ProductName in ('Chai', 'Chang'))
Order by
	InventoryDate
	,CategoryName
	,ProductName
go
;

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View vEmployeesByManager as
Select Top 100000
	CONCAT(vEmployees.EmployeeFirstName, ' ', vEmployees.EmployeeLastName) as EmployeeName
	,CONCAT(vManagers.EmployeeFirstName, ' ', vManagers.EmployeeLastName) as ManagerName
From vEmployees
	Inner Join vEmployees as vManagers
		On vEmployees.ManagerID = vManagers.EmployeeID
Order by ManagerName
go
;

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

Create View vInventoriesByProductsByCategoriesByEmployees as
Select Top 100000
	vCategories.CategoryID
	,CategoryName
	,vProducts.ProductID
	,ProductName
	,UnitPrice
	,InventoryID
	,InventoryDate
	,[Count]
	,E.EmployeeID
	,CONCAT(E.EmployeeFirstName, ' ', E.EmployeeLastName) as EmployeeName
	,CONCAT(M.EmployeeFirstName, ' ', M.EmployeeLastName) as ManagerName
from vInventories
	Inner Join vProducts
		on vInventories.ProductID = vProducts.ProductID
	Inner Join vEmployees as E
		on vInventories.InventoryID =E.EmployeeID
	Inner Join vCategories
		on vCategories.CategoryID = vProducts.ProductID
	Inner Join vEmployees as M
		on E.ManagerID = M.EmployeeID
go
;

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

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/