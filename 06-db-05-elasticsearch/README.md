# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста

```
FROM centos:7

RUN groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000

COPY elasticsearch-8.0.1-x86_64.rpm .

RUN rpm -ivh elasticsearch-8.0.1-x86_64.rpm && rm -rf elasticsearch-8.0.1-x86_64.rpm

WORKDIR /usr/share/elasticsearch

RUN set -ex && for path in data logs config config/scripts; do \
        mkdir -p "$path"; \
        chown -R elasticsearch:elasticsearch "$path"; \
    done
    
COPY elasticsearch.yml /usr/share/elasticsearch/config/

USER elasticsearch

ENV PATH=$PATH:/usr/share/elasticsearch/bin
ENV ELASTIC_PASSWORD=elastic

CMD ["elasticsearch"]

EXPOSE 9200 9300
```
- ссылку на образ в репозитории dockerhub

`далее использовал docker-compose c образом elasticsearch+kibana`
- ответ `elasticsearch` на запрос пути `/` в json виде

```json
{
  "name" : "netology_test",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "C_ZE4WeLTuK87upFZHQhwg",
  "version" : {
    "number" : "8.0.1",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "801d9ccc7c2ee0f2cb121bbe22ab5af77a902372",
    "build_date" : "2022-02-24T13:55:40.601285296Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```json
{
  "cluster_name" : "docker-cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 20,
  "active_shards" : 20,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 66.66666666666666,
  "indices" : {
    "ind-1" : {
      "status" : "green",
      "number_of_shards" : 1,
      "number_of_replicas" : 0,
      "active_primary_shards" : 1,
      "active_shards" : 1,
      "relocating_shards" : 0,
      "initializing_shards" : 0,
      "unassigned_shards" : 0
    },
    "ind-3" : {
      "status" : "yellow",
      "number_of_shards" : 4,
      "number_of_replicas" : 2,
      "active_primary_shards" : 4,
      "active_shards" : 4,
      "relocating_shards" : 0,
      "initializing_shards" : 0,
      "unassigned_shards" : 8
    },
    "ind-2" : {
      "status" : "yellow",
      "number_of_shards" : 2,
      "number_of_replicas" : 1,
      "active_primary_shards" : 2,
      "active_shards" : 2,
      "relocating_shards" : 0,
      "initializing_shards" : 0,
      "unassigned_shards" : 2
    }
  }
}
```
Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

`В кластере только одна нода, отказустойчивость реплик не обеспечивается.`
Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```json
PUT _snapshot/netology_backup
{
  "type": "fs",
  "settings": {
    "location": "my_fs_backup_location"
  }
}
```
```json
{
  "acknowledged" : true
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```json
PUT /test
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}
```
```json
GET /_all
{
  "test" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "test",
        "creation_date" : "1646389996537",
        "number_of_replicas" : "0",
        "uuid" : "6MxfaF8NRvqpicTCvZ_GLw",
        "version" : {
          "created" : "8000199"
        }
      }
    }
  }
}
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

```json
PUT _snapshot/netology_backup/my_snapshot?wait_for_completion=true
```
```bash
sh-5.0$ ls -l
total 92
-rw-rw-r--  1 elasticsearch root  4039 Mar  4 10:39 index-0
-rw-rw-r--  1 elasticsearch root     8 Mar  4 10:39 index.latest
drwxrwxr-x 16 elasticsearch root  4096 Mar  4 10:39 indices
-rw-rw-r--  1 elasticsearch root 75479 Mar  4 10:39 meta-i6soAIOkT2-5EH_O1yrV8A.dat
-rw-rw-r--  1 elasticsearch root   746 Mar  4 10:39 snap-i6soAIOkT2-5EH_O1yrV8A.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```json
{
  "test-2" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "test-2",
        "creation_date" : "1646391580512",
        "number_of_replicas" : "0",
        "uuid" : "RtGA3AjPRFykTcmKMxFXMw",
        "version" : {
          "created" : "8000199"
        }
      }
    }
  }
}
```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```json
POST _snapshot/netology_backup/my_snapshot/_restore
{
  "indices": "test"
}
```
```json
{
  "test" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "test",
        "creation_date" : "1646389996537",
        "number_of_replicas" : "0",
        "uuid" : "eBEGsmBzQwCdxG6-Ganw5g",
        "version" : {
          "created" : "8000199"
        }
      }
    }
  },
  "test-2" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "test-2",
        "creation_date" : "1646391580512",
        "number_of_replicas" : "0",
        "uuid" : "RtGA3AjPRFykTcmKMxFXMw",
        "version" : {
          "created" : "8000199"
        }
      }
    }
  }
}
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`
