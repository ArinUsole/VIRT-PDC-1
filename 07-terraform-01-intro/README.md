# Домашнее задание к занятию "7.1. Инфраструктура как код"

## Задача 1. Выбор инструментов. 
 
### Легенда
 
Через час совещание на котором менеджер расскажет о новом проекте. Начать работу над которым надо 
будет уже сегодня. 
На данный момент известно, что это будет сервис, который ваша компания будет предоставлять внешним заказчикам.
Первое время, скорее всего, будет один внешний клиент, со временем внешних клиентов станет больше.

Так же по разговорам в компании есть вероятность, что техническое задание еще не четкое, что приведет к большому
количеству небольших релизов, тестирований интеграций, откатов, доработок, то есть скучно не будет.  
   
Вам, как девопс инженеру, будет необходимо принять решение об инструментах для организации инфраструктуры.
На данный момент в вашей компании уже используются следующие инструменты: 
- остатки Сloud Formation, 
- некоторые образы сделаны при помощи Packer,
- год назад начали активно использовать Terraform, 
- разработчики привыкли использовать Docker, 
- уже есть большая база Kubernetes конфигураций, 
- для автоматизации процессов используется Teamcity, 
- также есть совсем немного Ansible скриптов, 
- и ряд bash скриптов для упрощения рутинных задач.  

Для этого в рамках совещания надо будет выяснить подробности о проекте, что бы в итоге определиться с инструментами:

1. Какой тип инфраструктуры будем использовать для этого проекта: изменяемый или не изменяемый?
2. Будет ли центральный сервер для управления инфраструктурой?
3. Будут ли агенты на серверах?
4. Будут ли использованы средства для управления конфигурацией или инициализации ресурсов? 

В связи с тем, что проект стартует уже сегодня, в рамках совещания надо будет определиться со всеми этими вопросами.

### В результате задачи необходимо

1. Ответить на четыре вопроса представленных в разделе "Легенда". 

```
1. Для инфраструктуры используем не изменяемый тип. Основные предпосылки к этому:
разработчики привыкли использовать Docker;
год назад начали активно использовать Terraform;
некоторые образы сделаны при помощи Packer;
уже есть большая база Kubernetes конфигураций.

2. На начальном этапе стартуем без центрального сервера, но все конфиги храним в общем ГИТ репозитории.
Далее решаем о необходимости использования центрального сервера.

3. Агенты оркестраторов Docker Sworm или Kubernetes обязательно будут.

4. Инициализации ресурсов в обязательном порядке, Terraform как провайдеро независимый.
Управления конфигурацией для решения особых задач, Ansible скрипты.
```
2. Какие инструменты из уже используемых вы хотели бы использовать для нового проекта? 

```
Terraform для инициализации ресурсов.
Packer для шаблонизации.
Docker+Kubernetes для оркестрации.
Ansible для управления конфигурацией в особых случаях (для решения проблем, когда создавать новый шаблон слишком долго).
Teamcity для автоматизации процессов.
```
3. Хотите ли рассмотреть возможность внедрения новых инструментов для этого проекта? 

```
Для старта нового проекта вполне достаточно представленного стека. Остальное по мере развития и необходимости.
```
Если для ответа на эти вопросы недостаточно информации, то напишите какие моменты уточните на совещании.

```
Используем собственные вычислительные мощности или внешнего сервис провайдера? Какого (есть ли расширение для Terraform)?
```
## Задача 2. Установка Terraform. 

Официальный сайт: https://www.terraform.io/

Установите Terraform при помощи менеджера пакетов используемого в вашей операционной системе.
В виде результата этой задачи приложите вывод команды `terraform --version`.

```
C:\Users\arinu>terraform --version
Terraform v1.1.7
on windows_amd64
```
## Задача 3. Поддержка легаси кода. 

В какой-то момент вы обновили Terraform до новой версии, например с 0.12 до 0.13. 
А код одного из проектов настолько устарел, что не может работать с версией 0.13. 
В связи с этим необходимо сделать так, чтобы вы могли одновременно использовать последнюю версию Terraform установленную при помощи
штатного менеджера пакетов и устаревшую версию 0.12. 

В виде результата этой задачи приложите вывод `--version` двух версий Terraform доступных на вашем компьютере 
или виртуальной машине.

```
C:\>set path=c:\tmp

C:\>terraform --version
Terraform v0.12.31

Your version of Terraform is out of date! The latest version
is 1.1.7. You can update by downloading from https://www.terraform.io/downloads.html
```
---