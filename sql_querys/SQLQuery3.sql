USE ECommerceSalesDB;
GO

-- Create a reusable analytical view for Top Performing Products
CREATE OR ALTER VIEW v_Top_Performing_Products AS
SELECT TOP 10
    p.SKU,
    p.Category,
    p.Size,
    SUM(f.Qty) AS Total_Units_Sold,
    SUM(f.Amount) AS Total_Revenue
FROM 
    Fact_Sales f
INNER JOIN 
    Dim_Products p ON f.Product_ID = p.Product_ID
GROUP BY 
    p.SKU, p.Category, p.Size
ORDER BY 
    Total_Revenue DESC;
GO

-- Test the view execution
SELECT * FROM v_Top_Performing_Products;