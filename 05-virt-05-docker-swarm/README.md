# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?

global - контейнер запускается на каждом узле кластера, replication - на указанном числе узлов. 
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?

RAFT - алгоритм поддержания распределенного консенсуса.
- Что такое Overlay Network?

Overlay-сети используются в контексте кластеров (Docker Swarm), где виртуальная сеть, которую используют контейнеры, связывает несколько физических хостов, на которых запущен Docker.

## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```
```bash
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
p7964zdxb76sxpdp67jcnpdn7 *   node01.netology.yc   Ready     Active         Leader           20.10.12
j0rgfuogmj0u6ww7qct44tg12     node02.netology.yc   Ready     Active         Reachable        20.10.12
ufyxjmiksecnc1n9n1n2wtgr7     node03.netology.yc   Ready     Active         Reachable        20.10.12
o6lkiq2f5t0th9qlp95k7yk0g     node04.netology.yc   Ready     Active                          20.10.12
mgge6lieog5w0rvbajpaaqfjj     node05.netology.yc   Ready     Active                          20.10.12
vtt73ag0n54pefglcwwc1oxd1     node06.netology.yc   Ready     Active                          20.10.12
```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```
```bash
[centos@node01 ~]$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
h7szsbnx1mvp   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
qegww0dbn0ig   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
vlm33cyms25t   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
qmbpo4n38hy4   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
ox1pt92zufvs   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
u6dwoc0oskk4   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
t116bym8nw1s   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
gncka971ci2x   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```

## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```
```bash
[centos@node01 ~]$ sudo docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-BgJEpOZTfLpeSh0uPNeBPBX/bBkQObJuEWJX1TpfPdI

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```
Изменяет место хранения ключей TLS с автоматического на ручное. Администратор кластера должен будет ввести ключ при его включении.
