-- How many unique nodes are there on the Data Bank system?

select count(distinct(node_id)) as NodeCount from Customer_nodes;

select distinct(region_name) from regions;

-- How many customers are allocated to each region?

select region_id, count(*) as TotalCount from Customer_nodes group by region_id order by TotalCount desc;

-- What is the number of nodes per region?

select c.region_id, region_name, count(distinct(node_id)) as node_count from Customer_nodes as c left outer join regions as r on c.region_id=r.region_id group by region_name order by region_id asc;

-- How many days on average are customers reallocated to a different node?
WITH node_days AS(
select customer_id, node_id, end_date-start_date as days_in_node from Customer_nodes WHERE end_date != '9999-12-31' group by customer_id, node_id, end_date,start_date),

total_node_days AS(
select customer_id, node_id, sum(days_in_node) total_days_in_node from node_days group by customer_id, node_id)

select round(avg(total_days_in_node)) as avg_total_days_in_node from total_node_days;

-- What is the unique count and total amount for each transaction type?

select txn_type, count(customer_id) as transaction_count, sum(txn_amount) as total_amount from customer_transactions GROUP BY txn_type;

--  What is the average total historical deposit counts and amounts for all customers?

WITH deposits AS (
select customer_id, count(customer_id) as transaction_count, avg(txn_amount) as avg_amount from customer_transactions where txn_type = 'deposit' group by customer_id)

select ROUND(AVG(transaction_count)) AS avg_deposit_count, ROUND(AVG(avg_amount)) AS avg_deposit_amt FROM deposits;


-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

select date_format(txn_date,'%b') as Mon from customer_transactions group by Mon;

select date_format(txn_date,'%m') as Mon from customer_transactions group by Mon;

select txn_type, count(*) from customer_transactions group by txn_type;

WITH monthly_transactions AS (
select customer_id,  date_format(txn_date,'%b') as Mon,
SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
FROM data_bank.customer_transactions
GROUP BY customer_id, Mon)

Select Mon, count(distinct(customer_id)) from monthly_transactions where deposit_count > 1 and (purchase_count>=1 or withdrawal_count >=1) group by Mon order by Mon;





