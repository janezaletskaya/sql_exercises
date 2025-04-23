-- Задание 1
--Используя данные из таблицы user_actions, рассчитайте среднее число заказов всех пользователей нашего сервиса.
--Полученное среднее число заказов всех пользователей округлите до двух знаков после запятой.
--Колонку с этим значением назовите orders_avg.
--Поле в результирующей таблице: orders_avg
SELECT
    round(sum(orders_count) / count(distinct user_id), 2) AS orders_avg
FROM (
    SELECT
        user_id,
        count(order_id) AS orders_count
    FROM
        user_actions
    WHERE
        action = 'create_order'
    GROUP BY
        user_id
) AS sub1;

-- Задание 2
--Повторите запрос из предыдущего задания, но теперь вместо подзапроса используйте оператор WITH и табличное выражение.
--Условия задачи те же: используя данные из таблицы user_actions, рассчитайте среднее число заказов всех пользователей.
--Полученное среднее число заказов округлите до двух знаков после запятой. Колонку с этим значением назовите orders_avg.
--Поле в результирующей таблице: orders_avg

WITH sub_1 AS (
    SELECT
        user_id,
        count(order_id) AS orders_count
    FROM
        user_actions
    WHERE
        action = 'create_order'
    GROUP BY
        user_id
)
SELECT
    round(avg(orders_count), 2) AS orders_avg
FROM
    sub_1;

-- Задание 3
--Выведите из таблицы products информацию о всех товарах кроме самого дешёвого.
--Результат отсортируйте по убыванию id товара.
--Поля в результирующей таблице: product_id, name, price

SELECT
    product_id,
    name,
    price
FROM
    products
WHERE
    price != (
        SELECT min(price)
        FROM products
    )
ORDER BY
    product_id DESC;

-- Задание 4
--Выведите информацию о товарах в таблице products, цена на которые превышает среднюю цену всех товаров
--на 20 рублей и более. Результат отсортируйте по убыванию id товара.
--Поля в результирующей таблице: product_id, name, price

WITH sub_1 AS (
    SELECT avg(price) AS avg_price
    FROM products
)
SELECT
    product_id,
    name,
    price
FROM
    products
WHERE
    price >= (
        SELECT avg_price
        FROM sub_1
    ) + 20
ORDER BY
    product_id DESC;

-- Задание 5
--Посчитайте количество уникальных клиентов в таблице user_actions, сделавших за последнюю неделю хотя бы один заказ.
--Полученную колонку с числом клиентов назовите users_count. В качестве текущей даты, от которой откладывать неделю,
--используйте последнюю дату в той же таблице user_actions.
--Поле в результирующей таблице: users_count

WITH sub_1 AS (
    SELECT max(time) - interval '1 week' AS week_ago
    FROM user_actions
)
SELECT
    count(distinct user_id) AS users_count
FROM
    user_actions
WHERE
    time >= (
        SELECT week_ago
        FROM sub_1
    )
    AND action = 'create_order';

-- Задание 6
--Определите возраст самого молодого курьера мужского пола в таблице couriers, но в этот раз при расчётах
--в качестве первой даты используйте последнюю дату из таблицы courier_actions.
--Возраст курьера измерьте количеством лет, месяцев и дней и переведите его в тип VARCHAR.
--Полученную колонку со значением возраста назовите min_age.
--Поле в результирующей таблице: min_age

WITH sub_1 AS (
    SELECT max(time)::date AS max_date
    FROM courier_actions
)
SELECT
    min(age(sub_1.max_date, c.birth_date))::varchar AS min_age
FROM
    couriers c,
    sub_1
WHERE
    c.sex = 'male';

-- Задание 7
--Из таблицы user_actions с помощью подзапроса или табличного выражения отберите все заказы,
--которые не были отменены пользователями.
--Выведите колонку с id этих заказов. Результат запроса отсортируйте по возрастанию id заказа.
--Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
--Поле в результирующей таблице: order_id

WITH sub_1 AS (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
)
SELECT
    order_id
FROM
    user_actions
WHERE
    order_id NOT IN (
        SELECT order_id
        FROM sub_1
    )
ORDER BY
    order_id
LIMIT 1000;

-- Задание 8
--Используя данные из таблицы user_actions, рассчитайте, сколько заказов сделал каждый пользователь и
-- отразите это в столбце orders_count.
--В отдельном столбце orders_avg напротив каждого пользователя укажите среднее число заказов всех пользователей,
--округлив его до двух знаков после запятой.
--Также для каждого пользователя посчитайте отклонение числа заказов от среднего значения.
--Колонку с отклонением назовите orders_diff.
--Результат отсортируйте по возрастанию id пользователя. Выведите только первые 1000 строк результирующей таблицы.
--Поля в результирующей таблице: user_id, orders_count, orders_avg, orders_diff

WITH sub_1 AS (
    SELECT
        user_id,
        count(order_id) AS orders_count
    FROM
        user_actions
    WHERE
        action = 'create_order'
    GROUP BY
        user_id
)
SELECT
    s.user_id,
    s.orders_count,
    (SELECT round(avg(orders_count), 2) FROM sub_1) AS orders_avg,
    s.orders_count - (SELECT round(avg(orders_count), 2) FROM sub_1) AS orders_diff
FROM
    sub_1 s
ORDER BY
    s.user_id
LIMIT 1000;

-- Задание 9
--Назначьте скидку 15% на товары, цена которых превышает среднюю цену на все товары на 50 и более рублей,
--а также скидку 10% на товары, цена которых ниже средней на 50 и более рублей. Цену остальных товаров внутри диапазона
--(среднее - 50; среднее + 50) оставьте без изменений. При расчёте средней цены, округлите её до двух знаков после запятой.
--Выведите информацию о всех товарах с указанием старой и новой цены. Колонку с новой ценой назовите new_price.
--Результат отсортируйте сначала по убыванию прежней цены в колонке price, затем по возрастанию id товара.
--Поля в результирующей таблице: product_id, name, price, new_price

WITH sub_1 AS (
    SELECT round(avg(price), 2) AS avg_price
    FROM products
)
SELECT
    product_id,
    name,
    price,
    CASE
        WHEN price > (SELECT avg_price FROM sub_1) + 50 THEN price * 0.85
        WHEN price < (SELECT avg_price FROM sub_1) - 50 THEN price * 0.9
        ELSE price
    END AS new_price
FROM
    products
ORDER BY
    price DESC,
    product_id;

-- Задание 10
--Выясните, есть ли в таблице courier_actions такие заказы, которые были приняты курьерами,
--но не были созданы пользователями. Посчитайте количество таких заказов.
--Колонку с числом заказов назовите orders_count.
--Поле в результирующей таблице: orders_count

WITH accepted_orders AS (
    SELECT order_id
    FROM courier_actions
    WHERE action = 'accept_order'
), created_orders AS (
    SELECT order_id
    FROM user_actions
    WHERE action = 'create_order'
)
SELECT
    count(order_id) AS orders_count
FROM
    user_actions
WHERE
    order_id IN (SELECT order_id FROM accepted_orders)
    AND order_id NOT IN (SELECT order_id FROM created_orders);

-- Задание 11
--Выясните, есть ли в таблице courier_actions такие заказы, которые были приняты курьерами,
--но не были доставлены пользователям. Посчитайте количество таких заказов.
--Колонку с числом заказов назовите orders_count.
--Поле в результирующей таблице: orders_count

WITH accepted_orders AS (
    SELECT order_id
    FROM courier_actions
    WHERE action = 'accept_order'
), delivered_orders AS (
    SELECT order_id
    FROM courier_actions
    WHERE action = 'deliver_order'
)
SELECT
    count(distinct order_id) AS orders_count
FROM
    courier_actions
WHERE
    order_id IN (SELECT order_id FROM accepted_orders)
    AND order_id NOT IN (SELECT order_id FROM delivered_orders);

-- Задание 12
--Определите количество отменённых заказов в таблице courier_actions и выясните, есть ли в этой таблице такие заказы,
--которые были отменены пользователями, но при этом всё равно были доставлены. Посчитайте количество таких заказов.
--Колонку с отменёнными заказами назовите orders_canceled. Колонку с отменёнными,
--но доставленными заказами назовите orders_canceled_and_delivered.
--Поля в результирующей таблице: orders_canceled, orders_canceled_and_delivered

WITH canceled_orders AS (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
)
SELECT
    (SELECT count(*) FROM canceled_orders) AS orders_canceled,
    count(*) FILTER (
        WHERE order_id IN (SELECT order_id FROM canceled_orders) AND action = 'deliver_order'
    ) AS orders_canceled_and_delivered
FROM
    courier_actions;

-- Задание 13
--По таблицам courier_actions и user_actions снова определите число недоставленных заказов и среди них
--посчитайте количество отменённых заказов и количество заказов, которые не были отменены
--(и соответственно, пока ещё не были доставлены).
--Колонку с недоставленными заказами назовите orders_undelivered, колонку с отменёнными заказами
--назовите orders_canceled, колонку с заказами «в пути» назовите orders_in_process.
--Поля в результирующей таблице: orders_undelivered, orders_canceled, orders_in_process

SELECT
    count(distinct order_id) AS orders_undelivered,
    count(order_id) FILTER (WHERE action = 'cancel_order') AS orders_canceled,
    count(distinct order_id) - count(order_id) FILTER (WHERE action = 'cancel_order') AS orders_in_process
FROM
    user_actions
WHERE
    order_id IN (
        SELECT order_id
        FROM courier_actions
        WHERE order_id NOT IN (
            SELECT order_id
            FROM courier_actions
            WHERE action = 'deliver_order'
        )
    );

-- Задание 14
--Отберите из таблицы users пользователей мужского пола, которые старше всех пользователей женского пола.
--Выведите две колонки: id пользователя и дату рождения. Результат отсортируйте по возрастанию id пользователя.
--Поля в результирующей таблице: user_id, birth_date

WITH max_woman_age AS (
    SELECT min(birth_date)::date AS max_woman_age
    FROM users
    WHERE sex = 'female'
)
SELECT
    user_id,
    birth_date
FROM
    users
WHERE
    sex = 'male'
    AND birth_date::date < (
        SELECT max_woman_age
        FROM max_woman_age
    )
ORDER BY
    user_id;

-- Задание 15
--Выведите id и содержимое 100 последних доставленных заказов из таблицы orders.
--Содержимым заказов считаются списки с id входящих в заказ товаров. Результат отсортируйте по возрастанию id заказа.
--Поля в результирующей таблице: order_id, product_ids

WITH delivered_orders AS (
    SELECT order_id
    FROM courier_actions
    WHERE action = 'deliver_order'
    ORDER BY time DESC
    LIMIT 100
)
SELECT
    order_id,
    product_ids
FROM
    orders
WHERE
    order_id IN (
        SELECT order_id
        FROM delivered_orders
    )
ORDER BY
    order_id;

-- Задание 16
--Из таблицы couriers выведите всю информацию о курьерах, которые в сентябре 2022 года доставили 30 и более заказов.
--Результат отсортируйте по возрастанию id курьера.
--Поля в результирующей таблице: courier_id, birth_date, sex

WITH best_couriers AS (
    SELECT
        courier_id,
        count(order_id) AS orders
    FROM
        courier_actions
    WHERE
        date_part('year', time) = 2022
        AND date_part('month', time) = 9
        AND action = 'deliver_order'
    GROUP BY
        courier_id
)
SELECT
    courier_id,
    birth_date,
    sex
FROM
    couriers
WHERE
    courier_id IN (
        SELECT courier_id
        FROM best_couriers
        WHERE orders >= 30
    )
ORDER BY
    courier_id;

-- Задание 17
--Рассчитайте средний размер заказов, отменённых пользователями мужского пола.
--Средний размер заказа округлите до трёх знаков после запятой. Колонку со значением назовите avg_order_size.
--Поле в результирующей таблице: avg_order_size

WITH canceled_orders AS (
    SELECT user_id, order_id
    FROM user_actions
    WHERE action = 'cancel_order'
      AND user_id IN (
        SELECT user_id
        FROM users
        WHERE sex = 'male'
      )
), average_order_size AS (
    SELECT avg(array_length(product_ids, 1)) AS avg_order_size
    FROM orders
    WHERE order_id IN (SELECT order_id FROM canceled_orders)
)
SELECT
    round(avg_order_size, 3) AS avg_order_size
FROM
    average_order_size;

-- Задание 18
--Посчитайте возраст каждого пользователя в таблице users.
--Возраст измерьте числом полных лет, как мы делали в прошлых уроках. Возраст считайте относительно
--последней даты в таблице user_actions.
--Для тех пользователей, у которых в таблице users не указана дата рождения, укажите среднее значение возраста
--всех остальных пользователей, округлённое до целого числа.
--Колонку с возрастом назовите age. В результат включите колонки с id пользователя и возрастом.
--Отсортируйте полученный результат по возрастанию id пользователя.
--Поля в результирующей таблице: user_id, age

WITH max_date AS (
    SELECT max(time)::date AS last_date
    FROM user_actions
), avg_age AS (
    SELECT round(avg(extract(year FROM age(last_date, birth_date)))) AS average_age
    FROM users, max_date
    WHERE birth_date IS NOT NULL
)
SELECT
    u.user_id,
    coalesce(
        extract(year FROM age((SELECT last_date FROM max_date), u.birth_date)),
        (SELECT average_age FROM avg_age)
    )::integer AS age
FROM
    users u
ORDER BY
    u.user_id;

-- Задание 19
--Для каждого заказа, в котором больше 5 товаров, рассчитайте время, затраченное на его доставку.
--В результат включите id заказа, время принятия заказа курьером, время доставки заказа и время,
--затраченное на доставку. Новые колонки назовите соответственно time_accepted, time_delivered и delivery_time.
--В расчётах учитывайте только неотменённые заказы. Время, затраченное на доставку, выразите в минутах,
--округлив значения до целого числа. Результат отсортируйте по возрастанию id заказа.
--Поля в результирующей таблице: order_id, time_accepted, time_delivered и delivery_time

WITH order_times AS (
    SELECT
        order_id,
        min(time) AS time_accepted,
        max(time) AS time_delivered,
        extract(epoch FROM (max(time) - min(time))) / 60 AS delivery_time_raw
    FROM
        courier_actions
    WHERE
        order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
        AND action IN ('accept_order', 'deliver_order')
    GROUP BY
        order_id
    HAVING
        count(order_id) > 1
),
orders_filtered AS (
    SELECT
        order_id,
        product_ids
    FROM
        orders
    WHERE
        array_length(product_ids, 1) > 5
)
SELECT
    of.order_id,
    ot.time_accepted,
    ot.time_delivered,
    round(ot.delivery_time_raw)::integer AS delivery_time
FROM
    orders_filtered of
    JOIN order_times ot ON of.order_id = ot.order_id
ORDER BY
    of.order_id;

-- Задание 20
--Для каждой даты в таблице user_actions посчитайте количество первых заказов, совершённых пользователями.
--Первыми заказами будем считать заказы, которые пользователи сделали в нашем сервисе впервые.
--В расчётах учитывайте только неотменённые заказы.
--В результат включите две колонки: дату и количество первых заказов в эту дату.
--Колонку с датами назовите date, а колонку с первыми заказами — first_orders.
--Результат отсортируйте по возрастанию даты.
--Поля в результирующей таблице: date, first_orders

SELECT
    first_order_date AS date,
    count(user_id) AS first_orders
FROM (
    SELECT
        user_id,
        min(time)::date AS first_order_date
    FROM
        user_actions
    WHERE
        order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
    GROUP BY
        user_id
) t
GROUP BY
    first_order_date
ORDER BY
    date;

-- Задание 21
--Выберите все колонки из таблицы orders и дополнительно в качестве последней колонки укажите функцию unnest,
--применённую к колонке product_ids. Эту последнюю колонку назовите product_id. Больше ничего с данными делать не нужно.
--Выведите только первые 100 записей результирующей таблицы.
--Поля в результирующей таблице: creation_time, order_id, product_ids, product_id

SELECT
    creation_time,
    order_id,
    product_ids,
    unnest(product_ids) AS product_id
FROM
    orders
LIMIT 100;

-- Задание 22
--Определите 10 самых популярных товаров в таблице orders.
--Самыми популярными товарами будем считать те, которые встречались в заказах чаще всего.
--Если товар встречается в одном заказе несколько раз (когда было куплено несколько единиц товара),
-- это тоже учитывается при подсчёте. Учитывайте только неотменённые заказы.
--Выведите id товаров и то, сколько раз они встречались в заказах (то есть сколько раз были куплены).
--Новую колонку с количеством покупок товаров назовите times_purchased.
--Результат отсортируйте по возрастанию id товара.
--Поля в результирующей таблице: product_id, times_purchased

WITH uncanceled_orders AS (
    SELECT
        o.order_id,
        o.product_ids
    FROM
        orders o
    WHERE
        o.order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
), expanded_products AS (
    SELECT
        unnest(product_ids) AS product_id
    FROM
        uncanceled_orders
), q1 AS (
    SELECT
        product_id,
        count(*) AS times_purchased
    FROM
        expanded_products
    GROUP BY
        product_id
    ORDER BY
        times_purchased DESC,
        product_id
    LIMIT 10
)
SELECT
    *
FROM
    q1
ORDER BY
    product_id;

-- Задание 23
--Из таблицы orders выведите id и содержимое заказов, которые включают хотя бы один из пяти самых дорогих товаров,
--доступных в нашем сервисе.
--Результат отсортируйте по возрастанию id заказа.
--Поля в результирующей таблице: order_id, product_ids

WITH expensive_products AS (
    SELECT product_id
    FROM products
    ORDER BY price DESC
    LIMIT 5
)
SELECT
    o.order_id,
    o.product_ids
FROM
    orders o
WHERE
    EXISTS (
        SELECT 1
        FROM unnest(o.product_ids) AS up(product_id)
        WHERE up.product_id IN (
            SELECT product_id
            FROM expensive_products
        )
    )
ORDER BY
    o.order_id;