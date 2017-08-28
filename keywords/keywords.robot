*** Settings ***
Documentation    Keywords for test

*** Keywords ***
generate_random_name
    Comment  Генерация случайного имени

    ${new_name}    Generate Random String    8    [NUMBERS] [LOWER] [UPPER]
    return from keyword    ${new_name}

chek_the_addition_of_the_service
    Comment  Проверка добавления нового сервиса

    &{header}=    Create Dictionary    Content-Type=application/json
    &{data}=    Create Dictionary    client_id=${client_id}
    Create session    session    ${session}
    ${resp}=    post request    session    /client/services    data=${data}    headers=${header}
    ${resp text}=   parse_text   ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    ${200}     Запрос прошел неуспешно, статус-код = ${resp.status_code}. \nПодробнее: ${resp text}  ${false}
    ${new_client_services}    Parse Json    ${resp.content}
    Should Contain    ${new_client_services['items']}    ${needed_service}   Новый сервис не был добавлен

get_client_services
    [arguments]  ${id}
    Comment  Получение услуг клиента

    &{header}=    Create Dictionary    Content-Type=application/json
    &{data}=    Create Dictionary    client_id=${id}
    Create session    session    ${session}
    ${resp}=    post request    session    /client/services    data=${data}    headers=${header}
    ${resp text}=   parse_text   ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    ${200}     Запрос прошел неуспешно, статус-код = ${resp.status_code}. \nПодробнее:\n${resp text}  ${false}
    ${client_services}    Parse Json    ${resp.content}
    return from keyword  ${client_services}

get_all_services
    Comment  Получение всех услуг

    &{header}=    Create Dictionary    Content-Type=application/json
    Create session    session    ${session}
    ${resp}=    get request    session    /services    headers=${header}
    ${resp text}=   parse_text   ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    ${200}     Запрос прошел неуспешно, статус-код = ${resp.status_code}. \nПодробнее: ${resp text}   ${false}
    ${all_services}    Parse Json    ${resp.content}
    return from keyword    ${all_services}

add_new_client_to_database
    Comment  Добавление нового пользователя в базу данных

    ${new_name}=    generate_random_name
    ${max} =    Query    Select max(m) from (select max(CLIENTS_CLIENT_ID) as m from balances union select max(CLIENT_ID) as m from clients) as a
    Execute SQL String    insert into balances(CLIENTS_CLIENT_ID, BALANCE) values (${max[0][0]}+1, ${new_balance})
    Execute SQL String    insert into clients(CLIENT_ID, CLIENT_NAME) values (${max[0][0]}+1, '${new_name}')
    Log     Добавлен новый пользователь ${new_name} с балансом ${new_balance}
    return from keyword   ${max[0][0]}

post_service
    [arguments]  ${client_id}   ${service_id}
    Comment  Подключение услуги клиенту

    should not be equal     ${client_id}   ${EMPTY}    ID клиента не должен быть пустым     ${False}
    &{header}=    Create Dictionary    Content-Type=application/json
    &{data}=    Create Dictionary    client_id=${client_id}    service_id=${service_id}
    Create session    session    ${session}
    ${resp}=    post request    session    /client/add_service    data=${data}    headers=${header}
    ${resp text}=   parse_text   ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}    ${202}     Запрос прошел неуспешно, статус-код = ${resp.status_code}. \nПодробнее: ${resp text}  ${false}

get_balance_of_client
    [arguments]  ${client_id}
    Comment  Получение баланса клиента

    should not be equal     ${client_id}    ${EMPTY}     ID клиента не должен быть пустым       ${False}
    ${final_balance}=     query    Select balance from balances where clients_client_id = ${client_id}
    return from keyword   ${final_balance}

check_connection_to_databse
    Comment  Проверка подключения к базе данных

    ${connection}=   run keyword and ignore error  query  select * from balances limit 1
    should not be true  '${connection[0]}'=='FAIL'      База данных не подключена

waiting_for_check
    Comment  Ожидание подключения услуги клиенту

    ${wait}=    run keyword and ignore error  Wait Until Keyword Succeeds    1 min    10 sec    chek_the_addition_of_the_service
    run keyword if  '${wait[0]}'=='FAIL'  should be true    ${False}   Услуга не была подключена

find_suitable_service
    [arguments]  ${all_services}   ${client_services}
    Comment  Поиск еще не подключенной клиенту услуги

    ${needed_service}=    find_service    ${all_services}    ${client_services}
    should be true     ${needed_service}   Не удалось найти подходящую услугу
    return from keyword  ${needed_service}

check_balance_change
    [arguments]  ${client_balance}   ${service_cost}    ${final_balance}
    Comment  Проверка корректности изменения баланса клиента

    should not be equal     ${client_balance}    ${EMPTY}     Баланс клиента не должен быть пустым       ${False}
    should not be equal     ${service_cost}    ${EMPTY}      Стоимость услуги не должна быть пустой       ${False}
    should not be equal     ${final_balance}    ${EMPTY}     Баланс клиента не должен быть пустым       ${False}
    ${difference}=      evaluate    ${client_balance} - ${service_cost}
    should be equal as numbers     ${final_balance}    ${difference}       Некорректное изменение баланса