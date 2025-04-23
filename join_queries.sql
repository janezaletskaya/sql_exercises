-- Задание 1
--Объедините таблицы user_actions и users по ключу user_id. В результат включите две колонки с user_id из обеих таблиц.
--Эти две колонки назовите соответственно user_id_left и user_id_right.
--Также в результат включите колонки order_id, time, action, sex, birth_date.
--Отсортируйте получившуюся таблицу по возрастанию id пользователя (в любой из двух колонок с id).
--Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

SELECT
    ua.user_id AS user_id_left,
    u.user_id AS user_id_right,
    ua.order_id AS order_id,
    ua.time AS time,
    ua.action AS action,
    u.sex AS sex,
    u.birth_date AS birth_date
FROM user_actions AS ua
JOIN users AS u ON ua.user_id = u.user_id
ORDER BY ua.user_id;

-- Задание 2
--А теперь попробуйте немного переписать запрос из прошлого задания и посчитать количество уникальных id в объединённой
--таблице. То есть снова объедините таблицы, но в этот раз просто посчитайте уникальные user_id в одной из колонок с id.
--Выведите это количество в качестве результата. Колонку с посчитанным значением назовите users_count.
--Поле в результирующей таблице: users_count

SELECT COUNT(DISTINCT user_id_left) AS users_count
FROM (
    SELECT
        ua.user_id AS user_id_left,
        u.user_id AS user_id_right,
        ua.order_id AS order_id,
        ua.time AS time,
        ua.action AS action,
        u.sex AS sex,
        u.birth_date AS birth_date
    FROM user_actions AS ua
    JOIN users AS u ON ua.user_id = u.user_id
) t1;

-- Задание 3
--С помощью LEFT JOIN объедините таблицы user_actions и users по ключу user_id. Обратите внимание на порядок таблиц —
--слева users_actions, справа users. В результат включите две колонки с user_id из обеих таблиц.
--Эти две колонки назовите соответственно user_id_left и user_id_right.
--Также в результат включите колонки order_id, time, action, sex, birth_date.
--Отсортируйте получившуюся таблицу по возрастанию id пользователя (в колонке из левой таблицы).
--Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

SELECT
    ua.user_id AS user_id_left,
    u.user_id AS user_id_right,
    ua.order_id AS order_id,
    ua.time AS time,
    ua.action AS action,
    u.sex AS sex,
    u.birth_date AS birth_date
FROM user_actions AS ua
LEFT JOIN users AS u ON ua.user_id = u.user_id
ORDER BY ua.user_id;

-- Задание 4
--Теперь снова попробуйте немного переписать запрос из прошлого задания и посчитайте количество уникальных id
--в колонке user_id, пришедшей из левой таблицы user_actions. Выведите это количество в качестве результата.
--Колонку с посчитанным значением назовите users_count.
--Поле в результирующей таблице: users_count

SELECT COUNT(DISTINCT a.user_id) AS users_count
FROM user_actions AS a
LEFT JOIN users AS b USING (user_id);

-- Задание 5
--Возьмите запрос из задания 3, где вы объединяли таблицы user_actions и users с помощью LEFT JOIN,
--добавьте к запросу оператор WHERE и исключите NULL значения в колонке user_id из правой таблицы.
--Включите в результат все те же колонки и отсортируйте получившуюся таблицу по возрастанию id пользователя
--в колонке из левой таблицы.
--Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

SELECT
    a.user_id AS user_id_left,
    b.user_id AS user_id_right,
    order_id,
    time,
    action,
    sex,
    birth_date
FROM user_actions AS a
LEFT JOIN users AS b USING (user_id)
WHERE b.user_id IS NOT NULL
ORDER BY user_id_left;

-- Задание 6
--С помощью FULL JOIN объедините по ключу birth_date таблицы, полученные в результате вышеуказанных запросов
--В результат включите две колонки с birth_date из обеих таблиц.
--Эти две колонки назовите соответственно users_birth_date и couriers_birth_date.
--Также включите в результат колонки с числом пользователей и курьеров — users_count и couriers_count.
--Отсортируйте получившуюся таблицу сначала по колонке users_birth_date по возрастанию,
--затем по колонке couriers_birth_date — тоже по возрастанию.
--Поля в результирующей таблице: users_birth_date, users_count,  couriers_birth_date, couriers_count

WITH users_birth_dates AS (
    SELECT
        birth_date,
        COUNT(user_id) AS users_count
    FROM users
    WHERE birth_date IS NOT NULL
    GROUP BY birth_date
),
couriers_birth_dates AS (
    SELECT
        birth_date,
        COUNT(courier_id) AS couriers_count
    FROM couriers
    WHERE birth_date IS NOT NULL
    GROUP BY birth_date
)
SELECT
    ubt.birth_date AS users_birth_date,
    ubt.users_count AS users_count,
    cbt.birth_date AS couriers_birth_date,
    cbt.couriers_count AS couriers_count
FROM users_birth_dates AS ubt
FULL JOIN couriers_birth_dates AS cbt ON ubt.birth_date = cbt.birth_date
ORDER BY users_birth_date, couriers_birth_date;

-- Задание 7
--Объедините два следующих запроса друг с другом так, чтобы на выходе получился набор уникальных дат
--из таблиц users и couriers:
--SELECT birth_date
--FROM users
--WHERE birth_date IS NOT NULL
--
--SELECT birth_date
--FROM couriers
--WHERE birth_date IS NOT NULL

--Поместите в подзапрос полученный после объединения набор дат и посчитайте их количество.
--Колонку с числом дат назовите dates_count.
--Поле в результирующей таблице: dates_count

SELECT count(birth_date) as dates_count
FROM   (SELECT birth_date
        FROM   users
        WHERE  birth_date is not null
        UNION
SELECT birth_date
        FROM   couriers
        WHERE  birth_date is not null) t1;

-- Задание 8
--Из таблицы users отберите id первых 100 пользователей и с помощью CROSS JOIN объедините их со всеми наименованиями
--товаров из таблицы products. Выведите две колонки — id пользователя и наименование товара.
--Результат отсортируйте сначала по возрастанию id пользователя, затем по имени товара — тоже по возрастанию.
--Поля в результирующей таблице: user_id, name

with first_users as (SELECT user_id
                     FROM   users limit 100)
SELECT fu.user_id as user_id,
       pr.name as name
FROM   first_users as fu cross join products as pr
ORDER BY user_id, name;

-- Задание 9
--Для начала объедините таблицы user_actions и orders — это вы уже умеете делать.
--В качестве ключа используйте поле order_id. Выведите id пользователей и заказов, а также список товаров в заказе.
--Отсортируйте таблицу по id пользователя по возрастанию, затем по id заказа — тоже по возрастанию.
--Выведите только первые 1000 строк результирующей таблицы.
--Поля в результирующей таблице: user_id, order_id, product_ids

SELECT ua.user_id as user_id,
       ua.order_id as order_id,
       o.product_ids as product_ids
FROM   user_actions as ua
    LEFT JOIN orders as o
        ON ua.order_id = o.order_id
ORDER BY user_id, order_id limit 1000;

-- Задание 10
--Снова объедините таблицы user_actions и orders, но теперь оставьте только уникальные неотменённые заказы.
--Остальные условия задачи те же: вывести id пользователей и заказов, а также список товаров в заказе.
--Отсортируйте таблицу по id пользователя по возрастанию, затем по id заказа — тоже по возрастанию.
--Выведите только первые 1000 строк результирующей таблицы.
--Поля в результирующей таблице: user_id, order_id, product_ids

SELECT ua.user_id as user_id,
       ua.order_id as order_id,
       o.product_ids as product_ids
FROM   (SELECT user_id,
               order_id
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) as ua
    LEFT JOIN orders as o
        ON ua.order_id = o.order_id
ORDER BY user_id, order_id limit 1000;

-- Задание 11
--Используя запрос из предыдущего задания, посчитайте, сколько в среднем товаров заказывает каждый пользователь.
--Выведите id пользователя и среднее количество товаров в заказе. Среднее значение округлите до двух знаков после запятой.
--Колонку посчитанными значениями назовите avg_order_size.
--Результат выполнения запроса отсортируйте по возрастанию id пользователя.
--Выведите только первые 1000 строк результирующей таблицы.
--Поля в результирующей таблице: user_id, avg_order_size

with valid_orders as (SELECT ua.user_id,
                             ua.order_id,
                             o.product_ids
                      FROM   user_actions ua join orders o
                              ON ua.order_id = o.order_id
                      WHERE  ua.order_id not in (SELECT order_id
                                                 FROM   user_actions
                                                 WHERE  action = 'cancel_order')
                         and ua.action = 'create_order')
SELECT user_id,
       round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM   valid_orders
GROUP BY user_id
ORDER BY user_id limit 1000;

-- Задание 12
--Для начала к таблице с заказами (orders) примените функцию unnest, как мы делали в прошлом уроке.
--Колонку с id товаров назовите product_id. Затем к образовавшейся расширенной таблице по ключу product_id
--добавьте информацию о ценах на товары (из таблицы products). Должна получиться таблица с заказами,
--товарами внутри каждого заказа и ценами на эти товары. Выведите колонки с id заказа, id товара и ценой товара.
--Результат отсортируйте сначала по возрастанию id заказа, затем по возрастанию id товара.
--Выведите только первые 1000 строк результирующей таблицы.
--Поля в результирующей таблице: order_id, product_id, price

with q1 as (SELECT creation_time,
                   order_id,
                   product_ids,
                   unnest(product_ids) as product_id
            FROM   orders)
SELECT q.order_id as order_id,
       q.product_id as product_id,
       p.price as price
FROM   (SELECT *
        FROM   q1) as q
    LEFT JOIN products as p
        ON q.product_id = p.product_id
ORDER BY order_id, product_id limit 1000;

-- Задание 13
--Используя запрос из предыдущего задания, рассчитайте суммарную стоимость каждого заказа.
--Выведите колонки с id заказов и их стоимостью. Колонку со стоимостью заказа назовите order_price.
--Результат отсортируйте по возрастанию id заказа.
--Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
--Поля в результирующей таблице: order_id, order_price

with q1 as (SELECT creation_time,
                   order_id,
                   product_ids,
                   unnest(product_ids) as product_id
            FROM   orders), q2 as (SELECT q.order_id as order_id,
                              q.product_id as product_id,
                              p.price as price
                       FROM   q1 as q
                           LEFT JOIN products as p
                               ON q.product_id = p.product_id
                       ORDER BY order_id, product_id)
SELECT order_id,
       sum(price) as order_price
FROM   q2
GROUP BY order_id
ORDER BY order_id limit 1000;

-- Задание 14
--Рассчитайте следующие показатели:
--общее число заказов — колонку назовите orders_count
--среднее количество товаров в заказе — avg_order_size
--суммарную стоимость всех покупок — sum_order_value
--среднюю стоимость заказа — avg_order_value
--минимальную стоимость заказа — min_order_value
--максимальную стоимость заказа — max_order_value
--Полученный результат отсортируйте по возрастанию id пользователя.
--
--Выведите только первые 1000 строк результирующей таблицы.
--Помните, что в расчётах мы по-прежнему учитываем только неотменённые заказы.
-- При расчёте средних значений, округляйте их до двух знаков после запятой.
--Поля в результирующей таблице:
--user_id, orders_count, avg_order_size, sum_order_value, avg_order_value, min_order_value, max_order_value


with valid_orders as (
    SELECT ua.user_id,
           ua.order_id
    FROM   user_actions ua
    WHERE  ua.action = 'create_order'
           AND ua.order_id NOT IN (
               SELECT order_id
               FROM   user_actions
               WHERE  action = 'cancel_order'
           )
), order_details as (
    SELECT vo.user_id,
           vo.order_id,
           count(p.product_id) AS product_count,
           sum(p.price) AS order_value
    FROM   valid_orders vo
           JOIN orders o ON vo.order_id = o.order_id
           CROSS JOIN LATERAL unnest(o.product_ids) AS up(product_id)
           JOIN products p ON up.product_id = p.product_id
    GROUP BY vo.user_id,
             vo.order_id
)
SELECT user_id,
       count(order_id) as orders_count,
       round(avg(product_count), 2) as avg_order_size,
       sum(order_value) as sum_order_value,
       round(avg(order_value), 2) as avg_order_value,
       min(order_value) as min_order_value,
       max(order_value) as max_order_value
FROM   order_details
GROUP BY user_id
ORDER BY user_id limit 1000;

-- Задание 15
--По данным таблиц orders, products и user_actions посчитайте ежедневную выручку сервиса.
--Под выручкой будем понимать стоимость всех реализованных товаров, содержащихся в заказах.
--Колонку с датой назовите date, а колонку со значением выручки — revenue.
--В расчётах учитывайте только неотменённые заказы.
--Результат отсортируйте по возрастанию даты.
--Поля в результирующей таблице: date, revenue

WITH uncanceled_orders AS (
    SELECT order_id
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order'
    )
),
without_price AS (
    SELECT
        order_id,
        creation_time,
        product_ids,
        unnest(product_ids) AS product_id
    FROM orders
    WHERE order_id IN (
        SELECT order_id
        FROM uncanceled_orders
    )
),
q1 AS (
    SELECT
        wp.order_id AS order_id,
        DATE(wp.creation_time) AS date,
        wp.product_ids AS product_ids,
        wp.product_id AS product_id,
        p.price AS price
    FROM without_price AS wp
    LEFT JOIN products AS p
           ON wp.product_id = p.product_id
)
SELECT
    date,
    SUM(price)::decimal AS revenue
FROM q1
GROUP BY date
ORDER BY date;

-- Задание 16
--По таблицам courier_actions , orders и products определите 10 самых популярных товаров,
--доставленных в сентябре 2022 года.
--Самыми популярными товарами будем считать те, которые встречались в заказах чаще всего.
--Если товар встречается в одном заказе несколько раз (было куплено несколько единиц товара), то при подсчёте учитываем
--только одну единицу товара.
--Выведите наименования товаров и сколько раз они встречались в заказах.
--Новую колонку с количеством покупок товара назовите times_purchased.
--Поля в результирующей таблице: name, times_purchased

WITH delivered_in_september AS (
    SELECT
        o.order_id,
        unnest(o.product_ids) AS product_id
    FROM orders o
    JOIN courier_actions ca
         ON o.order_id = ca.order_id
    WHERE ca.action = 'deliver_order'
      AND EXTRACT(YEAR FROM ca.time) = 2022
      AND EXTRACT(MONTH FROM ca.time) = 9
),
product_counts AS (
    SELECT
        product_id,
        COUNT(DISTINCT order_id) AS times_purchased
    FROM delivered_in_september
    GROUP BY product_id
    ORDER BY times_purchased DESC
    LIMIT 10
)
SELECT
    p.name,
    pc.times_purchased
FROM product_counts pc
JOIN products p
     ON pc.product_id = p.product_id
ORDER BY pc.times_purchased DESC, p.name;

-- Задание 17
--Возьмите запрос, составленный на одном из прошлых уроков, и подтяните в него из таблицы users данные о
--поле пользователей таким образом, чтобы все пользователи из таблицы user_actions остались в результате.
--Затем посчитайте среднее значение cancel_rate для каждого пола, округлив его до трёх знаков после запятой.
--Колонку с посчитанным средним значением назовите avg_cancel_rate.
--Результат отсортируйте по колонке с полом пользователя по возрастанию.
--Поля в результирующей таблице: sex, avg_cancel_rate

WITH q1 AS (
    SELECT
        user_id,
        ROUND(
            COUNT(DISTINCT order_id) FILTER (WHERE action = 'cancel_order')::decimal
            / COUNT(DISTINCT order_id),
            2
        ) AS cancel_rate,
        COUNT(DISTINCT order_id) AS orders_count
    FROM user_actions
    GROUP BY user_id
    ORDER BY user_id
),
q2 AS (
    SELECT
        q.user_id AS user_id,
        q.cancel_rate AS cancel_rate,
        u.sex AS sex
    FROM q1 AS q
    LEFT JOIN users AS u
           ON q.user_id = u.user_id
)
SELECT
    COALESCE(sex, 'unknown') AS sex,
    ROUND(AVG(cancel_rate), 3) AS avg_cancel_rate
FROM q2
GROUP BY sex
ORDER BY sex;

-- Задание 18
--По таблицам orders и courier_actions определите id десяти заказов, которые доставляли дольше всего.
--Поле в результирующей таблице: order_id

WITH q1 AS (
    SELECT
        ca.order_id AS order_id,
        ca.time AS delivered_time,
        ua.time AS created_time,
        ca.time - ua.time AS time_diff
    FROM courier_actions AS ca
    LEFT JOIN user_actions AS ua
           ON ca.order_id = ua.order_id
    WHERE ca.action = 'deliver_order'
)
SELECT order_id
FROM q1
ORDER BY time_diff DESC
LIMIT 10;

-- Задание 19
--Произведите замену списков с id товаров из таблицы orders на списки с наименованиями товаров.
--Наименования возьмите из таблицы products. Колонку с новыми списками наименований назовите product_names.
--Выведите только первые 1000 строк результирующей таблицы.
--Поля в результирующей таблице: order_id, product_names

WITH q1 AS (
    SELECT order_id,
           unnest(product_ids) AS product_id
    FROM orders
),
q2 AS (
    SELECT q.order_id,
           p.name
    FROM q1 AS q
    LEFT JOIN products AS p
           ON q.product_id = p.product_id
)
SELECT order_id,
       array_agg(name) AS product_names
FROM q2
GROUP BY order_id
ORDER BY order_id
LIMIT 1000;

--Выясните, кто заказывал и доставлял самые большие заказы. Самыми большими считайте заказы с наибольшим числом товаров.
--Выведите id заказа, id пользователя и id курьера. Также в отдельных колонках укажите возраст пользователя
--и возраст курьера. Возраст измерьте числом полных лет, как мы делали в прошлых уроках.
--Считайте его относительно последней даты в таблице user_actions — как для пользователей, так и для курьеров.
--Колонки с возрастом назовите user_age и courier_age. Результат отсортируйте по возрастанию id заказа.
--Поля в результирующей таблице: order_id, user_id, user_age, courier_id, courier_age

WITH max_date AS (
         SELECT MAX(time)::date
         FROM user_actions
     ),
     max_length AS (
         SELECT MAX(array_length(product_ids, 1)) AS max_len
         FROM orders
     ),
     q1 AS (
         SELECT o.order_id,
                o.product_ids
         FROM orders o,
              max_length ml
         WHERE array_length(o.product_ids, 1) = ml.max_len
     )
SELECT DISTINCT
       q.order_id AS order_id,
       ua.user_id AS user_id,
       DATE_PART('year', AGE((SELECT * FROM max_date), u.birth_date))::integer AS user_age,
       ca.courier_id AS courier_id,
       DATE_PART('year', AGE((SELECT * FROM max_date), c.birth_date))::integer AS courier_age
FROM q1 AS q
LEFT JOIN user_actions AS ua
       ON q.order_id = ua.order_id
LEFT JOIN users AS u
       ON ua.user_id = u.user_id
LEFT JOIN courier_actions AS ca
       ON q.order_id = ca.order_id
LEFT JOIN couriers AS c
       ON c.courier_id = ca.courier_id;


-- Задание 21
-- Выясните, какие пары товаров покупают вместе чаще всего.
-- Пары товаров сформируйте на основе таблицы с заказами. Отменённые заказы не учитывайте.
-- В качестве результата выведите две колонки — колонку с парами наименований товаров и колонку со значениями,
-- показывающими, сколько раз конкретная пара встретилась в заказах пользователей.
-- Колонки назовите соответственно pair и count_pair.
-- Пары товаров должны быть представлены в виде списков из двух наименований.
-- Пары товаров внутри списков должны быть отсортированы в порядке возрастания наименования.
-- Результат отсортируйте сначала по убыванию частоты встречаемости пары товаров в заказах, затем по колонке pair — по возрастанию.
-- Поля в результирующей таблице: pair, count_pair

with
    cross_table as (
        SELECT
            t1.product_id as id1,
            t1.name as name1,
            t2.product_id as id2,
            t2.name as name2
        FROM products as t1
        cross join products as t2
        WHERE t1.product_id > t2.product_id
    ),
    completed_order_ids as (
        SELECT order_id
        FROM user_actions
        WHERE order_id not in (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
    ),
    completed_orders as (
        SELECT o.order_id,
               product_ids
        FROM orders as o
        join completed_order_ids as ids
            ON ids.order_id = o.order_id
    ),
    t1 as (
        SELECT
            o.order_id,
            case
                when q2.name1 < q2.name2 then array [q2.name1, q2.name2]
                else array [q2.name2, q2.name1]
            end as pair
        FROM completed_orders as o
        join cross_table as q2
            ON q2.id1 = any(o.product_ids)
            and q2.id2 = any(o.product_ids)
    )
SELECT pair,
       count(order_id) as count_pair
FROM t1
GROUP BY pair
ORDER BY count_pair desc, pair;