# 1.3. Качество данных

## Оцените, насколько качественные данные хранятся в источнике.
Опишите, как вы проверяли исходные данные и какие выводы сделали.

Для проверки используются только те таблицы, котоыре принимают участие в формировании витрины.

Проверка на пропуски/дубли:
production.users:
select count(id), 
       count(distinct id), 
       count(*) 
from users;

Дублей нет, пропущенных значений нет.

production.orders:
select 
       count(*) as cnt_all,
       count(distinct order_id) as cnt_unique_order_ids,
       count(order_id) as cnt_order_ids_for_null,
       count(user_id) as cnt_user_ids_for_null,
       sum(case when cost < 0 then 1 else 0 end) as check_cost_for_minus, --проверяем на отрицательные значения в cost
       count(cost) as check_cost_for_null,
       count(status) as check_status_for_null,
       count(order_ts) as check_order_ts_for_null
from orders o
left join users u on o.user_id = u.id 
left join orderstatuses os on os.id  = o.status;

Проверка показала, что:
order_id - значения уникальны и не повторяются
user_id - пропусков нет
cost - нет отрицательных значений в поле cost, нет пропусков
status - нет пропусков
order_ts - нет пропусков

orderstatuses:
select * 
from orderstatuses;

Достаточно ручной проверки для таблицы с 5 строками - все заполнены, дублей нет.


Типы данных используемые для связки таблиц везде int4:
users.id - int4
orders.user_id - int4
orders.status - int4
orderstatuses.id - int4


Проверка на глубину данных:
select min(order_ts), max(order_ts)
from production.orders;


Минимальная дата заказа в таблице - 2022-02-12
Максимальная - 2022-03-14

## Укажите, какие инструменты обеспечивают качество данных в источнике.
Ответ запишите в формате таблицы со следующими столбцами:
- `Наименование таблицы` - наименование таблицы, объект которой рассматриваете.
- `Объект` - Здесь укажите название объекта в таблице, на который применён инструмент. Например, здесь стоит перечислить поля таблицы, индексы и т.д.
- `Инструмент` - тип инструмента: первичный ключ, ограничение или что-то ещё.
- `Для чего используется` - здесь в свободной форме опишите, что инструмент делает.

Пример ответа:

| Таблицы             | Объект                      | Инструмент      | Для чего используется |
| ------------------- | --------------------------- | --------------- | --------------------- |
| production.Products | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.Products | name varchar(2048) NOT NULL | Ограничение     | Обеспечивает заполненность поля |
| production.Products | price numeric(19, 5) NOT NULL DEFAULT 0 | Ограничение     | Обеспечивает заполненность поля, при отсутствии значения по умолчанию ставится 0|
|production.OrderItems| id int4NOT NULL GENERATED ALWAYS AS IDENTITY CONSTRAINT orderitems_pkey PRIMARY KEY (id)| Первичный ключ| Обеспечивает уникальность записей, автозаполнение|
|production.OrderItems| product_id int4 NOT NULL CONSTRAINT orderitems_order_id_product_id_key UNIQUE (order_id, product_id)| Ограничение     | Обеспечивает заполненность и уникальность данных|
|production.OrderItems| order_id int4 NOT NULL CONSTRAINT orderitems_order_id_product_id_key UNIQUE (order_id, product_id)| Ограничение     | Обеспечивает заполненность и уникальность данных|
|production.OrderItems| name int4 NOT NULL | Ограничение     | Обеспечивает заполненность данных|
|production.OrderItems| price numeric(19, 5) NOT NULL DEFAULT 0 CONSTRAINT orderitems_price_check CHECK ((price >= (0)::numeric))| Ограничение     | Обеспечивает заполненность данных и ставится ограничение на минимальное значение в поле|
|production.OrderItems| discount numeric(19, 5) NOT NULL DEFAULT 0 | Ограничение     | Обеспечивает заполненность данных|
|production.OrderItems| quantity int4 NOT NULL CONSTRAINT orderitems_quantity_check CHECK ((quantity > 0)| Ограничение     | Обеспечивает заполненность данных, ограничение на минимальное значение|
|production.orders| order_id int4 NOT NULL CONSTRAINT orders_pkey PRIMARY KEY (order_id)| Первичный ключ     | Обеспечивает уникальность записей|
|production.orders| order_ts timestamp NOT NULL| Ограничение| Обеспечивает заполненность данных|
|production.orders| user_id int4 NOT NULL| Ограничение| Обеспечивает заполненность данных| 
|production.orders| bonus_payment numeric(19, 5) NOT NULL DEFAULT 0| Ограничение| Обеспечивает заполненность данных, при отсутствии значения ставит 0|                 
|production.orders| payment numeric(19, 5) NOT NULL DEFAULT 0| Ограничение| Обеспечивает заполненность данных, при отсутствии значения ставит 0|
|production.orders| "cost" numeric(19, 5) NOT NULL DEFAULT 0 CONSTRAINT orders_check CHECK ((cost = (payment + bonus_payment)))| Ограничение| Обеспечивает заполненность данных, при отсутствии значения ставит 0, значение в поле должно быть равно payment + bonus_payment|
|production.orders| bonus_grant numeric(19, 5) NOT NULL DEFAULT 0| Ограничение| Обеспечивает заполненность данных, при отсутствии значения ставит 0|
|production.orders| status int4 NOT NULL| Ограничение| Обеспечивает заполненность данных|
|production.orderstatuslog| id int4 NOT NULL GENERATED ALWAYS AS IDENTITY CONSTRAINT orderstatuslog_pkey PRIMARY KEY (id)| Первичный ключ| Обеспечивает заполненность данных, уникальность данных, автозаполнение|
|production.orderstatuslog| order_id int4 NOT NULL CONSTRAINT orderstatuslog_order_id_status_id_key UNIQUE (order_id, status_id)| Ограничение| Обеспечивает заполненность данных, уникальность данных|
|production.orderstatuslog| status_id int4 NOT NULL CONSTRAINT orderstatuslog_order_id_status_id_key UNIQUE (order_id, status_id)| Ограничение| Обеспечивает заполненность данных, уникальность данных|
|production.orderstatuslog| dttm timestamp NOT NULL| Ограничение| Обеспечивает заполненность данных|
|production.orderstatuses| id int4 NOT NULL CONSTRAINT orderstatuses_pkey PRIMARY KEY (id)| Первичный ключ| Обеспечивает заполненность данных, уникальность данных|
|production.orderstatuses| "key" varchar(255) NOT NULL| Ограничение| Обеспечивает заполненность данных|
|production.users| id int4 NOT NULL CONSTRAINT users_pkey PRIMARY KEY (id)| Первичный ключ  | Обеспечивает уникальность записей о пользователях |
|production.users| "name" varchar(2048) NULL| Ограничение| Обеспечивает заполненность данных|
|production.users| login varchar(2048) NOT NULL| Ограничение| Обеспечивает заполненность данных|
