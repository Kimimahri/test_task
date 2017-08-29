# Описание выполнения тестового задания
В ходе выполнения тестового задания были сделаны следующие дополнения:
  - Для корректной работы БД с помощью docker-compose было произведено монтирование директории (./web:/app).
  - Для корректного выбора подключаемой клиенту услуги, производится отброс клиентов у которых уже установлены все услуги.

Примечания:
  - Запуск тестов производится с помощью файла run_tests.sh;
  - Test Cases расположены в файле /tests/test.robot;
  - Keywords расположены в /keywords/keywords.robot
  - Вспомогательные функции расположенные в библиотеке /libraries/finder.py;
  - Подключение всех ресурсов производится в файле /resources/resources.robot;
  - Отчеты расположены в папке /reports.

## Описание тест кейсов

### Connect to Database
#### Предусловия
Окружение установлено и запущено.
#### Описание
Подключение к базе данных и проверка ее работоспособности.
#### Ожидаемый результат
База данных успешно подключена.

### Get Client ID and Balance
#### Предусловия
База данных подключена.
#### Описание
Выполнение запроса для получения и фиксации ID и баланса клиента соответствующего следующим критериям:
- баланс больше 0;
- у клиента есть доступная для подключения услуга.
Если нет подходящего клиента, создается новый клиент.
#### Ожидаемый результат
Получены ID и баланс клиента.

### Get Client Services
#### Предусловия
Зафиксирован ID клиента.
#### Описание
Выполнение запроса для получения и фиксации услуг клиента.
#### Ожидаемый результат
Получены услуги клиента.

### Get All Services
#### Предусловия
Окружение установлено и запущено.
#### Описание
Получение и фиксация всех возможных услуг.
#### Ожидаемый результат
Получены все возможные услуги.

### Post Suitable Service
#### Предусловия
Зафиксированы ID клиента, все услуги и услуги клиента.
#### Описание
Фиксация еще не подключенной услуги.
Выполнение запроса для подключения услуги клиенту.
Ожидание подключения услуги.
#### Ожидаемый результат
Услуга подключена.

### Get Final Balance
#### Предусловия
Клиенту подключена новая услуга. Зафиксированы цена услуги и баланс клиента до ее подключения.
#### Описание
Выполнение запроса для получения и фиксации итогового баланса клиента.
#### Ожидаемый результат
Итоговый баланс клиента = балансу клиента до подключения услуги — цена услуги.

## Описание keywords

### generate_random_name
#### Описание
Генерация случайного имени.

### chek_the_addition_of_the_service
#### Описание
Проверка добавления нового сервиса.

### get_client_services
#### Аргументы
ID клиента.
#### Описание
Получение услуг клиента.

### get_all_services
#### Описание
Получение всех услуг.

### add_new_client_to_database
#### Описание
Добавление нового пользователя в базу данных.

### post_service
#### Аргументы
ID клиента, ID услуги.
#### Описание
Подключение услуги клиенту.

### get_balance_of_client
#### Аргументы
ID клиента.
#### Описание
Получение баланса клиента.

### check_connection_to_databse
#### Описание
Проверка подключения к базе данных.

### waiting_for_check
#### Описание
Ожидание подключения услуги клиенту.

### find_suitable_service
#### Аргументы
Все сервисы, сервисы клиента.
#### Описание
Поиск еще не подключенной клиенту услуги.

### check_balance_change
#### Аргументы
Баланс клиента, цена услуги, итоговый баланс.
#### Описание
Проверка корректности изменения баланса клиента.

## Функции библиотеки finder

### gen
#### Аргументы
Все сервисы, сервисы клиента.
#### Описание
Возвращает генератор содержащий не подключенные сервисы клиента.

### find_service
#### Аргументы
Все сервисы, сервисы клиента.
#### Описание
Возвращает еще не подключенный сервис клиента.

### run_keyword_for_test
#### Аргументы
Keyword, *args, **kwargs.
#### Описание
Выполняет keyword. 

### find_client_with_positive_balance
#### Описание
Возвращает клиента с позитивным балансом, если нет подходящего — создается новый клиент.

### parse_text
#### Аргументы
Строка.
#### Описание
Парсер текста ошибок.

-----------
Zubovich Andrey andrej.zubovich@simbirsoft.com
