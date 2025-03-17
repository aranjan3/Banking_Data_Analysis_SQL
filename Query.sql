create database project;
use project;
select * from accounts;
select * from customers;
select concat(first_name, ' ', last_name) as full_name from customers;
select * from transactions;
-- Q1. 
-- apoorv ranjan
SELECT DISTINCT CONCAT(c.first_name, ' ', c.last_name) AS full_name
FROM customers c LEFT JOIN accounts a
ON c.customer_id = a.customer_id LEFT JOIN transactions t 
ON a.account_number = t.account_number
WHERE YEAR(t.transaction_date) != YEAR(CURRENT_DATE) - 1;
-- Q2
-- apoorv ranjan
select account_number,month(transaction_date) as transaction_month, round(sum(amount),3) as Total_Amount
from transactions 
group by account_number, month(transaction_date);
-- Q3. 
-- apoorv ranjan 
WITH LastQuarterTransactions AS (
    SELECT 
        t.account_number,
        t.amount,
        t.transaction_date
    FROM transactions t
    WHERE t.transaction_type = 'deposit' -- Only consider deposits
      AND QUARTER(t.transaction_date) = QUARTER(CURRENT_DATE - INTERVAL 3 MONTH) -- Last quarter
      AND YEAR(t.transaction_date) = YEAR(CURRENT_DATE - INTERVAL 3 MONTH) -- Ensure it matches the year of the last quarter
),
BranchDeposits AS (
    SELECT 
        a.branch_id,
        SUM(lqt.amount) AS total_deposits
    FROM LastQuarterTransactions lqt
    JOIN accounts a
        ON lqt.account_number = a.account_number
    GROUP BY a.branch_id
)
SELECT 
    b.branch_id,
    b.branch_name,
    bd.total_deposits,
    RANK() OVER (ORDER BY bd.total_deposits DESC) AS branch_rank
FROM BranchDeposits bd
JOIN branch b
    ON bd.branch_id = b.branch_id
ORDER BY branch_rank;
-- Q4
-- apoorv ranjan
select concat(c.first_name , ' ', c.last_name) as full_name, round(sum(t.amount),3) as Total_amount, t.transaction_type from customers c
left join accounts a 
on c.customer_id = a.customer_id
left join transactions t
on a.account_number = t.account_number
where t.transaction_type = 'deposit'
group by full_name
order by total_amount desc
limit 1;

-- Q5 
-- apoorv ranjan
SELECT 
    a.account_number,
    DAY(t.transaction_date) AS transaction_day, 
    COUNT(t.transaction_id) AS transaction_count
FROM accounts a
LEFT JOIN transactions t 
    ON a.account_number = t.account_number
GROUP BY a.account_number, DAY(t.transaction_date)
HAVING COUNT(t.transaction_id) > 2;
-- Q6
-- apoorv ranjan
SELECT 
    AVG(monthly_transaction_count) AS avg_transactions_per_customer_account_per_month
FROM (
    SELECT 
        a.customer_id,
        a.account_number,
        MONTH(t.transaction_date) AS transaction_month,
        COUNT(t.transaction_id) AS monthly_transaction_count
    FROM accounts a
    LEFT JOIN transactions t 
        ON a.account_number = t.account_number
    WHERE t.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) -- Only consider the last 12 months
    GROUP BY a.customer_id, a.account_number, MONTH(t.transaction_date)
) AS monthly_summary;
-- Q7 
-- apoorv ranjan
SELECT 
    DATE(transaction_date) AS transaction_day,
    SUM(amount) AS total_transaction_volume
FROM transactions
WHERE 
    YEAR(transaction_date) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
    AND MONTH(transaction_date) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
GROUP BY DATE(transaction_date)
ORDER BY transaction_day;

-- Q8 
-- apoorv ranjan 
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, CURDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, CURDATE()) BETWEEN 18 AND 30 THEN '18-30'
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, CURDATE()) BETWEEN 31 AND 60 THEN '31-60'
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, CURDATE()) > 60 THEN '60+'
    END AS age_group,
    SUM(t.amount) AS total_transaction_amount
FROM customers c
INNER JOIN accounts a
    ON c.customer_id = a.customer_id
INNER JOIN transactions t
    ON a.account_number = t.account_number
WHERE t.transaction_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
GROUP BY age_group
ORDER BY total_transaction_amount DESC;

-- Q9
-- apoorv ranjan
SELECT 
    b.branch_id,
    AVG(a.balance) AS avg_balance
FROM 
    accounts a
INNER JOIN 
    branch b ON a.branch_id = b.branch_id
GROUP BY 
    b.branch_id
ORDER BY 
    avg_balance DESC
LIMIT 1;

-- Q10 
-- apoorv ranjan
WITH monthly_end_balance AS (
    SELECT 
        a.customer_id,
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS month,  -- Extract year-month
        MAX(a.balance) AS end_month_balance
    FROM 
        accounts a
    INNER JOIN 
        transactions t ON a.account_number = t.account_number
    WHERE 
        t.transaction_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 12 MONTH) AND CURDATE()
    GROUP BY 
        a.customer_id, DATE_FORMAT(t.transaction_date, '%Y-%m')
)
SELECT 
    month,
    AVG(end_month_balance) AS avg_balance_per_customer
FROM 
    monthly_end_balance
GROUP BY 
    month
ORDER BY 
    month;
