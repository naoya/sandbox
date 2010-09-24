#!/usr/bin/pyton
import sys

def print_lcs (a, b, lcs, i, j):
    if (i == 0 or j == 0):
        return
    if (a[i-1] == b[j-1]):
        print_lcs(a, b, lcs, i - 1, j - 1)
        print a[i - 1],
    else:
        if lcs[i-1][j] >= lcs[i][j-1]:
            print_lcs(a, b, lcs, i - 1, j)
        else:
            print_lcs(a, b, lcs, i, j - 1)

a = sys.argv[1]
b = sys.argv[2]

lcs = [ [0] * (len(b) + 1) for i in range(len(a)+1) ]
# lcs = [ [0 for j in range(len(b) + 1)] for i in range(len(a)+1) ]

for i in xrange(1, len(a) + 1):
    for j in xrange(1, len(b) + 1):
        if a[i - 1] == b[j - 1]:
            x = 1
        else:
            x = 0
        lcs[i][j] = max(lcs[i-1][j-1] + x, lcs[i-1][j], lcs[i][j-1])

print lcs

print_lcs(a, b, lcs, len(a), len(b))
