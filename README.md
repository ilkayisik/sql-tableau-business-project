# sql-tableau-business-project

### __Exploration of a real world dataset using MySQL__

![schema_database](https://github.com/ilkayisik/sql-tableau-business-project/blob/main/data_sql_schema.png?raw=true)


In this project I explored a publicly available, real life dataset to generate insights and provide actionable recommendations to (a hypothetical) board of directors.

The aim of the project was to decide whether ENIAC (a European tech company specialised in Apple compatible accessories) should expand its business to the Brazilian market or not.

The company is exploring an expansion to the Brazilian market because it has a high eCommerce revenue and even a higher potential for growth but Eniac lacks the general knowledge of the market and also does not have ties with local providers, package delivery services, or customer service agencies. To solve these problems ENIAC is considering working with Magist a Brazilian Software as a Service company that offers a centralized order management system to connect small and medium-sized stores with the biggest Brazilian marketplaces. Eniac is considering signing a deal with Magist but not everyone in the company is sure that thisis the right decision.

There are two main concerns:

- Eniac’s catalog is 100% tech products, and heavily based on Apple-compatible accessories. It is not clear that the marketplaces Magist works with are a good place for these high-end tech products.

- Among Eniac’s efforts to have happy customers, fast deliveries are key. The delivery fees resulting from Magist’s deal with the public Post Office might be cheap, but at what cost? Are deliveries fast enough?


> The scripts in this repository contains the following code answering these questions:

- data/magist_dump.sql: the data that can be loaded into MySQL
- data/CSVs: the data in csv file format (that can be loaded into Tableau)
- magist_sql_queries.sql: the queries for exploring the data


![tableau_dashboard](https://github.com/ilkayisik/sql-tableau-business-project/blob/main/eniac_dashboard.png?raw=true
