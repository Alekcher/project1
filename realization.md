# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом вам необходимо выяснить у заказчика детали. Запросите недостающую информацию у заказчика в чате.

Зафиксируйте выясненные требования. Составьте документацию готовящейся витрины на основе заданных вами вопросов, добавив все необходимые детали.

-----------

DoD:
Витрина dm_rfm_segments включает в себя данные по пользователям в RFM классификации, витрина основана на данных с 2021г.

Структура данных:
user_id - уникальный идентификатор клиента. Тип данных - int4
recency - сколько времени прошло с момента последнего заказа (по шкале от 1 до 5). Тип данных - smallint
frequency - количество заказов (по шкале от 1 до 5). Тип данных - smallint
monetary_value - сумма затрат клиента (по шкале от 1 до 5). Тип данных - smallint

Показатели R/F/M строятся на пропорциональном распределении пользователей по шкалам - если в базе всего 100 клиентов, то 20 клиентов должны получить значение 1, ещё 20 — значение 2 и т. д
1 - наименьшее значение в показателе (например пользователь попал в группу с наименьшей суммой трат)
5 - наибольшее значение в показателе (например пользователь попал в группу с наибольшой суммой трат)

Источник данных - схема production

Схема и наименование финальной витрины - analysis.dm_rfm_segments

Глубина данных - с 2021г.

Частота обновления - разовое создание витрины, обновления не требуются.

Доп условия - для простроения витрины выделяем только успешно выполненные заказы (статус "Closed")

## 1.2. Изучите структуру исходных данных.

Полключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------

Схема - production.

Какие таблицы и поля будут использованы:
users (для проверки качества данных):
id

orders:
user_id
order_id
cost
status
order_ts

orderstatuses:
id
key



## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

-----------
production.users: 
поле ID уникально и не может быть null, является PK (CONSTRAINT users_pkey PRIMARY KEY (id))

production.orders:
user_id - не может быть null
order_id - PK (CONSTRAINT orders_pkey PRIMARY KEY (order_id))
cost - является суммой payment и bonus_payment (CONSTRAINT orders_check CHECK ((cost = (payment + bonus_payment))))
status - не может быть null
order_ts - не может быть null

orderstatuses:
id - уникальный ключ
key - не может быть null


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


## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Вас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), вы решаете сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишите SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполните их. Для проверки предоставьте код создания VIEW.

```SQL
--Впишите сюда ваш ответ
CREATE VIEW analysis.products AS SELECT * FROM production.products;
CREATE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE VIEW analysis.orders AS SELECT * FROM production.orders;
CREATE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE VIEW analysis.users AS SELECT * FROM production.users;
```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

Далее вам необходимо создать витрину. Напишите CREATE TABLE запрос и выполните его на предоставленной базе данных в схеме analysis.

```SQL
--Впишите сюда ваш ответ
CREATE TABLE analysis.dm_rfm_segments (
    user_id int4 NOT NULL PRIMARY KEY,
    recency smallint NOT NULL CHECK(recency >= 1 AND recency <= 5),
    frequency smallint NOT NULL CHECK(frequency >= 1 AND frequency <= 5),
    monetary_value smallint NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
    );

```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL
--Впишите сюда ваш ответ
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);


insert into analysis.tmp_rfm_recency
select u.id as user_id,
	   ntile(5) over(order by max(coalesce(o.order_ts, '2020-01-01 00:00:00'::date)))  as recency
from analysis.users u
left join (select t1.*
		   from analysis.orders t1
		   inner join analysis.orderstatuses t2 on t1.status = t2.id and t2.key = 'Closed')	o on u.id = o.user_id
group by 1
;


insert into analysis.tmp_rfm_frequency
select u.id as user_id,
	   ntile(5) over(order by count(order_id))  as frequency
from analysis.users u
left join (select t1.*
		   from analysis.orders t1
		   inner join analysis.orderstatuses t2 on t1.status = t2.id and t2.key = 'Closed')	o on u.id = o.user_id
group by 1
;



insert into analysis.tmp_rfm_monetary_value
select u.id as user_id,
	   ntile(5) over(order by sum(o.cost))  as monetary_value
from analysis.users u
left join (select t1.*
		   from analysis.orders t1
		   inner join analysis.orderstatuses t2 on t1.status = t2.id and t2.key = 'Closed')	o on u.id = o.user_id
group by 1
;

--заполнение витрины
insert into analysis.dm_rfm_segments (    
    user_id,
    recency,
    frequency,
    monetary_value)
select u.id as user_id,
	   r.recency,
	   f.frequency,
	   mv.monetary_value
from analysis.users u 
left join analysis.tmp_rfm_recency r on u.id = r.user_id
left join analysis.tmp_rfm_frequency f on u.id = f.user_id
left join analysis.tmp_rfm_monetary_value mv on u.id = mv.user_id;

```



