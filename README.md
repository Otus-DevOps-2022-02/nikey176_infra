# nikey176_infra repository

Подключение к серверу во внутренней сети через узел-бастион
-----------
```
bastion_IP = 51.250.70.70
someinternalhost_IP = 10.128.0.6
```

### Вариант 1
С помощью команды следующего вида:
```
$ ssh -i <файл идентификации для подключения к узлу-бастиону> \
-o ProxyCommand="ssh -i <файл идентификации для подключения к серверу во внутренней сети> <имя пользователя>@<имя узла-бастиона> \
-W %h:%p" <имя сервера во внутренней сети>
```
Пример:
```
$ ssh -i ~/.ssh/nchernukha -o ProxyCommand="ssh -i ~/.ssh/nchernukha nchernukha@51.250.70.70 -W %h:%p" 10.128.0.6
```
### Вариант 2
С помощью конфигурационного файл ssh. Добавить в конфигурационный файл строки:
```
Host someinternalhost
	Hostname <имя сервера во внутренней сети>
	ProxyCommand ssh -i <файл идентификации для подключения к узлу-бастиону> <имя пользователя>@<имя узла-бастиона> -W %h:%p
	IdentityFile <файл идентификации для подключения к серверу во внутренней сети>
```
Пример:
```
Host someinternalhost
	Hostname 10.128.0.6
	ProxyCommand ssh -i ~/.ssh/nchernukha nchernukha@51.250.70.70 -W %h:%p
	IdentityFile /home/nchernukha/.ssh/nchernukha
```


Подключение к хосту во внутренней сети через VPN
-----------
```
bastion_IP = 51.250.70.70
someinternalhost_IP = 10.128.0.6
```
### Подключение к VPN-серверу Pritunl
1. Установить OpenVPN Connect
2. Создать профиль подключения, выполнив импорт файла cloud-bastion.ovpn
3. Использовать для подключения учетную запись _test_

### Конфигурация VPN-сервера Pritunl:
1. Настройки доступны по [ссылке](https://51.250.70.70.sslip.io/) (соединение защищено сертификатом Let's Encrypt)
2. Для входа использовать учетную запись _pritunl_

Деплой тестового приложения
-----------
```
testapp_IP = 51.250.70.70
testapp_port = 9292
```
### Скрипт для создания инстанса
```
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=infra-ru-central1-a,nat-ip-version=ipv4, nat-address=51.250.70.70 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=metadata.yaml
```

Сборка образов VM при помощи Packer
-----------
1. Создать образ семейства reddit-full, выполнив команду:
```
# cd packer && packer build -var-file=variables.json ./immutable.json
```
2. Запустить скрипт по созданию ВМ на основе созданного образа
```
# cd config-scripts
# ./create-reddit-vm.sh
```
3. После запуска ВМ приложение будет доступно по [ссылке](http://51.250.70.70:9292/)

Доступ к приложению через HTTP-балансировщик Yandex Cloud при помощи Terraform
-----------
### Структура проекта:

1. В main.tf описано создание инстансов в Yandex Cloud
2. В lb.tf описано создание балансировщика и целевой группы для балансировщика в Yandex Cloud
3. Входные переменные описаны в variables.tf
3. Выходные переменные описаны в outputs.tf
4. Приведены примеры значений для входных переменных terraform.tfvars.example
5. В папку files добавлены файлы для провиженеров из main.tf

### Как запустить приложение с доступом через балансировщик:

1. Определить значение переменных в terraform.tfvars
2. Запустить создание ресурсов командой:  
`$ terraform apply -auto-approve`
3. После успешного выполнения команды в консоли отобразится ip-адрес балансировщика:  
`external_ip_load-balancer`
5. Перейти по адресу:  
`http://<external_ip_load-balancer>:9292`

Конфигурация инфраструктуры Terraform с использованием модулей и использованием remote backend для хранения state-файла
-----------
### Структура проекта:

1. ВМ с базой данных вынесена в модуль db
2. ВМ с приложением вынесена в модуль app
3. Настроена конфигурация для сред stage и prod
4. Хранение state-файла настроено на backend в Yandex Object Storage
5. В модули добавлены provisioner'ы для коннекта приложения и БД с разных ВМ

Использование 'динамического' json-инвентори в Ansible
-----------
### Структура проекта:

1. Определены группы app и db в файлах inventory и inventory.yml
2. Написан плейбук для клонирования репозитория express42/reddit
3. Создан конфигурационный файл ansible.cfg
4. В ansible.cfg внесена настройка на использование inventory.json
5. Написан скрипт inventory.sh для создания inventory.json на основе ранее созданной инфраструктуры в Yandex Cloud
	- Скрипт запускает команды `terraform show` для развернутых серверов
	- На основе полученных IP-адресов создает json-файл
6. Добавлен пример созданного скриптом инвентори-файла inventory.json

### Как запустить проект:

1. Создать инфраструктуру в средах stage и prod с помощью terraform
2. Запустить скрипт inventory.sh
3. Убедиться в том, что инвентори-файл inventory.json успешно создан
4. Выполнить команду
`ansible all -m ping`

Деплой и управление конфигурацией с Ansible
-----------
### Структура проекта:

1. Выполнены инструкции в рамках основной части ДЗ:
- Написан плейбук с одним сценарием
- Написан плейбук с несколькими сценариями
- Написано несколько плейбуков для разных частей конфигурации приложения
- В Packer'е провижининг переключен на Ansible
2. В рамках дополнительной части ДЗ выполнено:
- Изучена документация к плагину yc_compute.py с примерами использования
- Настроен инвентори-файл на использование плагина в моем окружении
- В инвентори добавил 3 варианта ключей для keyed_groups:

a) простой вариант с группировкой по ид папки с инстансами
```
- key: folder_id
	prefix: ''
	separator: ''
```
пример команды:
```
$ ansible all -i yc.yaml -m ping -o --limit 'b1gf67o53kg106nnl0fl'
```

b) вариант с вложенностью для значения disk_id
```
- key: boot_disk['disk_id']
	prefix: ''
	separator: ''
```
пример команды:
```
$ ansible all -i yc.yaml -m ping -o --limit 'fhmd0co55fe39t0ibnbj'
```

c) аналогичный предыдущему вариант для значения метки group с добавлением префикса и разделителя:
```
- key: labels['group']
	prefix: 'otus'
	separator: '_'
```
пример команды:
```
$ ansible all -i yc.yaml -m ping -o --limit 'otus_reddit_db_stage'
```
- При подключении зависимостей плагина использовал виртуальное окружение (модуль venv) 

Ansible. Работа с ролями и окружениями
-----------
### Структура проекта:
1. Основное задание:
- Выполнена настройка ролей app и db с помощью `ansible-galaxy`
- Выполнена настройка окружений stage и prod
- Все плейбуки перенесены в единую папку
- Применена community-роль _jdauphant.nginx_ для конфигурации доступа к приложению
- Данные пользователей зашифрованы при помощи `ansible-vault encrypt` (механизм Ansible Vault)
2. Дополнительное задание:
- Настроен динамический инвентори-файл для окружений stage и prod  
Как использовать скрипт по созданию динамического инвентори-файла:
 1) Предварительно рекомендуется убедиться в том, что команда `terraform show` выполняется успешно
 2) Поместить скрипт _inventory.sh_ в папку Ansible
 3) Запустить скрипт
 4) После запуска скрипт запросит вариант окружения, для которого необходимо создать динамический инвентори-файл
 5) Выберите необходимое окружение и подтвердите выбор нажатием Enter
 6) После этого в папке окружения появится файл _inventory.json_ с описанием выбранного окружения
 
 Разработка и тестирование Ansible ролей и плейбуков
---
#### 1. Установка Vagrant
1. Установлен VirtualBox
2. Установлен Vagrant
3. Создан _Vagrantfile_ с описанием двух ВМ - **dbserver** и **appserver**
4. Запуск ВМ выполнен командой `vagrant up`
5. Проверен статус ВМ, ssh-доступ и ping

#### 2. Провижининг для проверки ролей и плейбуков
##### Доработка роли db
1. Добавлен плейбук _site.yml_ в определение ВМ **dbserver**
2. В плейбук _site.yml_ подключен плейбук _base.yml_ для установки Python
3. В роль _db_ добавлены таски для установки и конфигурации MongoDB
4. Данные таски подключены в _main.yml_
##### Доработка роли app
1. Добавлен плейбук _site.yml_ в определение ВМ **appserver**
2. В роль _app_ добавлены таски для конфигурации хоста приложения (_ruby.yml_ и _puma.yml_)
3. Данные таски подключены в _main.yml_
4. Выполнена параметризация конфигурации для возможности использования роли различными пользователями за счет определения переменной _deploy_user_

#### 3. Тестирование роли
1. Все необходимые зависимости добавлены в _ansible/requirements.txt_
2. Для тестирования роли _db_ создана заготовка при помощи команды:
`molecule init scenario -r db -d vagrant default`
Для использования драйвера vagrant его предварительно необходимо установить:
`pip install 'molecule_vagrant`
3. В файл _db/molecule/default/tests/test_default.py_ добавлены тесты для проверки работы и конфигурации MongoDB
4. Для тестирования роли создана ВМ командой `molecule create`. Дополнительно потребовалось определить роль и пространство имен в _db/meta/main.yml_
Решение найдено [тут](https://stackoverflow.com/questions/69652451/molecule-error-computed-fully-qualified-role-name-does-not-follow-current-galax)
5. Для выполнения проверки роли от имени суперпользователя внесены изменения в плейбук  _db/molecule/converge.yml_. Провижининг изменений выполнен командой `molecule converge`
6. Успешно выполнены тесты, запущенные командой `molecule verify`

#### 4. Самостоятельные задания
1. Добавлен тест для проверки доступности БД на порте 27017
2. В плейбуки packer_db.yml и packer_app.yml подключены роли db и app соответственно.
Для того, чтобы при билде packer'ом роль была найдена, потребовалось добавить переменные в провижинеры:
- ANSIBLE_ROLES_PATH
- ANSIBLE_REMOTE_TMP
3. Роль db вынесена в отдельный репозиторий (https://github.com/nikey176/ansible_role_db) и подключена в окружениях stage и prod через requirements.yml
4. В конфигурацию Vagrant добавлена переменная nginx_sites для проксирования приложения с помощью nginx с порта 9292 на порт 80
