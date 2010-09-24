#!/usr/bin/env python
# -*- coding: utf-8 -*-

class CHC:
    @staticmethod
    def min_heapfy (a, i, h):
        l = 2 * i + 1
        r = 2 * i + 2

        if l < h and a[a[l]] < a[a[i]]:
            mi = l
        else:
            mi = i

        if r < h and a[a[r]] < a[a[mi]]:
            mi = r

        if mi != i:
            tmp   = a[i]
            a[i]  = a[mi]
            a[mi] = tmp
            CHC.min_heapfy(a, mi, h)

    @staticmethod
    def build_min_heap (a, h):
        for i in xrange((h - 1)/2, -1, -1):
            CHC.min_heapfy(a, i, h)

    def __init__(self, count):
        ## Phase One: Create an array A of 2n words
        n = len(count)
        A = [None] * (2 * n)
        for i in xrange(n):
            A[n + i] = count[i]
            A[i] = n + i
        print A
        CHC.build_min_heap(A, n)
        print A

        ## Phase Two: Building Huffman tree
        h = n
        while h - 1 > 0:
            m1 = A[0]
            A[0] = A[h - 1]
            h -= 1
            CHC.min_heapfy(A, 0, h)
            print "(1) %s" % A

            m2 = A[0]
            A[h] = A[m1] + A[m2]
            A[0] = h
            A[m1] = A[m2] = h
            CHC.min_heapfy(A, 0, h)
            print "(2) %s" % A

        ## Phase Three: Counting of leaf depths
        A[1] = 0
        for i in xrange(3, 2 * n):
            A[i] = A[A[i]] + 1

        print "last: %s" % A

        ## codelen
        codelen = [None] * n
        for i in xrange(n):
            codelen[i] = A[n + i]

        maxlength = max(codelen)

        ## numl
        numl = [0] * (maxlength + 1)
        for i in xrange(n):
            numl[ codelen[i] ] += 1

        ## firstcode
        firstcode = [0] * (maxlength + 1)
        for l in xrange(maxlength - 1, 0, -1):
            firstcode[l] = (firstcode[l + 1] + numl[l + 1]) / 2

        ## codeword and symbol
        symbol = [None] * (maxlength + 1)
        for l in xrange(maxlength + 1):
            if numl[l] > 0:
                symbol[l] = [None] * numl[l] 

        nextcode = firstcode[:]
        codeword = [None] * n
        for i in xrange(n):
            l = codelen[i]
            codeword[i] = nextcode[l]
            symbol[l][nextcode[l] - firstcode[l]] = i
            nextcode[l] += 1

        self.codelen   = codelen
        self.codeword  = codeword
        self.firstcode = firstcode
        self.symbol    = symbol

    class Encoder:
        def __init__(self, l, w):
            self.codelen  = l
            self.codeword = w

        def encode(self, i):
            s = ""
            v = self.codeword[i]

            ## decimal to binary strings
            for x in xrange(self.codelen[i]):
                s = str(v % 2) + s
                v = v / 2
            return s

    class Decoder:
        def __init__(self, f, s):
            self.firstcode = f
            self.symbol    = s

        @staticmethod
        def nextinputbit(input):
            if len(input) > 0:
                return int(input.pop(0))
            else:
                return

        def decode(self, input):
            v = CHC.Decoder.nextinputbit(input)
            if v is None:
                return
            l = 1
            while v < self.firstcode[l]:
                v  = 2 * v  + CHC.Decoder.nextinputbit(input)
                l += 1
            return self.symbol[l][v - self.firstcode[l]]

#          a   b   c   d   e   f
# count = [ 10, 11, 12, 13, 22, 23 ]
# count = [ 50, 11, 10, 13, 22, 23 ]

#          a   b  c   d   e   f  g   h
count = [ 10, 11, 2, 13, 22, 23, 5, 13 ]

chc = CHC(count)
# print chc.codelen
# print chc.codeword

enc = CHC.Encoder(chc.codelen, chc.codeword)
for i in xrange(len(count)):
    print "%d: %s" % (i, enc.encode(i))

dec = CHC.Decoder(chc.firstcode, chc.symbol)
code = list("0111011010001") ## 34521
while True:
    i = dec.decode(code)
    if i is None:
        break
    print i,
