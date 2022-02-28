# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
```bash
mysql> \s
--------------
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          12
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.28 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 6 min 8 sec

Threads: 3  Questions: 6  Slow queries: 0  Opens: 118  Flush tables: 3  Open tables: 37  Queries per second avg: 0.016
--------------
```

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

```sql
mysql> select count(*) from test_db.orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.
```sql
mysql> select * from INFORMATION_SCHEMA.USER_ATTRIBUTES;
+------------------+-----------+---------------------------------------+
| USER             | HOST      | ATTRIBUTE                             |
+------------------+-----------+---------------------------------------+
| root             | %         | NULL                                  |
| mysql.infoschema | localhost | NULL                                  |
| mysql.session    | localhost | NULL                                  |
| mysql.sys        | localhost | NULL                                  |
| root             | localhost | NULL                                  |
| test             | localhost | {"fname": "James", "lname": "Pretty"} |
+------------------+-----------+---------------------------------------+
6 rows in set (0.01 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

```sql
mysql> SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE table_name = 'orders';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.01 sec)
```
Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`

```sql
mysql> SHOW PROFILES;
+----------+------------+-------------------------------------+
| Query_ID | Duration   | Query                               |
+----------+------------+-------------------------------------+
|        1 | 0.02346400 | select count(*) from test_db.orders |
+----------+------------+-------------------------------------+
1 row in set, 1 warning (0.00 sec)

mysql> show profile for query 1;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000172 |
| Executing hook on transaction  | 0.000009 |
| starting                       | 0.000015 |
| checking permissions           | 0.000009 |
| Opening tables                 | 0.022940 |
| init                           | 0.000028 |
| System lock                    | 0.000050 |
| optimizing                     | 0.000014 |
| executing                      | 0.000014 |
| end                            | 0.000004 |
| query end                      | 0.000007 |
| closing tables                 | 0.000065 |
| freeing items                  | 0.000067 |
| cleaning up                    | 0.000072 |
+--------------------------------+----------+
14 rows in set, 1 warning (0.00 sec)
```
- на `InnoDB`

```sql
mysql> SHOW PROFILES;
+----------+------------+-------------------------------------+
| Query_ID | Duration   | Query                               |
+----------+------------+-------------------------------------+
|        1 | 0.00175825 | select count(*) from test_db.orders |
+----------+------------+-------------------------------------+
1 row in set, 1 warning (0.00 sec)

mysql> show profile for query 1;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000342 |
| Executing hook on transaction  | 0.000014 |
| starting                       | 0.000012 |
| checking permissions           | 0.000008 |
| Opening tables                 | 0.000043 |
| init                           | 0.000007 |
| System lock                    | 0.000011 |
| optimizing                     | 0.000006 |
| statistics                     | 0.000055 |
| preparing                      | 0.000029 |
| executing                      | 0.001080 |
| end                            | 0.000020 |
| query end                      | 0.000006 |
| waiting for handler commit     | 0.000013 |
| closing tables                 | 0.000013 |
| freeing items                  | 0.000045 |
| cleaning up                    | 0.000059 |
+--------------------------------+----------+
17 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

```
[mysqld]
innodb_buffer_pool_size=1024M
innodb_log_file_size=100M
innodb_log_buffer_size=1M
innodb_file_per_table=1
innodb_file_format=Barracuda
innodb_flush_method=O_DSYNC
```

---