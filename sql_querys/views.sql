USE ECommerceSalesDB;
GO

-- View A: Top Performing Products Analysis
CREATE OR ALTER VIEW v_Top_Performing_Products AS
SELECT TOP 10
    p.SKU, p.Category, p.Size,
    SUM(f.Qty) AS Total_Units_Sold,
    SUM(f.Amount) AS Total_Revenue
FROM Fact_Sales f
INNER JOIN Dim_Products p ON f.Product_ID = p.Product_ID
GROUP BY p.SKU, p.Category, p.Size
ORDER BY Total_Revenue DESC;
GO

-- View B: Geographic Performance and Average Ticket Value
CREATE OR ALTER VIEW v_Geographic_Sales_Performance AS
SELECT 
    g.Ship_State, 
    g.Ship_City,
    COUNT(DISTINCT f.Order_ID) AS Total_Orders,
    SUM(f.Qty) AS Total_Units_Shipped,
    SUM(f.Amount) AS Total_Sales_Revenue,
    (SUM(f.Amount) / NULLIF(COUNT(DISTINCT f.Order_ID), 0)) AS Average_Order_Value
FROM Fact_Sales f
INNER JOIN Dim_Geography g ON f.Location_ID = g.Location_ID
GROUP BY g.Ship_State, g.Ship_City;
GO