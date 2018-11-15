#!/usr/bin/env python

# generate a kubeadm-compatible token

import json
import os

# use the TOKEN variable if preset
token = os.environ.get('TOKEN')

if token is None:
    token = os.environ.get('TF_VAR_token')

if token is None:
    try:
        import random
        token = "%0x.%0x" % (random.SystemRandom().getrandbits(3*8),
                             random.SystemRandom().getrandbits(8*8))
    except:
        token = ""

print(json.dumps({'token': token.strip()}, indent=2))
