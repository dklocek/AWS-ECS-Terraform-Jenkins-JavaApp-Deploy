import urllib.request
import urllib.parse


def availability_check(host, port):
    try:
        if urllib.request.urlopen(host + ":" + port, timeout=10).getcode() == 200:
            print('!OK --- Connection established')
    except Exception as e:
        print("An Error occurred, probably can't connect to host, details below")
        exit(e)


def response_check(host, port):
    req_list = [
        [host + ':' + port + '/test', 'I\'m working!'],
        [host + ':' + port, "Please use /sort or /sortStudent"]
    ]
    request_sort_list = [
        [("table", "5,2,3,1,4"), ("method", "bubble")],
        [("table", "Marek,zenon,Adam,dawid"), ("method", "bubble")],
        [("table", "5,2,3,1,4"), ("method", "heap")],
        [("table", "Marek,zenon,Adam,dawid"), ("method", "heap")],
        [("table", "5,2,3,1,4"), ("method", "insertion")],
        [("table", "Marek,zenon,Adam,dawid"), ("method", "insertion")],
        [("table", "5,2,3,1,4"), ("method", "merge")],
        [("table", "Marek,zenon,Adam,dawid"), ("method", "merge")],
        [("table", "5,2,3,1,4"), ("method", "quick")],
        [("table", "Marek,zenon,Adam,dawid"), ("method", "quick")],
        [("table", "5,2,3,1,4"), ("method", "selection")],
        [("table", "Marek,zenon,Adam,dawid"), ("method", "selection")],
    ]
    response_expected = ['[1,2,3,4,5]', '["Adam","Marek","dawid","zenon"]']

    for x in req_list:
        if urllib.request.urlopen(x[0]).read().decode("utf-8") != x[1]:
            exit("Data don't match for " + x[0])
        else:
            print('!OK ---' + x[0])

    main_url = host + ':' + port + '/sort?'
    for x in request_sort_list:
        sort_request = urllib.parse.urlencode(x)
        response_got = urllib.request.urlopen(main_url + sort_request).read().decode("utf-8")
        if response_got == response_expected[0] or response_got == response_expected[1]:
            print('!OK ' + str(x[1].__getitem__(1)))
        else:
            exit('Data don\'t match')
            print(response_got)
            print(response_expected)
