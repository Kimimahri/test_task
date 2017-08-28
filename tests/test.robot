*** Settings ***
Documentation     Tests cases for test
Resource    ../resources/resources.robot

*** Variables ***
${db_type}           sqlite3
${db_name}           clients.db
${new_balance}       5.00
${session}           http://localhost:5000
${200}               200
${202}               202
${client_id}         ${EMPTY}
${client_balance}    ${EMPTY}
${client_services}   ${EMPTY}
${all_services}      ${EMPTY}
${service_id}        ${EMPTY}
${service_cost}      ${EMPTY}
${needed_service}    ${EMPTY}
${final_balance}     ${EMPTY}
${client}            ${EMPTY}


*** Test Cases ***
Connect to Database
    [Tags]    connect   services
    [Documentation]     Подключение к базе данных

    Connect To Database Using Custom Params    ${db_type}    '${db_name}'
    check_connection_to_databse

Get Client ID and Balance
    [Tags]    get   database
    [Documentation]
    ...     Получение ID и баланса подходящего клиента
    ...     У клиента должен быть хотя бы одна неподключенная услуга, а баланс клиента должен быть больше нуля
    ...     Будет создан новый клиент, если не будет найден подходящий под условия кандидат

    ${client}=   find_client_with_positive_balance
    should be true   ${client}   Не удалось найти подходящего клиента
    Set Global Variable    ${client_id}    ${client[0][0]}
    Set Global Variable    ${client_balance}    ${client[0][1]}

Get Client Services
    [Tags]    get   services
    [Documentation]  Получение подключенных клиенту услуг

    ${client_services}=    get_client_services   ${client_id}
    Set Global Variable    ${client_services}

Get All Services
    [Tags]    get   services
    [Documentation]  Получение всех услуг

    ${all_services}=    get_all_services
    Set Global Variable    ${all_services}

Post Suitable Service
    [Tags]    post    services
    [Documentation]  Подключение клиенту еще не подключенной услуги

    ${needed_service}=  find_suitable_service   ${all_services}    ${client_services}
    Set Global Variable    ${service_id}    ${needed_service['id']}
    Set Global Variable    ${service_cost}    ${needed_service['cost']}
    Set Global Variable    ${needed_service}
    post_service    ${client_id}    ${service_id}
    waiting_for_check

Get Final Balance
    [Tags]    get   database
    [Documentation]  Получение нового баланса клиента

    ${final_balance}=    get_balance_of_client      ${client_id}
    Set Global Variable     ${final_balance}    ${final_balance[0][0]}
    check_balance_change    ${client_balance}   ${service_cost}    ${final_balance}

