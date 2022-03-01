# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД

```sql
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```
- подключения к БД

```sql
postgres=# \c test_database
Password:
You are now connected to database "test_database" as user "postgres".
```
- вывода списка таблиц

```sql
postgres=# \dS
                        List of relations
   Schema   |              Name               | Type  |  Owner
------------+---------------------------------+-------+----------
 pg_catalog | pg_aggregate                    | table | postgres
 pg_catalog | pg_am                           | table | postgres
 pg_catalog | pg_amop                         | table | postgres
 ...
 ```
- вывода описания содержимого таблиц

```sql
postgres=# \dS pg_database
               Table "pg_catalog.pg_database"
    Column     |   Type    | Collation | Nullable | Default
---------------+-----------+-----------+----------+---------
 oid           | oid       |           | not null |
 datname       | name      |           | not null |
 datdba        | oid       |           | not null |
 encoding      | integer   |           | not null |
 datcollate    | name      |           | not null |
 datctype      | name      |           | not null |
 datistemplate | boolean   |           | not null |
 datallowconn  | boolean   |           | not null |
 datconnlimit  | integer   |           | not null |
 datlastsysoid | oid       |           | not null |
 datfrozenxid  | xid       |           | not null |
 datminmxid    | xid       |           | not null |
 dattablespace | oid       |           | not null |
 datacl        | aclitem[] |           |          |
Indexes:
    "pg_database_datname_index" UNIQUE, btree (datname), tablespace "pg_global"
    "pg_database_oid_index" UNIQUE, btree (oid), tablespace "pg_global"
Tablespace: "pg_global"
```

- выхода из psql

```sql
\q                     quit psql
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```sql
with z as (
SELECT attname, avg_width, RANK() OVER (ORDER BY avg_width DESC) rnk FROM pg_stats WHERE tablename LIKE '%orders%')
SELECT attname, avg_width FROM z WHERE rnk=1;
```
|attname|avg_width|
|---|---|
|title|16|
## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

```
test_database=# \d+ orders
                                                 Partitioned table "public.orders"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target |
Description
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
 title  | character varying(80) |           | not null |                                    | extended |              |
 price  | integer               |           |          | 0                                  | plain    |              |
Partition key: RANGE (price)
Partitions: orders_1 FOR VALUES FROM (499) TO (MAXVALUE),
            orders_2 FOR VALUES FROM (MINVALUE) TO (499)
```
Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

```sql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE(price);
CREATE TABLE public.orders_2 PARTITION OF public.orders FOR VALUES FROM (MINVALUE) TO (499);
CREATE TABLE public.orders_1 PARTITION OF public.orders FOR VALUES FROM (499) TO (MAXVALUE);
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```sql
ALTER TABLE ONLY public.orders_1 ADD CONSTRAINT orders_pkey1 PRIMARY KEY (id);
ALTER TABLE ONLY public.orders_2 ADD CONSTRAINT orders_pkey2 PRIMARY KEY (id);
ALTER TABLE ONLY public.orders_1 ADD CONSTRAINT orders_un1 UNIQUE (title);
ALTER TABLE ONLY public.orders_2 ADD CONSTRAINT orders_un2 UNIQUE (title);
```
---