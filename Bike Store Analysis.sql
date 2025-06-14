### 🛍️ **Sales & Orders**

##1. What are the **top 10 best-selling products** by quantity sold?
SELECT p.product_name, sum(oi.quantity) as quantitysold  FROM bike_data.order_items oi 
join bike_data.products p on oi.product_id  = p.product_id
group by p.product_id,p.product_name
order by quantitysold desc;


#2. What is the **total revenue** generated per month in the last year?
select MONTHNAME(order_date) as Month, sum(Round(quantity*list_price*(1-discount))) as Revenue_gen 
from bike_data.order_items oi
join bike_data.orders o on oi.order_id = o.order_id 
where Year(order_date) = 2018
group by MONTHNAME(order_date);


#3. Which **category and brand combination** drives the highest sales?
SELECT oi.product_id,p.product_name, sum(oi.quantity) as Sales, b.brand_name , c.category_name FROM bike_data.order_items oi
join bike_data.products p on oi.product_id = p.product_id
join bike_data.brands b on p.brand_id = b.brand_id
join bike_data.categories c on p.category_id = c.category_id
group by oi.product_id,p.product_name, b.brand_name , c.category_name
order by sales desc;

#4. What is the **average discount rate applied** per store or per staff?
#average staff discount
SELECT o.staff_id, s.first_name, Avg(discount) as average_discount FROM bike_data.orders o
join bike_data.order_items oi on o.order_id = oi.order_id
join bike_data.staffs s on o.staff_id = s.staff_id
group by o.staff_id, s.first_name;

#average store discount
SELECT o.store_id, s.store_name, Avg(discount) as average_discount FROM bike_data.orders o
join bike_data.order_items oi on o.order_id = oi.order_id
join bike_data.stores s on o.store_id = s.store_id
group by o.store_id, s.store_name;


#5. Which orders had **delayed shipping** beyond the required date?
SELECT *, DATEDIFF(shipped_date, required_date) as delay_days 
FROM bike_data.orders
where shipped_date > required_date;

### 👥 **Customer Behavior**

#6. Which customers have **placed the most orders** (by count or value)?
SELECT o.customer_id,c.first_name,c.last_name, count(*) as Orders 
FROM bike_data.orders o 
join bike_data.customers c on o.customer_id = c.customer_id
group by o.customer_id,c.first_name,c.last_name
order by Orders desc;

#7. What is the **average order value per customer**?
select c.customer_id, c.first_name,c.last_name, round(avg(quantity*list_price*(1-discount)),2) as Average_order_value from bike_data.order_items oi 
join bike_data.orders o on oi.order_id = o.order_id 
join bike_data.customers c on o.customer_id = c.customer_id
group by  c.customer_id, c.first_name,c.last_name; 

#8. Which customers haven’t made a purchase in the last 6 months?
select c.customer_id, c.first_name, c.last_name, c.email
from bike_data.customers c
where c.customer_id not in (
    select distinct o.customer_id
    from bike_data.orders o
    where o.order_date >= (
        select max(order_date) from bike_data.orders
    ) - interval 6 month
);


#9. What **states or cities** generate the highest revenue?
#State/City
select c.state, c.city, sum(quantity*list_price*(1-discount)) as Revenue
from bike_data.orders o 
join bike_data.order_items oi
on o.order_id = oi.order_id
join bike_data.customers c on o.customer_id = c.customer_id
group by state, c.city
order by Revenue desc;

#State
select c.state,sum(quantity*list_price*(1-discount)) as Revenue
from bike_data.orders o 
join bike_data.order_items oi
on o.order_id = oi.order_id
join bike_data.customers c on o.customer_id = c.customer_id
group by state
order by Revenue desc;

### 🏪 **Inventory & Stock**
#10. Which products are **low in stock** (e.g., <10 units) across stores?
select st.product_id, p.product_name, s.store_name,st.quantity
from bike_data.stores s
join  bike_data.stocks st on s.store_id = st.store_id  
join bike_data.products p on st.product_id = p.product_id
where st.quantity < 10; 

#11. What are the **stock levels per product across all stores**?
select p.product_name,s.store_name, sum(st.quantity) as Stock_level
from bike_data.stores s
join  bike_data.stocks st on s.store_id = st.store_id  
join bike_data.products p on st.product_id = p.product_id
group by p.product_name,s.store_name;


#12. Are there **products that are never sold** but still stocked?
select p.product_name from bike_data.products p
left join bike_data.order_items oi on p.product_id = oi.product_id
left join  bike_data.stocks s on p.product_id = s.product_id
where oi.product_id is null and s.quantity >= 1 ;


#13. How many **unique products** does each store carry?
select st.store_name, count(distinct product_name) as products from  bike_data.stocks sc
join bike_data.stores st on sc.store_id = st.store_id
join bike_data.products p on sc.product_id = p.product_id
group by st.store_name;

### 🧑‍💼 **Staff & Performance**

#14. Which staff members have **processed the most orders**?
select o.staff_id,s.first_name,s.last_name, count(order_id) as orders_Processed from bike_data.orders o 
join bike_data.staffs s on o.staff_id = s.staff_id 
group by o.staff_id,s.first_name,s.last_name 
order by orders_Processed desc;


#15. What’s the **average number of orders per staff** per month?
select o.staff_id, s.first_name, s.last_name, avg(monthly_orders) as avg_monthly_orders
from (
	select staff_id, year(order_date) as year, month(order_date) as month, count(order_id) as monthly_orders
	from bike_data.orders 
	group by staff_id, year(order_date), month(order_date)
) as o
join bike_data.staffs s on o.staff_id = s.staff_id 
group by o.staff_id, s.first_name, s.last_name 
order by avg_monthly_orders desc;


#16. Who are the **store managers**, and how many staff do they supervise?
#No manager table

#17. Are there any **inactive staff** still associated with active orders?
select s.staff_id, s.first_name, s.last_name from bike_data.staffs s
join bike_data.orders o on s.staff_id = o.staff_id 
where s.staff_id = 0 and order_status = 4;


#18. Which products have the **highest list price per category**?
select product_name, max(list_price) as max_product 
from bike_data.products
group by product_name
order by max_product desc;

#19. What’s the **average price difference** between brands within a category?
select p1.category_id, c.category_name, avg(abs(p1.list_price - p2.list_price)) as average_price_diff_bw_brands from bike_data.products p1 
join bike_data.products p2 on p1.category_id = p2.category_id and p1.brand_id <> p2.brand_id
join bike_data.categories c on p1.category_id = c.category_id
group by p1.category_id, c.category_name;

#20. Which model years are **still in inventory but have no sales**?
select distinct p.model_year, p.product_name from bike_data.products p 
join  bike_data.stocks s on p.product_id = s.product_id
where s.quantity > 0  and p.product_id not in (
select distinct oi.product_id
	from  bike_data.order_items oi  
	join bike_data.orders o on oi.order_id = o.order_id
	where o.order_status = !3 );

#21. What are the **monthly sales trends per category or brand**?
select Year(o.order_date) as Year, Monthname(o.order_date) as Month,c.category_name, round(sum(oi.quantity * oi.list_price *(1-oi.discount)),2) as Sales from bike_data.orders o
join bike_data.order_items oi on o.order_id = oi.order_id 
join bike_data.products p on oi.product_id = p.product_id 
join bike_data.categories c on p.category_id = c.category_id
where o.order_status = 4 
group by Year(o.order_date), Monthname(o.order_date), c.category_name;

#22. Are there **seasonal peaks** in sales for certain products?
select 
  p.product_name,
  monthname(o.order_date) as month,
  sum(oi.quantity) as total_units_sold
from bike_data.orders o
join bike_data.order_items oi on o.order_id = oi.order_id
join bike_data.products p on oi.product_id = p.product_id
where o.order_status = 4
group by p.product_name, monthname(o.order_date)
order by p.product_name, total_units_sold desc;


#23. How does **discounting affect sales volume** per product or category?
select 
  c.category_name,
  case 
    when oi.discount = 0 then '0% (no discount)'
    when oi.discount > 0 and oi.discount <= 0.1 then '1-10%'
    when oi.discount > 0.1 and oi.discount <= 0.3 then '11-30%'
    when oi.discount > 0.3 then '31%+'
    else 'unknown'
  end as discount_range,
  sum(oi.quantity) as total_units_sold
from bike_data.order_items oi
join bike_data.orders o on oi.order_id = o.order_id
join bike_data.products p on oi.product_id = p.product_id
join bike_data.categories c on p.category_id = c.category_id
where o.order_status = 4
group by c.category_name, discount_range
order by c.category_name, discount_range;


#24. What is the **order fulfillment time** across stores (shipped date - order date)?
select s.store_name, round(avg(datediff(shipped_date, order_date))) as Order_fulfillment_time from bike_data.stores s
join bike_data.orders o on s.store_id = o.store_id
where o.shipped_date is not null 
group by s.store_name


