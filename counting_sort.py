#!/usr/bin/env python
# -*- coding: utf-8 -*-

str = "abracadabra"
freq = [0] * 0xff
cum  = [0] * 0xff
work = [0] * len(str)

for x in map(lambda x: ord(x), str):
    freq[x] += 1

for i in xrange(1, 0xff):
    cum[i] = cum[i - 1] + freq[i]

for i in xrange(len(str) - 1, -1, -1):
    cum[ord(str[i])] -= 1
    work[cum[ord(str[i])]] = str[i]

print work
