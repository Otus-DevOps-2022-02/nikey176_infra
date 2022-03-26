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
