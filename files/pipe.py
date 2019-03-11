#!/usr/bin/env python
import sys
import redis
input = sys.stdin.readlines()
message = ''.join(input)
recipient = str(sys.argv[1])
try:
  r = redis.Redis(host='localhost')
  r.lpush(recipient,message)
except Exception, e:
  sys.exit(str(e) + '. Recipient= ' + recipient)

