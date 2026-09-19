USE Global_Electronics_Retrailer;

--USANDO EDA 

SELECT * FROM Products;
SELECT * FROM Stores;
SELECT * FROM Exchange_rates;
SELECT * FROM sales;
GO
SELECT p.unit_cost_usd,
		p.unit_price_usd,
		s.quantity
FROM Products p 
INNER JOIN sales s
ON p.ProductKey = s.ProductKey
WHERE p.ProductKey = 1;
GO
SELECT DISTINCT category
FROM Products
GROUP BY Category;

--COLOCANDO LAS CLAVES FORANEAS FK
--PK compuesta en Sales
ALTER TABLE Sales
ADD CONSTRAINT PK_Sales PRIMARY KEY (Order_Number, Line_Item);
-- PK COMPUESTA EN EXCHANGE_RATES
ALTER TABLE Exchange_Rates
ADD CONSTRAINT PK_ExchangeRates PRIMARY KEY (Date, Currency);

--FOREIGN KEYS EN SALES, APUNTANDO A TABLA PADRE CUSTOMER

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Customers FOREIGN KEY (CustomerKey) REFERENCES Customers(CustomerKey);

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Products FOREIGN KEY (ProductKey) REFERENCES Products(ProductKey);

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Stores FOREIGN KEY (StoreKey) REFERENCES Stores(StoreKey);

INSERT INTO Stores (StoreKey, Country, State, Square_Meters, Open_Date) --insertando en stores la row de tienda online
VALUES (0, 'Online', 'Online', NULL, 2010-01-01);

ALTER TABLE Stores
ALTER COLUMN Open_Date DATE NULL;

--ANALISIS 
SELECT * FROM Products;
SELECT * FROM Stores;
SELECT * FROM Exchange_rates;
SELECT * FROM sales;

--Calculando el Coeficiente de Correlacion de Pearson entre Margen y Cantidad vendida
--SQL Server no cuenta con la funcion CORR(x,y) 
GO 
WITH ProductsStats AS (
SELECT 
		p.ProductKey,
		CAST((p.Unit_Price_USD - p.Unit_Cost_USD) AS FLOAT) AS Margin,
		CAST(SUM(s.quantity) AS FLOAT) AS Total_Quantity
FROM Products p
JOIN Sales s 
	ON p.ProductKey = s.ProductKey
GROUP BY p.ProductKey, p.Unit_Price_USD, p.Unit_Cost_USD
)

SELECT 
	 COUNT(*) AS n,
    SUM(Margin) AS sum_x,
    SUM(Total_Quantity) AS sum_y,
    SUM(Margin * Total_Quantity) AS sum_xy,
    SUM(Margin * Margin) AS sum_x2,
    SUM(Total_Quantity * Total_Quantity) AS sum_y2,
	--Formula de Pearson armada con las variables
	 ( (COUNT(*) * SUM(Margin * Total_Quantity)) - (SUM(Margin) * SUM(Total_Quantity)))
    /
    (
        SQRT(
            (COUNT(*) * SUM(Margin * Margin) - POWER(SUM(Margin), 2))
            *
            (COUNT(*) * SUM(Total_Quantity * Total_Quantity) - POWER(SUM(Total_Quantity), 2))
        )
    ) AS Correlation_Coefficient
FROM ProductsStats;

--aplicando el coeficiente de determinacion (R^2)

--R² = (-0.1186)² ≈ 0.014 = el margen explica solo 1.4% de la variación en las unidades vendidas
--el otro 98.6% se debe a otros factores (categoría, marca, necesidad del producto, temporada, etc.)


--DETERMINANDO COEFICIENTE DE CORRELACION   Edad del cliente vs.  su Gasto total
    
WITH CustomerSpend AS (
    SELECT
        c.CustomerKey,
        CAST(
            DATEDIFF(YEAR, c.Birthday, GETDATE()) -
            CASE
                WHEN (MONTH(c.Birthday) > MONTH(GETDATE())) --determinando la edad del cliente
                  OR (MONTH(c.Birthday) = MONTH(GETDATE()) AND DAY(c.Birthday) > DAY(GETDATE()))
                THEN 1
                ELSE 0
            END
        AS FLOAT) AS Age,
        CAST(SUM(p.Unit_Price_USD * s.Quantity) AS FLOAT) AS Gasto_Total
    FROM Customers c
    JOIN Sales s ON c.CustomerKey = s.CustomerKey
    JOIN Products p ON s.ProductKey = p.ProductKey
    GROUP BY c.CustomerKey, c.Birthday
)
SELECT
    COUNT(*) AS n,
    SUM(Age) AS sum_x,
    SUM(Gasto_Total) AS sum_y,
    SUM(Age * Gasto_Total) AS sum_xy,
    SUM(Age * Age) AS sum_x2,
    SUM(Gasto_Total * Gasto_Total) AS sum_y2,
    -- Fórmula de Pearson armada con las variables
    ((COUNT(*) * SUM(Age * Gasto_Total)) - (SUM(Age) * SUM(Gasto_Total))) 
    /
    (
       SQRT(
            (COUNT(*) * SUM(Age * Age) - POWER(SUM(Age), 2))
            *
            (COUNT(*) * SUM(Gasto_Total * Gasto_Total) - POWER(SUM(Gasto_Total), 2))
        )
    ) AS Correlation_Coefficient
FROM CustomerSpend;

--CORRELACION ENTRE METROS DE TIENDA VS. CANTIDAD VENDIDA POR TIENDA

SELECT * FROM Products;
SELECT * FROM Stores;
SELECT * FROM Exchange_rates;
SELECT * FROM sales;

--¿El tamaño de la tienda fisica se relaciona  con sus ventas totales??
WITH StoreSales AS (
    SELECT 
        st.StoreKey,
        st.Square_Meters,
        SUM(p.Unit_Price_USD * s.Quantity) AS sum_sales
    FROM Stores st
    JOIN Sales s 
        ON st.StoreKey = s.StoreKey
    JOIN Products p 
        ON s.ProductKey = p.ProductKey
    WHERE st.StoreKey <> 0 --se excluye la tienda en linea
    GROUP BY st.StoreKey, st.Square_Meters
)
SELECT
    COUNT(*) AS n,
    SUM(CAST(Square_Meters AS FLOAT)) AS sum_x,
    SUM(sum_sales) AS sum_y,
    SUM(CAST(Square_Meters AS FLOAT) * sum_sales) AS sum_xy,
    SUM(CAST(Square_Meters AS FLOAT) * CAST(Square_Meters AS FLOAT)) AS sum_x2,
    SUM(sum_sales * sum_sales) AS sum_y2,
    --Formula de Pearson armada con las variables
    ((COUNT(*) * SUM(CAST(Square_Meters AS FLOAT) * sum_sales)) - (SUM(CAST(Square_Meters AS FLOAT)) * SUM(sum_sales)))
         /
    ( SQRT(
            (COUNT(*) * SUM(CAST(Square_Meters AS FLOAT) * CAST(Square_Meters AS FLOAT)) - POWER(SUM(CAST(Square_Meters AS FLOAT)), 2))
            *
            (COUNT(*) * SUM(sum_sales * sum_sales) - POWER(SUM(sum_sales), 2)))
         
    ) AS Correlation_Coefficient
FROM StoreSales;


--Analisis: determinando ventas de las tiendas segun su tamaño

WITH StoreSales AS (
    SELECT 
        st.StoreKey,
        CAST(st.Square_Meters AS FLOAT) AS Square_Meters,
        SUM(p.Unit_Price_USD * s.Quantity) AS Actual_Sales
    FROM Stores st
    JOIN Sales s ON st.StoreKey = s.StoreKey
    JOIN Products p ON s.ProductKey = p.ProductKey
    WHERE st.StoreKey <> 0
    GROUP BY st.StoreKey, st.Square_Meters
),
RegressionCoefficients AS (
    SELECT
        (
            (COUNT(*) * SUM(Square_Meters * Actual_Sales)) - (SUM(Square_Meters) * SUM(Actual_Sales))
        )
        /
        (
            (COUNT(*) * SUM(Square_Meters * Square_Meters)) - POWER(SUM(Square_Meters), 2)
        ) AS Slope,
        AVG(Actual_Sales) AS Avg_Y,
        AVG(Square_Meters) AS Avg_X
    FROM StoreSales
)
SELECT
    ss.StoreKey,
    ss.Square_Meters,
    ss.Actual_Sales,
    (rc.Avg_Y + rc.Slope * (ss.Square_Meters - rc.Avg_X)) AS Predicted_Sales,
    ss.Actual_Sales - (rc.Avg_Y + rc.Slope * (ss.Square_Meters - rc.Avg_X)) AS Residual,
    RANK() OVER (ORDER BY ss.Actual_Sales - (rc.Avg_Y + rc.Slope * (ss.Square_Meters - rc.Avg_X)) DESC) AS Overperform_Rank
FROM StoreSales ss
CROSS JOIN RegressionCoefficients rc
ORDER BY Residual DESC;


-- ANALISIS SEGMENTACION DE CLIENTES POR GASTO_TOTAL
SELECT * FROM Customers;
SELECT * FROM Sales;
SELECT * FROM Products;
GO 

CREATE VIEW vw_CustomerQuartiles AS

GO

 WITH CustomerSpend AS (
    SELECT
        c.CustomerKey,
        SUM(p.Unit_Price_USD * s.Quantity) AS Gasto_Total
    FROM Customers c
    JOIN Sales s ON c.CustomerKey = s.CustomerKey
    JOIN Products p ON s.ProductKey = p.ProductKey
    GROUP BY c.CustomerKey
),
Quartiles AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY Gasto_Total DESC) AS Spend_Quartile
    FROM CustomerSpend
)
SELECT
    Spend_Quartile,
    COUNT(*) AS Cantidad_Clientes,
    SUM(Gasto_Total) AS Ingreso_Total_Cuartil,
    -- % que representa este cuartil sobre el total general
    CAST(SUM(Gasto_Total) AS FLOAT) / SUM(SUM(Gasto_Total)) OVER () * 100 AS Pct_del_Total
FROM Quartiles
GROUP BY Spend_Quartile
;

GO 

--KIPS PARA DASHBOARD 
--1. ingresos totales mensuales con running total.

SELECT * FROM Products;
SELECT * FROM Stores;
SELECT * FROM Exchange_rates;
SELECT * FROM sales;

WITH salesmonth AS (

        SELECT  DATETRUNC(month, s.order_date) AS month_,
                SUM(p.Unit_price_USD * s.Quantity) AS sales_month
        FROM sales s 
        JOIN Products p 
             ON s.ProductKey = p.ProductKey
        GROUP BY DATETRUNC(month, s.order_date)  
 )
 SELECT 
        month_,
        sales_month,
        LAG(sales_month, 1,0) OVER(ORDER BY month_) AS sales_last_month,
        SUM(sales_month) OVER (ORDER BY month_) AS running_total,
       CASE 
        WHEN LAG(sales_month, 1, 0) OVER(ORDER BY month_) = 0 THEN NULL
        ELSE (sales_month - LAG(sales_month, 1, 0) OVER(ORDER BY month_)) 
         / LAG(sales_month, 1, 0) OVER(ORDER BY month_) *100
END AS pct_growth_mon
FROM salesmonth
ORDER BY month_;

--2. Ganancia total mensual

WITH profitmonth AS (
    SELECT  
        DATETRUNC(month, s.order_date) AS month_,
        SUM((p.Unit_Price_USD - p.Unit_Cost_USD) * s.Quantity) AS profit_month
    FROM sales s 
    JOIN Products p 
        ON s.ProductKey = p.ProductKey
    GROUP BY DATETRUNC(month, s.order_date)
)
SELECT 
    month_,
    profit_month,
    LAG(profit_month, 1, 0) OVER(ORDER BY month_) AS profit_last_month,
    SUM(profit_month) OVER (ORDER BY month_) AS running_total_profit,
     CASE 
        WHEN LAG(profit_month, 1, 0) OVER(ORDER BY month_) = 0 THEN NULL
        ELSE (profit_month - LAG(profit_month, 1, 0) OVER(ORDER BY month_)) 
         / LAG(profit_month, 1, 0) OVER(ORDER BY month_) * 100
         END AS profit_growth_mon
FROM profitmonth
ORDER BY month_;

--3. AVG DE TICKET PROMEDIO

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Stores;
SELECT * FROM Exchange_rates;
SELECT * FROM sales;

WITH sum_order AS (
SELECT 
        s.order_number,
        SUM(p.Unit_Price_USD * s.Quantity) AS sum_order
FROM Sales s 
  JOIN Products p 
  ON s.ProductKey = p.ProductKey
GROUP BY s.Order_Number
)
SELECT 
  AVG(sum_order) AS avg_ticket
FROM sum_order
;

--4. ventas promedio por tienda
WITH sales_stores AS (

    SELECT 
        st.storekey,
         SUM(p.Unit_Price_USD * s.Quantity) AS sum_sales
FROM Stores st
    JOIN Sales s 
        ON st.StoreKey = s.StoreKey
    JOIN Products p 
        ON s.ProductKey = p.ProductKey
WHERE st.StoreKey <> 0 
GROUP BY  st.storekey
)
SELECT 
    AVG(sum_sales) AS avg_sales_per_store
FROM sales_stores;

--CREANDO VIWE DE SALES PARA POWER BI 

CREATE VIEW vw_Sales AS
SELECT 
    s.*,
    (p.Unit_Price_USD - p.Unit_Cost_USD) AS Margin
FROM Sales s
JOIN Products p 
    ON s.ProductKey = p.ProductKey;

SELECT TOP 10 * FROM vw_Sales;