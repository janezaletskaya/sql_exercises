-- Задание 1
--Выведите id всех уникальных пользователей из таблицы user_actions. Результат отсортируйте по возрастанию id.
--Поле в результирующей таблице: user_id

SELECT DISTINCT user_id
FROM   user_actions
ORDER BY user_id

-- Задание 2
--Примените DISTINCT сразу к двум колонкам таблицы courier_actions и отберите уникальные
--пары значений courier_id и order_id.
--Результат отсортируйте сначала по возрастанию id курьера, затем по возрастанию id заказа.
--Поля в результирующей таблице: courier_id, order_id

SELECT DISTINCT courier_id,
                order_id
FROM   courier_actions
ORDER BY courier_id, order_id

-- Zадание 3
--Посчитайте максимальную и минимальную цены товаров в таблице products.
--Поля назовите соответственно max_price, min_price.
--Поля в результирующей таблице: max_price, min_price

SELECT max(price) as max_price,
       min(price) as min_price
FROM   products

-- Задание 4
--Как вы помните, в таблице users у некоторых пользователей не были указаны их даты рождения.
--Посчитайте в одном запросе количество всех записей в таблице и количество только тех записей,
--для которых в колонке birth_date указана дата рождения.
--Колонку с общим числом записей назовите dates, а колонку с записями без пропусков — dates_not_null.
--Поля в результирующей таблице: dates, dates_not_null

SELECT count(*) as dates,
       count(birth_date) as dates_not_null
FROM   users

-- Задание 5
--Посчитайте количество всех значений в колонке user_id в таблице user_actions, а также количество
--уникальных значений в этой колонке (т.е. количество уникальных пользователей сервиса).
--Колонку с первым полученным значением назовите users, а колонку со вторым — unique_users.
--Поля в результирующей таблице: users, unique_users

SELECT count(user_id) as users,
       count(distinct user_id) as unique_users
FROM   user_actions

-- Задание 6
--Посчитайте количество курьеров женского пола в таблице couriers.
--Полученный столбец с одним значением назовите couriers.
--Поле в результирующей таблице: couriers

SELECT count(distinct courier_id) as couriers
FROM   couriers
WHERE  sex = 'female'

-- Задание 7
--Рассчитайте время, когда были совершены первая и последняя доставки заказов в таблице courier_actions.
--Колонку с временем первой доставки назовите first_delivery, а колонку с временем последней — last_delivery.
--Поля в результирующей таблице: first_delivery, last_delivery

SELECT min(time) as first_delivery,
       max(time) as last_delivery
FROM   courier_actions
WHERE  action = 'deliver_order'

-- Задание 8
--Представьте, что один из пользователей сервиса сделал заказ, в который вошли одна пачка сухариков,
--одна пачка чипсов и один энергетический напиток. Посчитайте стоимость такого заказа.
--Колонку с рассчитанной стоимостью заказа назовите order_price.
--Для расчётов используйте таблицу products.
--Поле в результирующей таблице: order_price

SELECT sum(price) as order_price
FROM   products
WHERE  name in ('сухарики', 'чипсы', 'энергетический напиток')

-- Задание 9
--Посчитайте количество заказов в таблице orders с девятью и более товарами.
--Поле в результирующей таблице: orders

SELECT count(order_id) as orders
FROM   orders
WHERE  array_length(product_ids, 1) >= 9

-- Задание 10
--Рассчитайте возраст самого молодого курьера мужского пола в таблице couriers.
--Возраст выразите количеством лет, месяцев и дней (как в примере выше), переведя его в тип VARCHAR.
--В качестве даты, относительно которой считать возраст курьеров, используйте свою текущую дату.
--Полученную колонку со значением возраста назовите min_age.
--Поле в результирующей таблице: min_age

SELECT age(max(birth_date))::varchar as min_age
FROM   couriers
WHERE  sex = 'male'

-- Задание 11
--Посчитайте стоимость заказа, в котором будут три пачки сухариков, две пачки чипсов и один энергетический напиток.
--Колонку с рассчитанной стоимостью заказа назовите order_price.
--Для расчётов используйте таблицу products.
--Поле в результирующей таблице: order_price

SELECT sum(case when name = 'сухарики' then price * 3
                when name = 'чипсы' then price * 2
                when name = 'энергетический напиток' then price
                else 0 end) as order_price
FROM   products

-- Задание 12
--Рассчитайте среднюю цену товаров в таблице products, в названиях которых присутствуют слова «чай» или «кофе».
--Любым известным способом исключите из расчёта товары, содержащие в названии «иван-чай» или «чайный гриб».
--Среднюю цену округлите до двух знаков после запятой. Столбец с полученным значением назовите avg_price.
--Поле в результирующей таблице: avg_price

SELECT round(avg(price), 2) as avg_price
FROM   products
WHERE  name like 'чай %'
    or name like 'кофе %'

-- Задание 13
--Воспользуйтесь функцией AGE и рассчитайте разницу в возрасте между самым старым и самым молодым
--пользователями мужского пола в таблице users.
--Разницу в возрасте выразите количеством лет, месяцев и дней, переведя её в тип VARCHAR.
--Колонку с посчитанным значением назовите age_diff.
--Поле в результирующей таблице: age_diff

SELECT (age(max(birth_date), min(birth_date))) :: varchar as age_diff
FROM   users
WHERE  sex = 'male'

-- Задание 14
--Рассчитайте среднее количество товаров в заказах из таблицы orders,
--которые пользователи оформляли по выходным дням (суббота и воскресенье) в течение всего времени работы сервиса.
--Полученное значение округлите до двух знаков после запятой. Колонку с ним назовите avg_order_size.
--Поле в результирующей таблице: avg_order_size

SELECT round(avg(array_length(product_ids, 1)), 2) as avg_order_size
FROM   orders
WHERE  date_part('dow', creation_time) in (0, 6)

-- Задание 15
--На основе данных в таблице user_actions посчитайте количество уникальных пользователей сервиса, количество
--уникальных заказов, поделите одно на другое и выясните, сколько заказов приходится на одного пользователя.
--В результирующей таблице отразите все три значения — поля назовите соответственно
--unique_users, unique_orders, orders_per_user.
--Показатель числа заказов на пользователя округлите до двух знаков после запятой.
--Поля в результирующей таблице: unique_users, unique_orders, orders_per_user

SELECT count(distinct user_id) as unique_users,
       count(distinct order_id) as unique_orders,
       round(count(distinct order_id)::decimal / count(distinct user_id),
             2) as orders_per_user
FROM   user_actions

-- Задание 16
--Посчитайте, сколько пользователей никогда не отменяли свой заказ.
--Полученный столбец назовите users_count.
--Поле в результирующей таблице: users_count

SELECT count(distinct user_id) - count(distinct user_id) filter (WHERE action = 'cancel_order') as users_count
FROM   user_actions

-- Задание 17
--Посчитайте общее количество заказов в таблице orders, количество заказов с пятью и более товарами
--и найдите долю заказов с пятью и более товарами в общем количестве заказов.
--В результирующей таблице отразите все три значения — поля назовите соответственно
--orders, large_orders, large_orders_share.
--Долю заказов с пятью и более товарами в общем количестве товаров округлите до двух знаков после запятой.
--Поля в результирующей таблице: orders, large_orders, large_orders_share

SELECT count(distinct order_id) as orders,
       count(distinct(order_id)) filter (WHERE array_length(product_ids, 1) >= 5) as large_orders,
       round(count(distinct(order_id)) filter (WHERE array_length(product_ids, 1) >= 5)::decimal / count(distinct order_id),
             2) as large_orders_share
FROM   orders
