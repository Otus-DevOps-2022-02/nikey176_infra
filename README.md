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
=======
Конфигурация инфраструктуры Terraform с использованием модулей и использованием remote backend для хранения state-файла
-----------
### Структура проекта:

1. ВМ с базой данных вынесена в модуль db
2. ВМ с приложением вынесена в модуль app
3. Настроена конфигурация для сред stage и prod
4. Хранение state-файла настроено на backend в Yandex Object Storage
5. В модули добавлены provisioner'ы для коннекта приложения и БД с разных ВМ
