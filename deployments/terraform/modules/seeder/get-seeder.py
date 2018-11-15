#!/usr/bin/env python

import os

address = os.environ.get('SEEDER')
computed = "false"

if address is None:
    address = os.environ.get('TF_VAR_seeder')

if address is None:
    try:
        import socket

        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        address = s.getsockname()[0]
        s.close()
        computed = "true"
    except:
        address = ""

import json
print(json.dumps({'address': address.strip(), 'computed': computed}, indent=2))
