# 📊 Схема базы данных

Ниже представлена структура базы данных, используемой для анализа заказов, пользователей и курьеров.

## Таблицы

### 🧑‍💻 users

| Поле       | Тип       | Описание                     |
|------------|-----------|------------------------------|
| user_id    | INT  | Уникальный ID пользователя   |
| sex        | VARCHAR(50)     | Пол                          |
| birth_date | DATE      | Дата рождения                |

---

### 📦 products

| Поле      | Тип         | Описание                   |
|-----------|-------------|----------------------------|
| product_id| INT         | Уникальный ID товара       |
| price     | FLOAT(4)    | Цена                       |
| name      | VARCHAR(50) | Название товара            |

---

### 🚚 couriers

| Поле       | Тип   | Описание                   |
|------------|-------|----------------------------|
| courier_id | INT   | Уникальный ID курьера      |
| sex        | VARCHAR(50)  | Пол                        |
| birth_date | DATE  | Дата рождения              |

---

### 📝 user_actions

| Поле     | Тип   | Описание                              |
|----------|-------|-----------------------------------------|
| user_id  | INT   | ID пользователя                        |
| action   | VARCHAR(50)  | Действие (create_order, cancel_order…) |
| order_id | INT | ID заказа                              |
| time     | TIMESTAMP | Время действия                         |

---

### 📬 courier_actions

| Поле       | Тип | Описание                              |
|------------|-----|-----------------------------------------|
| courier_id | INT | ID курьера                             |
| action     | VARCHAR(50) | Действие (accept_order, deliver_order…)|
| order_id   | INT | ID заказа                              |
| time       | TIMESTAMP | Время действия                         |

---

### 🧾 orders

| Поле         | Тип   | Описание                             |
|--------------|-------|----------------------------------------|
| order_id     | INT   | ID заказа                             |
| product_ids  | INT[] | Массив ID товаров                     |
| creation_time| TIMESTAMP | Дата и время создания заказа          |

---

## 🔗 Связи между таблицами

- `users.user_id` → `user_actions.user_id`
- `couriers.courier_id` → `courier_actions.courier_id`
- `orders.order_id` → `user_actions.order_id`, `courier_actions.order_id`
- `orders.product_ids` → `products.product_id` (через unnest)