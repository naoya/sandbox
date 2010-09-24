#!/usr/bin/env python
# -*- coding: utf-8 -*-

def strncmp (s1, n1, s2, n2, n):
    if n == 0:
        return 0
    while True:
        if s1[n1] != s2[n2]:
            return ord(s1[n1]) - ord(s2[n2])
        if n == 1: return 0
        if n1 >= len(s1) - 1 or n2 >= len(s2) - 1:
            return (len(s1) - n1) - (len(s2) - n2)
        n1 += 1
        n2 += 1     
        n  -= 1
    return 0

def build_sa (buf):
    SA = range(0, len(buf))
    SA.sort(lambda i,j: strncmp(buf, i, buf, j, len(buf) - 1))
    return SA

def build_bwt (buf, SA):
    return map(lambda i: buf[i - 1], SA)

import sys

fh  = open(sys.argv[1], 'r')
buf = fh.read()
SA  = build_sa(buf)
print ''.join(build_bwt(buf, SA))
