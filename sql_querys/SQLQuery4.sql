USE ECommerceSalesDB;
GO

-- Create a view to analyze geographical distribution of revenue
CREATE OR ALTER VIEW v_Geographic_Sales_Performance AS
SELECT 
    g.Ship_State,
    g.Ship_City,
    COUNT(DISTINCT f.Order_ID) AS Total_Orders,
    SUM(f.Qty) AS Total_Units_Shipped,
    SUM(f.Amount) AS Total_Sales_Revenue,
    (SUM(f.Amount) / NULLIF(COUNT(DISTINCT f.Order_ID), 0)) AS Average_Order_Value
FROM 
    Fact_Sales f
INNER JOIN 
    Dim_Geography g ON f.Location_ID = g.Location_ID
GROUP BY 
    g.Ship_State, g.Ship_City;
GO

-- Test the view execution
SELECT * FROM v_Geographic_Sales_Performance ORDER BY Total_Sales_Revenue DESC;