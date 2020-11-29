import urllib.request
import urllib.parse
import sys
from colorama import init
from termcolor import colored

init()

port = str(50001)
if sys.argv[1] == "-port":
    port = str(sys.argv[2])
print("Testing stage 1 - Connections")
print("Connection port set as " + port)

request_1 = ["https://jenkins.dklocek.pl:" + port + "/test", "I'm working!"]
request_2 = ["https://jenkins.dklocek.pl:" + port, "Please use /sort or /sortStudent"]

try:
    urllib.request.urlopen(request_2[0], timeout=10).getcode
except Exception as e:
    print("An Error occurred, probably can't connect to host, details below")
    exit(e)

request_list = [request_1, request_2]
for x in request_list:
    if urllib.request.urlopen(x[0]).read().decode("utf-8") != x[1]:
        exit("Data don't match for " + x[0])
    else:
        print(colored('!OK', 'green'), x[0])

print("Testing stage - 2 - responses")
sort_request = [
    ("table", "5,2,3,1,4"),
    ("method", "quick")
]
sort_request2 = [
    ("table", "Marek,zenon,Adam,dawid"),
    ("method", "bubble")
]
# test_request = [sort_request, sort_request2]
main_url = "https://jenkins.dklocek.pl:" + port + "/sort?"
sort_request = urllib.parse.urlencode(sort_request)
print(urllib.request.urlopen(main_url + sort_request).read().decode("utf-8"))
sort_request2 = urllib.parse.urlencode(sort_request2)
print(urllib.request.urlopen(main_url + sort_request2).read().decode("utf-8"))

# print(test_request)
