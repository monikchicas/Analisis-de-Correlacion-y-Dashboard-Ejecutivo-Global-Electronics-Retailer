[🇪🇸 Español](README.md) | 🇬🇧 English

# DataCo Global Supply Chain — Delivery Time Analysis and Economic Impact

## 1.0 Project Summary

Analysis of delivery times within DataCo Global's supply chain and the economic impact that customer retention (or loss) has on the company, using SQL Server and Power BI. A high percentage of orders delivered late was identified, making it necessary to find the possible root cause in order to understand whether this is a direct issue with the delivery process itself or an isolated problem caused by a different factor.

## 2.0 Business Problem

DataCo Global is a company that sells a variety of sports and fitness equipment, such as footwear, apparel, and watches, among others. The company sells across many countries on every continent.

During an exploratory analysis of actual vs. scheduled shipping days, averages were calculated and it was observed that actual delivery days consistently exceeded scheduled days. It is important to monitor this final stage of a company's supply chain and to measure the real and future impact that failing to meet these timeframes has on the business.

## 3.0 Data Source

Dataset name: **DataCo Smart Supply Chain for Big Data Analysis**

Link: <https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis>

The main dataset contains 180,519 rows in total; each row represents an Order_item belonging to a specific product within a complete order.

The date range of the analysis spans from 2015-01-01 to 2018-01-31. The dataset folder contains 3 files, but 2 were discarded: tokenized_access_logs.csv (web clickstream/browsing data not related to this analysis) and DescriptionDataCoSupplyChain.csv (contains the column descriptions of the main file), which was used as a reference to understand the business context.

## 4.0 Tools Used

SQL Server / SSMS, Power BI Desktop, DAX, Git/GitHub

## 5.0 Methodology

The analysis was designed to answer at least 5 questions arising from the exploratory analysis. Starting from a general table of company activity, only the columns involved in the business questions were selected.

The results of these questions showed that a very deep level of granularity was not necessary for this analysis.

Once the 5 questions were answered, the next step was building the visualization through a Power BI Dashboard. To do this, a View was created in SQL Server in order to extract the columns involved in the analysis, along with additional columns that support interactivity in the Dashboard, such as results by Market, order method, etc.

It was necessary to create DAX measures for the calculated columns, mirroring the calculations already done in SQL Server.

## 6.0 Business Questions and Findings

### 1.0 What is the average of actual shipping days vs. scheduled days, and what is the difference between the averages?

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image1.png)](images/image1.png)

### 1.1 Result

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image2.png)](images/image2.png)

### 1.2 Finding

The result shows that the average of actual shipping days is higher than the scheduled delivery days, meaning that most orders arrive a little over half a day late to customers. This points to a serious deficiency at this final stage of the company's supply chain.

### 2.0 What percentage of orders fail to meet the estimated delivery days? Excluding canceled orders

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image3.png)](images/image3.png)

### 2.1 Result

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image4.png)](images/image4.png)

### 2.2 Finding

Filtering out only orders that were not canceled results in 57.29% of orders marked as "Late." Rounding the result, it can be concluded that for this company: **"6 out of every 10 customers receive their order late."** This opens the door to the next question — granularity needs to be assessed to find the root cause of the delivery problem.

### 3.0 Which regions show the most late orders?

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image5.png)](images/image5.png)

### 3.1 Result

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image6.png)](images/image6.png)

### 3.2 Finding

This query shows the order count by region, ranked by the percentage of late orders out of total orders placed. This answers the question: there isn't just 1 or 5 regions out of 23 accounting for most of the late orders — it is a systemic issue in the delivery process. No single region stands out in the data; every region has between 50%-60% of its orders delivered late.

This result opens the door to investigating another possible cause.

### 4.0 Which product categories show the highest number of late orders?

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image7.png)](images/image7.png)

### 4.1 Result

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image8.png)](images/image8.png) [![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image9.png)](images/image9.png)

### 4.2 Finding

The query was filtered with HAVING to include only categories with more than 200 orders, ensuring a reliable sample size. The result showed the same pattern as the previous question about regions: the problem lies in the shipping process across the board. Percentages range from 49% to 63%.

Finally, it is important to assess the impact these delays have on the company by analyzing customers who canceled their orders once the estimated delivery time was exceeded and never placed another order since. A window of 6 months after the last canceled order was considered a reasonable timeframe to expect a repeat purchase.

### 5.0 How many customers never made another purchase after their last canceled order?

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image10.png)](images/image10.png)

### 5.1 Result

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image11.png)](images/image11.png)

### 5.2 Finding

The result shows the total number of customers whose cancellation occurred at least 6 months before the dataset's final date (2018-01-31): 2,118 customers. Of those, 391 never placed another order. Rounding the percentage to 20%, it can be concluded that **"1 out of every 5 customers never returns to buy again."** At first glance this figure doesn't seem very impactful, which is why it needs to be analyzed in economic terms for the company.

### 5.3 How much money did it cost the company to not retain those customers?

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image12.png)](images/image12.png)

### 5.4 Result

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image13.png)](images/image13.png)

### 5.5 Finding

Those 391 customers represented $103,954.53 in historical profit for the company, with an average order value of $20.04 — nearly identical to that of retained customers ($21.30). This confirms that these lost customers were not low-value customers.

It is important to implement a strategy to improve delivery times and prevent the loss of new customers.

**Note:** Regarding figure variation — the values shown in this dashboard (calculated in DAX) show a minimal variation from the results originally obtained in SQL Server: 2,116 vs. 2,118 customers with a cancellation, and $103,637.85 vs. $103,954.53 in profit. This 0.09% difference is due to different handling of date/time edge cases between the DATEADD (SQL) and EDATE (DAX) functions when calculating the 6-month window. It does not affect the conclusions of the analysis.

## 7.0 Dashboard Visualization

[![](https://github.com/monikchicas/supply-chain-analysis/raw/main/images/image14.png)](images/image14.png)

The Dashboard allows filtering by Year and Shipping Mode, recalculating delivery time KPIs and comparative charts by region and category in real time. The lost/retained customers section (bottom of the dashboard) shows the historical accumulated total and does not respond to these filters, as it represents an independent customer retention analysis covering the entire dataset period (2015-2018).

## 8.0 Business Recommendations

1. Provide closer monitoring of product delivery status levels.

2. Identify the critical step in the final stage of the supply chain process, in order to prevent it from spiraling further out of control and bring it to a stable level.

3. Apply methodologies to gather customer feedback regarding product and overall service satisfaction.

4. Compensate customers with some type of discount on their next purchase if their order arrived late.

## 9.0 Limitations and Next Steps

**- Absence of customer satisfaction data:** the dataset does not include survey or rating data, so the relationship between delivery delays and customer perception could only be addressed indirectly, through the repurchase rate following a cancellation.

**- Shipping mode not formally analyzed:** although the "Shipping_Mode" column was incorporated into the data model and can be explored interactively in the dashboard, no formal SQL analysis was performed on its relationship with delivery punctuality. This is identified as a relevant business question for a future iteration of the project.

**- Minor difference between SQL and DAX:** the count of customers with a cancellation within the 6-month window came out to 2,118 in SQL and 2,116 in DAX. This 0.09% variation is attributed to differences in how date/time edge cases are handled between the DATEADD (SQL) and EDATE (DAX) functions, but it does not alter the conclusions of the analysis.

## 10.0 Repository Structure

| **File/Folder** | **Content** |
|---|---|
| readme-proyecto-supplychain.md | Full project documentation |
| sqlserver/queries_finales_supply_chain.sql | The 5 business questions with their queries and findings |
| powerbi/dashboard_supply_chain.pbix | Interactive dashboard (Power BI Desktop) |
| images/dashboard_screenshot.png | Screenshots of queries, results, and dashboard used in this README |
| data/dataset_link.md | Link to the original dataset source on Kaggle |

## 👤 Author

Monica Chicas — Data Analyst | Industrial Engineer

[LinkedIn](https://www.linkedin.com/in/monica-chicas-6132913bb/) · [GitHub](https://github.com/monikchicas)