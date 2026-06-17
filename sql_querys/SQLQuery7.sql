USE ECommerceSalesDB;
GO

-- Safely clear data for a clean deployment sync
ALTER TABLE Fact_Sales NOCHECK CONSTRAINT ALL;
TRUNCATE TABLE Fact_Sales;
DELETE FROM Dim_Status;
DELETE FROM Dim_Products;
DELETE FROM Dim_Geography;
ALTER TABLE Fact_Sales CHECK CONSTRAINT ALL;
GO