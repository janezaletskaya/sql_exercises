-- Задание 1
-- Примените оконные функции к таблице products и с помощью ранжирующих функций упорядочьте все товары по цене —
-- от самых дорогих к самым дешёвым. Добавьте в таблицу следующие колонки:
-- Колонку product_number с порядковым номером товара
-- Колонку product_rank с рангом товара с пропусками рангов
-- Колонку product_dense_rank с рангом товара без пропусков рангов
-- Поля в результирующей таблице: product_id, name, price, product_number, product_rank, product_dense_rank

SELECT
    product_id,
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS product_number,
    RANK() OVER (ORDER BY price DESC) AS product_rank,
    DENSE_RANK() OVER (ORDER BY price DESC) AS product_dense_rank
FROM products;


-- Задание 2
-- Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке для каждой
-- записи проставьте цену самого дорогого товара. Колонку с этим значением назовите max_price.
-- Затем для каждого товара посчитайте долю его цены в стоимости самого дорогого товара.
-- Полученные доли округлите до двух знаков после запятой. Колонку с долями назовите share_of_max.
-- Выведите всю информацию о товарах, включая значения в новых колонках.
-- Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, max_price, share_of_max

SELECT
    product_id,
    name,
    price,
    MAX(price) OVER () AS max_price,
    ROUND(price / MAX(price) OVER (), 2) AS share_of_max
FROM products
ORDER BY price DESC, product_id;


-- Задание 3
-- Примените две оконные функции к таблице products. Одну с агрегирующей функцией MAX, а другую с агрегирующей функцией
-- MIN — для вычисления максимальной и минимальной цены.
-- Для двух окон задайте инструкцию ORDER BY по убыванию цены. Поместите результат вычислений в две колонки max_price и min_price.
-- Выведите всю информацию о товарах, включая значения в новых колонках.
-- Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, max_price, min_price

SELECT
    product_id,
    name,
    price,
    MAX(price) OVER (ORDER BY price DESC) AS max_price,
    MIN(price) OVER (ORDER BY price DESC) AS min_price
FROM products
ORDER BY price DESC, product_id;

-- Задание 4
-- Ранжирование товаров по цене (product_number, product_rank, product_dense_rank)
SELECT
    product_id,
    name,
    price,
    row_number() OVER (ORDER BY price DESC) AS product_number,
    rank() OVER (ORDER BY price DESC) AS product_rank,
    dense_rank() OVER (ORDER BY price DESC) AS product_dense_rank
FROM
    products;



-- Задание 5
-- Цена самого дорогого товара и доля цены каждого товара от максимальной
SELECT
    product_id,
    name,
    price,
    max(price) OVER () AS max_price,
    round(price / max(price) OVER (), 2) AS share_of_max
FROM
    products
ORDER BY
    price DESC,
    product_id;



-- Задание 6
-- MAX и MIN цена по убыванию цены
SELECT
    product_id,
    name,
    price,
    max(price) OVER (ORDER BY price DESC) AS max_price,
    min(price) OVER (ORDER BY price DESC) AS min_price
FROM
    products
ORDER BY
    price DESC,
    product_id;



-- Задание 7
-- Число заказов по дням и накопительная сумма заказов
WITH q1 AS (
    SELECT
        creation_time::date AS date,
        count(order_id) AS orders_count
    FROM
        orders
    WHERE
        order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
    GROUP BY
        creation_time::date
)
SELECT
    date,
    orders_count,
    SUM(orders_count) OVER (ORDER BY date)::integer AS orders_count_cumulative
FROM
    q1;



-- Задание 8
-- Порядковый номер заказа пользователя (ROW_NUMBER)
SELECT
    user_id,
    order_id,
    time,
    row_number() OVER (
        PARTITION BY user_id
        ORDER BY time
    ) AS order_number
FROM
    user_actions
WHERE
    order_id NOT IN (
        SELECT order_id FROM user_actions WHERE action = 'cancel_order'
    )
ORDER BY
    user_id,
    order_number
LIMIT 1000;



-- Задание 9
-- Интервал между заказами пользователя (LAG, AGE)
SELECT
    user_id,
    order_id,
    time,
    row_number() OVER (
        PARTITION BY user_id
        ORDER BY time
    ) AS order_number,
    lag(time, 1) OVER (
        PARTITION BY user_id
        ORDER BY time
    ) AS time_lag,
    age(
        time,
        lag(time, 1) OVER (
            PARTITION BY user_id
            ORDER BY time
        )
    ) AS time_diff
FROM
    user_actions
WHERE
    order_id NOT IN (
        SELECT order_id FROM user_actions WHERE action = 'cancel_order'
    )
ORDER BY
    user_id,
    order_number
LIMIT 1000;



-- Задание 10
-- Среднее время между заказами пользователя в часах
WITH q1 AS (
    SELECT
        user_id,
        row_number() OVER (
            PARTITION BY user_id
            ORDER BY time
        ) AS order_number,
        lag(time, 1) OVER (
            PARTITION BY user_id
            ORDER BY time
        ) AS time_lag,
        age(
            time,
            lag(time, 1) OVER (
                PARTITION BY user_id
                ORDER BY time
            )
        ) AS time_diff
    FROM
        user_actions
    WHERE
        order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
)
SELECT
    user_id,
    round(avg(extract(epoch FROM time_diff)) / 3600)::integer AS hours_between_orders
FROM
    q1
WHERE
    time_diff IS NOT NULL
GROUP BY
    user_id
ORDER BY
    user_id
LIMIT 1000;



-- Задание 11
-- Скользящее среднее числа заказов за 3 предыдущих дня
WITH daily_orders AS (
    SELECT
        creation_time::date AS date,
        count(*) AS orders_count
    FROM
        orders
    WHERE
        order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
    GROUP BY
        creation_time::date
)
SELECT
    date,
    orders_count,
    round(
        avg(orders_count) OVER (
            ORDER BY date
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ),
        2
    ) AS moving_avg
FROM
    daily_orders;



-- Задание 12
-- Курьеры, доставившие больше среднего в сентябре 2022 года
WITH q1 AS (
    SELECT
        courier_id,
        count(order_id) AS delivered_orders,
        round(avg(count(order_id)) OVER (), 2) AS avg_delivered_orders
    FROM
        courier_actions
    WHERE
        action = 'deliver_order'
        AND date_part('year', time) = 2022
        AND date_part('month', time) = 9
    GROUP BY
        courier_id
)
SELECT
    courier_id,
    delivered_orders,
    avg_delivered_orders,
    CASE WHEN delivered_orders > avg_delivered_orders THEN 1 ELSE 0 END AS is_above_avg
FROM
    q1
ORDER BY
    courier_id;



-- Задание 13
-- Число первых и повторных заказов по датам
WITH ordered_actions AS (
    SELECT
        user_id,
        order_id,
        date(time) AS date,
        rank() OVER (PARTITION BY user_id ORDER BY time) AS rank,
        count(order_id) OVER (PARTITION BY user_id, date(time)) AS same_time_orders_count
    FROM
        user_actions
    WHERE
        action = 'create_order'
        AND order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
), marked_orders AS (
    SELECT
        date,
        CASE WHEN rank = 1 THEN 'Первый' ELSE 'Повторный' END AS order_type,
        order_id,
        same_time_orders_count
    FROM
        ordered_actions
)
SELECT
    date,
    order_type,
    count(order_id) AS orders_count
FROM
    marked_orders
GROUP BY
    date,
    order_type
ORDER BY
    date,
    order_type;



-- Задание 14
-- Доля первых и повторных заказов по датам
WITH ordered_actions AS (
    SELECT
        user_id,
        order_id,
        date(time) AS date,
        rank() OVER (PARTITION BY user_id ORDER BY time) AS rank,
        count(order_id) OVER (PARTITION BY user_id, date(time)) AS same_time_orders_count
    FROM
        user_actions
    WHERE
        action = 'create_order'
        AND order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
), marked_orders AS (
    SELECT
        date,
        CASE WHEN rank = 1 THEN 'Первый' ELSE 'Повторный' END AS order_type,
        order_id,
        same_time_orders_count
    FROM
        ordered_actions
), agg_table AS (
    SELECT
        date,
        order_type,
        count(order_id) AS orders_count
    FROM
        marked_orders
    GROUP BY
        date,
        order_type
)
SELECT
    date,
    order_type,
    orders_count,
    round(
        orders_count / (sum(orders_count) OVER (PARTITION BY date)),
        2
    ) AS orders_share
FROM
    agg_table
ORDER BY
    date,
    order_type;



-- Задание 15
-- Средняя цена товаров и средняя цена без самого дорогого
SELECT
    product_id,
    name,
    price,
    round(avg(price) OVER (), 2) AS avg_price,
    round(
        avg(price) FILTER (WHERE price < (SELECT max(price) FROM products)) OVER (),
        2
    ) AS avg_price_filtered
FROM
    products
ORDER BY
    price DESC,
    product_id;



-- Задание 16
-- Накопительные оформленные и отменённые заказы, cancel_rate
SELECT
    user_id,
    order_id,
    action,
    time,
    sum(CASE WHEN action = 'create_order' THEN 1 ELSE 0 END)
        OVER (PARTITION BY user_id ORDER BY time) AS created_orders,
    sum(CASE WHEN action = 'cancel_order' THEN 1 ELSE 0 END)
        OVER (PARTITION BY user_id ORDER BY time) AS canceled_orders,
    round(
        sum(CASE WHEN action = 'cancel_order' THEN 1.0 ELSE 0 END)
            OVER (PARTITION BY user_id ORDER BY time)
        / nullif(
            sum(CASE WHEN action = 'create_order' THEN 1 ELSE 0 END)
                OVER (PARTITION BY user_id ORDER BY time), 0
        ),
        2
    ) AS cancel_rate
FROM
    user_actions
ORDER BY
    user_id,
    order_id,
    time
LIMIT 1000;



-- Задание 17
-- Топ 10% курьеров по количеству доставленных заказов
WITH courier_deliveries AS (
    SELECT
        courier_id,
        count(*) AS orders_count
    FROM
        courier_actions
    WHERE
        action = 'deliver_order'
    GROUP BY
        courier_id
), ranked_couriers AS (
    SELECT
        courier_id,
        orders_count,
        rank() OVER (ORDER BY orders_count DESC, courier_id) AS courier_rank,
        percent_rank() OVER (ORDER BY orders_count DESC, courier_id) AS pct_rank
    FROM
        courier_deliveries
), top_couriers AS (
    SELECT
        courier_id,
        orders_count,
        courier_rank
    FROM
        ranked_couriers
    WHERE
        pct_rank <= 0.1
)
SELECT
    *
FROM
    top_couriers
ORDER BY
    courier_rank
LIMIT (
    SELECT ceil(count(DISTINCT courier_id) * 0.1) FROM courier_actions
);



-- Задание 18
-- Стоимость заказа, ежедневная выручка, доля заказа в выручке за день
WITH order_products AS (
    SELECT
        o.order_id,
        o.creation_time,
        unnest(o.product_ids) AS product_id
    FROM
        orders o
    WHERE
        o.order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
), order_prices AS (
    SELECT
        op.order_id,
        op.creation_time,
        SUM(p.price) AS order_price
    FROM
        order_products op
        JOIN products p ON op.product_id = p.product_id
    GROUP BY
        op.order_id,
        op.creation_time
), daily_revenue AS (
    SELECT
        date(creation_time) AS order_date,
        SUM(order_price) AS daily_revenue
    FROM
        order_prices
    GROUP BY
        order_date
), order_revenue_share AS (
    SELECT
        op.order_id,
        op.creation_time,
        op.order_price,
        dr.daily_revenue,
        round((op.order_price / dr.daily_revenue) * 100, 3) AS percentage_of_daily_revenue
    FROM
        order_prices op
        JOIN daily_revenue dr ON date(op.creation_time) = dr.order_date
)
SELECT
    order_id,
    creation_time,
    order_price,
    daily_revenue,
    percentage_of_daily_revenue
FROM
    order_revenue_share
ORDER BY
    date(creation_time) DESC,
    percentage_of_daily_revenue DESC,
    order_id;



-- Задание 19
-- Ежедневная выручка, абсолютный и относительный прирост выручки
WITH order_details AS (
    SELECT
        o.order_id,
        o.creation_time::date AS order_date,
        unnest(o.product_ids) AS product_id
    FROM
        orders o
    WHERE
        o.order_id NOT IN (
            SELECT order_id FROM user_actions WHERE action = 'cancel_order'
        )
), product_prices AS (
    SELECT
        od.order_id,
        od.order_date,
        SUM(p.price) AS order_price
    FROM
        order_details od
        JOIN products p ON od.product_id = p.product_id
    GROUP BY
        od.order_id,
        od.order_date
), daily_revenue AS (
    SELECT
        order_date,
        SUM(order_price) AS daily_revenue
    FROM
        product_prices
    GROUP BY
        order_date
), revenue_growth AS (
    SELECT
        order_date,
        daily_revenue,
        daily_revenue - lag(daily_revenue) OVER (ORDER BY order_date) AS revenue_growth_abs,
        CASE
            WHEN lag(daily_revenue) OVER (ORDER BY order_date) IS NULL THEN 0
            ELSE round(
                (daily_revenue - lag(daily_revenue) OVER (ORDER BY order_date))
                / nullif(lag(daily_revenue) OVER (ORDER BY order_date), 0) * 100,
                1
            )
        END AS revenue_growth_percentage
    FROM
        daily_revenue
)
SELECT
    order_date AS date,
    round(daily_revenue, 1) AS daily_revenue,
    coalesce(round(revenue_growth_abs, 1), 0) AS revenue_growth_abs,
    coalesce(revenue_growth_percentage, 0) AS revenue_growth_percentage
FROM
    revenue_growth
ORDER BY
    order_date ASC;


-- Задание 20
-- Медианная стоимость заказа (median_price)
WITH main_table AS (
    SELECT
        order_price,
        ROW_NUMBER() OVER (ORDER BY order_price) AS row_number,
        COUNT(*) OVER () AS total_rows
    FROM (
        SELECT
            SUM(price) AS order_price
        FROM (
            SELECT
                order_id,
                product_ids,
                unnest(product_ids) AS product_id
            FROM
                orders
            WHERE
                order_id NOT IN (
                    SELECT order_id FROM user_actions WHERE action = 'cancel_order'
                )
        ) t3
        LEFT JOIN products USING (product_id)
        GROUP BY order_id
    ) t1
)
SELECT
    AVG(order_price) AS median_price
FROM
    main_table
WHERE
    row_number BETWEEN total_rows / 2.0 AND total_rows / 2.0 + 1;


