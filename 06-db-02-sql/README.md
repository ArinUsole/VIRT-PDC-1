# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

```yml
version: "3.9"
services:
  postgres:
    container_name: postgres_container
    image: postgres:13.3
    environment:
      POSTGRES_DB: "test_db"
      POSTGRES_USER: "test-admin-user"
      POSTGRES_PASSWORD: "pgpwd4myusr"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./initSQL:/docker-entrypoint-initdb.d
      - .:/var/lib/postgresql/data
      - ./pgbackup:/pgbackup
    ports:
      - "5432:5432"
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 4G
    networks:
      - postgres

networks:
  postgres:
    driver: bridge
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,

|oid|datname|datdba|encoding|datcollate|datctype|datistemplate|datallowconn|datconnlimit|datlastsysoid|datfrozenxid|datminmxid|dattablespace|datacl|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|13395|postgres|10|6|en_US.utf8|en_US.utf8||true|-1|13394|479|1|1663||
|16384|test_db|10|6|en_US.utf8|en_US.utf8||true|-1|13394|479|1|1663||
|1|template1|10|6|en_US.utf8|en_US.utf8|true|true|-1|13394|479|1|1663|{"=c/\"test-admin-user\""|"\"test-admin-user\"=CTc/\"test-admin-user\""}|
|13394|template0|10|6|en_US.utf8|en_US.utf8|true||-1|13394|479|1|1663|{"=c/\"test-admin-user\""|"\"test-admin-user\"=CTc/\"test-admin-user\""}|

- описание таблиц (describe)

```sql
CREATE TABLE IF NOT EXISTS orders
(
    id SERIAL PRIMARY KEY,
    descr TEXT,
    price INTEGER
);
COMMENT ON TABLE orders IS 'Заказы';
COMMENT ON COLUMN orders.descr IS 'наименование';
COMMENT ON COLUMN orders.price IS 'цена';

CREATE TABLE IF NOT EXISTS clients(  
    id SERIAL NOT NULL PRIMARY KEY,
    fullName TEXT,
    country TEXT,
    idOrder INTEGER REFERENCES orders
);
CREATE INDEX IF NOT EXISTS index_clients_1 ON clients (country);
COMMENT ON TABLE clients IS 'Клиенты';
COMMENT ON COLUMN clients.fullName IS 'фамилия';
COMMENT ON COLUMN clients.fullName IS 'страна проживания';
COMMENT ON COLUMN clients.fullName IS 'заказ';
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```sql
SELECT * FROM "table_privileges" WHERE table_catalog = 'test_db' AND table_schema = 'public';
```
- список пользователей с правами над таблицами test_db

|grantor|grantee|table_catalog|table_schema|table_name|privilege_type|is_grantable|with_hierarchy|
|---|---|---|---|---|---|---|---|
|test-admin-user|test-admin-user|test_db|public|orders|INSERT|YES|NO|
|test-admin-user|test-admin-user|test_db|public|orders|SELECT|YES|YES|
|test-admin-user|test-admin-user|test_db|public|orders|UPDATE|YES|NO|
|test-admin-user|test-admin-user|test_db|public|orders|DELETE|YES|NO|
|test-admin-user|test-admin-user|test_db|public|orders|TRUNCATE|YES|NO|
|test-admin-user|test-admin-user|test_db|public|orders|REFERENCES|YES|NO|
|test-admin-user|test-admin-user|test_db|public|orders|TRIGGER|YES|NO|
|test-admin-user|test-admin-user|test_db|public|clients|INSERT|YES|NO|
|test-admin-user|test-admin-user|test_db|public|clients|SELECT|YES|YES|
|test-admin-user|test-admin-user|test_db|public|clients|UPDATE|YES|NO|
|test-admin-user|test-admin-user|test_db|public|clients|DELETE|YES|NO|
|test-admin-user|test-admin-user|test_db|public|clients|TRUNCATE|YES|NO|
|test-admin-user|test-admin-user|test_db|public|clients|REFERENCES|YES|NO|
|test-admin-user|test-admin-user|test_db|public|clients|TRIGGER|YES|NO|



## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

```sql
SELECT count(*) FROM "orders";
```

| |count|
|-|-|
|1|5|
```sql
SELECT count(*) FROM "clients";
```
| |count|
|-|-|
|1|5|

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

```sql
UPDATE "clients" SET idOrder = 3 WHERE id = 1;
UPDATE "clients" SET idOrder = 4 WHERE id = 2;
UPDATE "clients" SET idOrder = 5 WHERE id = 3;
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
```sql
SELECT c.id, c.fullname, c.country, c.idorder FROM clients c JOIN orders o on o.id=c.idorder;
```

|id|fullname|country|idorder|
|---|---|---|---|
|1|Иванов Иван Иванович|USA|3|
|2|Петров Петр Петрович|Canada|4|
|3|Иоганн Себастьян Бах|Japan|5|

Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```sql
EXPLAIN SELECT c.id, c.fullname, c.country, c.idorder FROM clients c JOIN orders o on o.id=c.idorder;
```
```
QUERY PLAN
Hash Join  (cost=37.00..57.24 rows=810 width=72)
  Hash Cond: (c.idorder = o.id)
  ->  Seq Scan on clients c  (cost=0.00..18.10 rows=810 width=72)
  ->  Hash  (cost=22.00..22.00 rows=1200 width=4)
        ->  Seq Scan on orders o  (cost=0.00..22.00 rows=1200 width=4)
```

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

```bash
docker exec postgres_container /bin/bash -c "export PGPASSWORD=pgpwd4myusr && /usr/bin/pg_dump -U test-admin-user test_db | gzip -9 > /pgbackup/postgres-backup.sql.gz" 
```
Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

```bash
docker exec postgres_container_1 pg_restore -U postgres -d some_database /backups/postgres-backup.sql 
```

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---