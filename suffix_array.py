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

def sa_search (q, buf, SA):
    l = - 1
    u = len(buf)
    while (l + 1 != u):
        m = (l + u) / 2
        if strncmp(q, 0, buf, SA[m], len(q)) > 0:
            l = m
        else:
            u = m
    if u >= len(buf) or strncmp(q, 0, buf, SA[u], len(q)) != 0:
        return
    return u

## strncmp() tests
# print 1, strncmp("abb", 0, "abc", 0, 3) < 0
# print 2, strncmp("abc", 0, "abc", 0, 3) == 0
# print 3, strncmp("abd", 0, "abc", 0, 3) > 0
# print 4, strncmp("ab",  0, "abc", 0, 3) < 0
# print 5, strncmp("abc", 0, "ab",  0, 3) > 0
# print 6, strncmp("abc", 0, "ab",  0, 1) == 0
# print 7, strncmp("abc", 1, "abd", 1, 1) == 0
# print 8, strncmp("abc", 1, "ab",  1, 2) > 0
# print 9, strncmp("ab",  1, "ab",  1, 2) == 0
# print 10,strncmp("a",   0, "ab",  0, 1) == 0
# print 11,strncmp("a",   0, "a",   0, 1) == 0

buf = "abracadabra"
SA = build_sa(buf)
# print [10, 7, 0, 3, 5, 8, 1, 4, 6, 9, 2]
# print SA

for x in SA:
    print 'SA[%d] = %s' % (x, buf[x:])

import sys
q = sys.argv[1]
i = sa_search(q, buf, SA)

if i is None:
    print "Not found"
    sys.exit(-1)

while i < len(buf) and strncmp(q, 0, buf, SA[i], len(q)) == 0:
    print buf[SA[i]:]
    i += 1
