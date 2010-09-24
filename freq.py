#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

text = sys.argv[1]
ascii = {}
cur   = 0

for x in (sorted(text)):
    if x not in ascii:
        ascii[x] = cur
        cur += 1

freq = [0] * len(ascii)
for x in text:
    freq[ascii[x]] += 1

print ascii
print freq
