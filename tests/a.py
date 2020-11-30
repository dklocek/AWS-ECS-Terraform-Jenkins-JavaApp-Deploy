from functions import *
import sys

host = 'localhost'
port = '8080'
data = sys.argv
for i in range(1, len(sys.argv)):
    if data[i] == '-host':
        host = data[i+1]
    elif data[i] == '-port':
        port = data[i+1]

# print(host+':'+port)

availability_check(host, port)
response_check(host, port)
