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
