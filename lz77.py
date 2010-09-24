#!/usr/bin/env python
# -*- coding: utf-8 -*-

W = 8 # スライド窓の長さ
F = 4 # 最長一致長の長さ

def encode_lz77 (str, p, bin):
    ## 怪しい
    last = p + F
    if last >= len(str) - 1:
        last = len(str) - 1

    substr = str[p:last]
    m = -1
    l = len(substr)

    s = p - W
    if s < 0:
        s = 0

    e = p - 1
    if e < 0:
        e = 0

    while l > 0:
        m = str.find(substr, s, e)
        if m > -1:
            break
        else:
            substr = substr[:-1]
            l -= 1

    if m == - 1:
        bin.append([0, 0, str[p]])
    else:
        # if p + l  == len(str):
            # bin.append([p - m, l, None])
        # else:
        bin.append([p - m, l, str[p + l]])

    return p + l + 1

def decode_lz77 (bin):
    str = ''
    p = 0

    for x in bin:
        s = p - x[0]
        e = p - x[0] + x[1]
        str += str[s:e] + x[2]
        # if x[2] is not None:
        #    str += x[2]
        p = p + x[1] + 1

    return str
    
import sys
str = sys.argv[1]

p = 0
l = len(str)
bin = []

while p < l:
    p = encode_lz77(str, p, bin)

print bin

print decode_lz77(bin)
