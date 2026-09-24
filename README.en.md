[🇪🇸 Español](README.md) | us English

# Correlation Analysis and Executive Dashboard - Global Electronics Retailer

## 1.0 Project Summary

This project presents a correlation analysis applied to Global Electronics Retailer, focused primarily on the relationship between physical store size and total sales, complemented by a regression analysis to identify stores that outperform or underperform relative to their expected performance. The analysis is extended with a customer segmentation by total spend, which revealed that the top 25% of customers by spend generates 62.7% of the company's total revenue.

The tools used were SQL Server, for exploratory data analysis (EDA), data cleaning and modeling, and business queries; and Power BI, for data model construction, DAX measure calculation, and the final visualization of findings in an interactive executive dashboard.

## 2.0 Business Problem

Global Electronics Retailer is a multinational consumer electronics retail chain, with a presence in eight countries (United States, United Kingdom, Germany, France, Canada, Australia, Italy, and the Netherlands) through physical stores and an online sales channel. Its catalog covers categories such as audio, cameras, cell phones, computers, video games and toys, home appliances, entertainment (music, movies and books), and TVs.

Given an operation distributed across multiple countries and channels, company leadership needs to identify which factors relate to sales performance — at the store and customer level — in order to guide decisions on effective physical store distribution and identify opportunities for improvement.

## 3.0 Hypotheses

**H1 — Margin vs. Quantity Sold:** a relationship was expected between a product's unit margin and the quantity of units sold, under the premise that lower-margin (cheaper) products tend to sell in higher volume.

**H2 — Customer Age vs. Total Spend:** customer age was expected to have some degree of relationship with total accumulated spend.

**H3 — Store Size vs. Total Sales:** larger physical stores (in square meters) were expected to generate higher total sales, under the premise that more space allows for more inventory display and more customers served.

## 4.0 Data Source

The dataset used is "Global Electronics Retailer," freely available on the Maven Analytics Data Playground. It consists of 5 relational tables: Customers (15,266 rows), Products (2,517 rows), Stores (66 rows), Sales (62,884 rows), and Exchange_Rates (11,215 rows), covering transactions from January 2016 to February 2021.

The Exchange_Rates table was discarded from the analysis: since the Unit_Cost_USD and Unit_Price_USD columns in the Products table are already standardized in US dollars, the entire analysis was carried out in USD without needing currency conversion.

## 5.0 Tools Used

- **SQL Server / SSMS** — database modeling, exploratory data analysis (EDA), business queries, and correlation/regression calculation
- **Power BI Desktop** — data modeling, DAX measures, executive dashboard construction
- **Visual Studio Code** — project documentation in Markdown
- **GitHub** — version control and portfolio publishing

## 6.0 Methodology

The project began with importing the dataset's 5 tables into SQL Server and defining the data model: primary keys (simple and composite, as needed) and foreign keys were established between Sales and its dimension tables (Customers, Products, Stores), including adding an "Online" record to Stores to represent sales with no associated physical store.

The main analysis focused on selecting relevant numeric variables to calculate the Pearson correlation coefficient between them, evaluating the strength and direction of their relationship. The choice of these variables came from the exploratory data analysis (EDA) performed on all tables involved, within the business context.

Testing the first two hypotheses did not yield a relevant correlation, so no further analysis was pursued beyond documenting the result. The third hypothesis did show a moderate correlation, which led to a deeper analysis via linear regression, allowing the expected sales of a store to be predicted based on its size and classified according to its actual performance against that prediction.

To enrich the analysis and dashboard, relevant KPIs for the organization were calculated: total revenue, total margin, average ticket, average sales per store, as well as a customer segmentation by spend quartile and the running total of revenue and margin over time.

Once the SQL Server query phase was complete, the resulting tables and views were exported to Power BI for data modeling, DAX measure construction, and final visualization. Each key measure (KPIs, correlations) was validated by comparing its result in Power BI against the value obtained directly in SQL Server, confirming consistency between both tools.

## 7.0 Business Questions and Findings

### 7.1 Is there a relationship between a product's margin and the quantity sold?

![](images/image-margen-producto.png)

### 7.1.1 Result

![](images/image-resultado-mp.png)

### 7.1.2 Finding

The negative R result (-0.1186) indicates that, on average, higher margin is associated with a slightly lower quantity sold, and vice versa. According to the coefficient interpretation scale: (0-0.3) weak, (0.3-0.7) moderate, and (0.7-1) strong — so at 0.1186 it falls into the weak range, practically negligible.

In conclusion: a product's margin does not have a reliable relationship with its sales volume; margin cannot be used to predict whether something will sell a lot or a little.

Applying the coefficient of determination (R²) = (-0.1186)² = 0.014, margin explains 1.4% of the variation in units sold; the remaining 98.6% is due to other factors such as category, brand, product necessity, seasonality, etc.

### 7.2 Is there a relationship between customer age and total spend?

![](images/image-age-gasto.png)

### 7.2.1 Result

![](images/image-resultado-ag.png)

### 7.2.2 Finding

The result (r = -0.0019) indicates a practically null correlation between customer age and total spend — the value is so close to zero that no identifiable linear relationship exists between the two variables. In fact, it is an even weaker correlation than the one found between margin and quantity sold.

In conclusion: customer age is not a factor that explains or predicts how much a customer spends at the company. Customers of different ages spend similarly, on average — total spend appears to depend on other factors not explored in this hypothesis (purchase frequency, preferred product category, geographic location, among others).

### 7.3 Is a physical store's size related to its total sales?

![](images/image-stores-ventas.png)

### 7.3.1 Result

![](images/image-resultado-sv.png)

### 7.3.2 Finding

The result for this correlation was r = 0.6022, which, according to the interpretation scale used, falls into the **moderate** range. Being positive, it can be stated that a direct relationship exists between the variables: the larger a store (m²), the higher its total sales tend to be.

Applying the coefficient of determination (R² = 0.6022² ≈ 0.3626), store size explains approximately **36.3%** of the variation in total sales. The remaining 63.7% depends on other factors not included in this analysis, such as location, customer traffic, or product mix.

In conclusion: unlike the previous two hypotheses, store size does show a real relationship with sales performance, although it does not fully explain it. This result, together with the fact that the analysis was calculated on a sample of only 57 stores, motivated a deeper investigation via linear regression (see next question), to identify which specific stores deviate from this expected pattern.

### 7.4 Which stores outperform or underperform relative to their expected performance based on size?

![](images/image-rendimiento-tama.png)

### 7.4.1 Result

![](images/image-rendi-1.png)
![](images/image-rendi-2.png)

### 7.4.2 Finding

Based on the moderate correlation found between store size and sales (r = 0.6022), a simple linear regression analysis was applied to estimate each store's expected sales based on its size, calculating the slope and intercept of the best-fit line directly in SQL Server. With that prediction, each store's **residual** was calculated (actual sales minus predicted sales), and the window function `RANK()` was used to rank them from highest to lowest overperformance.

The most notable finding: a store of just 840 m² generated actual sales of $1,220,964 — well above the $541,042 its size predicted, more than double what was expected. At the opposite extreme, larger stores were identified with sales below their prediction, suggesting that factors other than physical size (location, management, product mix) are strongly influencing their performance.

In conclusion: store size alone does not guarantee good sales performance. Identifying stores that exceed their prediction allows the company to investigate which practices to replicate at other locations; identifying stores that fall short allows improvement efforts to be prioritized.

### 7.5 What share of revenue does the highest-spending customer segment represent?

![](images/image-ntile.png)

### 7.5.1 Result

![](images/image-resul-ntile.png)

### 7.5.2 Finding

Customers were segmented into 4 quartiles based on their accumulated total spend, using the window function `NTILE(4)`. Quartile 1 (the top 25% of spenders) generated **$34,981,970.95**, equivalent to **62.74%** of the company's total revenue — more than 6 out of every 10 dollars. At the opposite end, quartile 4 (the bottom 25%) accounted for just **2.68%** of revenue.

This concentration is even more pronounced than the classic 80/20 principle: in this case, a quarter of customers generate nearly two-thirds of the company's total revenue.

In conclusion: the customer base does not contribute evenly to revenue — there is a strong dependency on a small segment of high-value customers. Losing a portion of quartile 1 would have a disproportionately high financial impact compared to losing customers from the lower quartiles, which suggests that retention strategies should prioritize this group over the acquisition of new customers.

## 8.0 Dashboard Visualization

### Page 1 — Executive Summary

![](images/image-panel.png)

Presents the organization's 4 main KPIs (Total Revenue, Total Margin, Average Ticket, Average Sales per Store), the monthly revenue trend with running total, margin evolution, and the margin percentage over revenue over time. Filterable by Year and Country.

In the revenue trend, sharp monthly growth spikes are observed coinciding with December/January each year, suggesting seasonality tied to the year-end shopping season. Meanwhile, the margin percentage over revenue remains notably stable (between 58% and 59%) throughout the 6 years of the dataset, despite strong seasonal fluctuations in absolute revenue — indicating that the company's profitability is consistent regardless of each month's sales volume.

### Page 2 — Store Analysis

![](images/image-tienda.png)

Shows the main correlation finding (store size vs. revenue, with trend line) alongside a revenue breakdown by country. Filterable by Country.

### Page 3 — Customer Analysis

![](images/image-clientes.png)

Presents revenue concentration by spend quartile, along with a table of the top 10 customers by total spend. Filterable by Product Category.

## 9.0 Business Recommendations

**To the Expansion and Store Operations team:**

1. While a moderate relationship was confirmed between store size and total sales (r = 0.6022), this factor alone explains only 36% of that variation — therefore, **expansion or investment decisions should not be based solely on a store's physical size**. Size should be considered one factor among several, not the sole predictor of a location's success.

2. It is recommended to conduct a detailed operational analysis of the stores identified with the highest overperformance relative to their size (the most notable case: an 840 m² store with sales more than double what was expected). This analysis should include sales flow, product mix sold, transaction volume, and the profile of customers purchasing at those locations, with the goal of identifying practices that can be replicated at similarly sized stores that are underperforming.

**To the Customer Retention and Marketing team:**

3. The top 25% of customers by spend generate 62.74% of the company's total revenue, while the bottom 25% account for just 2.68%. Given this high concentration, it is recommended to prioritize retention and loyalty resources (loyalty programs, personalized attention, targeted offers) toward the top-spending segment (quartile 1) over new customer acquisition strategies — losing a fraction of this group would have a disproportionately larger financial impact than losing customers from the lower quartiles. It is further recommended to investigate which characteristics this segment's customers share (preferred product categories, purchase frequency, purchase channel) in order to replicate that profile in acquisition campaigns.

## 10.0 Limitations and Next Steps

**Limitations**

- The margin vs. quantity sold analysis excluded 25 products with no recorded sales, as they contribute no information to the relationship studied; this exclusion was a conscious decision, not an accidental omission.
- The store regression and ranking analysis was calculated on a sample of only 57 physical stores, making the result sensitive to individual outliers.
- Validation of Pearson's linearity assumption was done visually (via scatter plot), not through a formal statistical test; the normality assumption of the variables was not evaluated either.
- The analysis was carried out exclusively in USD, since the dataset's cost and price columns were already standardized in that currency; the Exchange_Rates table was discarded from the analysis as unnecessary under this scope.
- It was found that 79% of orders have no recorded delivery date, corresponding to purchases picked up directly in-store rather than shipped to a home address; this pattern is documented as an EDA finding but was not investigated further, being outside this project's scope.
- The margin vs. quantity and age vs. spend hypotheses showed no relevant relationship, but alternative variables that might better explain those behaviors (product category, purchase frequency, sales channel) were not investigated.

**Next Steps**

- Explore which variables better explain sales volume by product and spend by customer, given that margin and age were not relevant.
- Expand the store regression analysis by incorporating additional variables (location, store age) beyond physical size.
- Deepen customer segmentation with a full RFM model (Recency, Frequency, Monetary), rather than segmenting by total spend alone.
- Apply the lessons from this project to the next two planned portfolio projects, focused on data cleaning and data modeling (entity and table identification).

## 11.0 Repository Structure

| Folder/File | Description |
|---|---|
| `sqlserver/` | SQL Server scripts: database creation, modeling (PK/FK), views, correlation, regression, and KPI queries |
| `powerbi/` | Executive dashboard `.pbix` file |
| `images/` | SQL and dashboard result screenshots used in this README |
| `data/` | `.md` file with the link to the original dataset on Maven Analytics (CSV not included due to size) |
| `README.md` | This document |

## 👤 Author

Monica Chicas — Data Analyst | Industrial Engineer

[LinkedIn](https://www.linkedin.com/in/monica-chicas-6132913bb/) · [GitHub](https://github.com/monikchicas)
