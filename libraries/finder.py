from robot.libraries.BuiltIn import BuiltIn
import re


def gen(services, client_services):
    # generator contains difference between the possible services and services of the client
        set1 = set()
        set2 = set()
        for item in services['items']:
            set1.add(item['id'])
        for item in client_services['items']:
            set2.add(item['id'])
        for item in services['items']:
            if item['id'] in set1-set2:
                yield item


def find_service(services, client_services):
    # find difference between the possible services and services of the client
    try:
        return gen(services, client_services).next()
    except:
        return False


def run_keyword_for_test(keyword, *args, **kwargs):
    # used to run keyword
    return BuiltIn().run_keyword(keyword, *args, **kwargs)


def find_client_with_positive_balance():
    #   find client with positive balance. if there is no client - add new client to database
    try:
        all_services = run_keyword_for_test('get_all_services')
        clients = run_keyword_for_test('Query', 'select * from balances where balance > 0')
        all_id = []
        for i in xrange(len(clients)):
            all_id.append(clients[i][0])
        for id_of_client in all_id:
            services = run_keyword_for_test('get_client_services', id_of_client)
            if services['count'] < all_services['count']:
                return run_keyword_for_test('Query',
                                            'select * from balances where clients_client_id = %s' % id_of_client)
        else:
            max_id = run_keyword_for_test('add_new_client_to_database')
            new_id = max_id + 1
            return run_keyword_for_test('Query', 'select * from balances where clients_client_id = %s' % new_id)
    except:
        return False


def parse_text(row):
    # error parser
    try:
        h1 = re.findall('<h1>(.*)</h1>', row)
        p1 = re.findall('<p>(.*)</p>', row)
        p1[0] = re.sub(r"\. ", ".\n", p1[0])
        return h1[0] + ":\n" + p1[0]
    except:
        return row
