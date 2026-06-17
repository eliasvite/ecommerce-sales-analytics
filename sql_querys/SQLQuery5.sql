USE ECommerceSalesDB;
GO

-- Create a view to analyze operational fulfillment status by market channel
CREATE OR ALTER VIEW v_Logistics_Fulfilment_Analysis AS
SELECT 
    s.Market_Channel,
    s.Status AS Order_Status,
    s.Courier_Status,
    COUNT(f.Order_ID) AS Order_Count,
    SUM(f.Amount) AS Affected_Revenue
FROM 
    Fact_Sales f
INNER JOIN 
    Dim_Status s ON f.Status_ID = s.Status_ID
GROUP BY 
    s.Market_Channel, s.Status, s.Courier_Status;
GO

-- Test the view execution
SELECT * FROM v_Logistics_Fulfilment_Analysis ORDER BY Market_Channel, Order_Count DESC;