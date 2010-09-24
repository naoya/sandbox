#!/usr/bin/env python
# -*- coding: utf-8 -*-

class LogarithmicIndex:
    n       = 2
    I       = [[]]
    Z       = [[]]
    indexes = {}

    @staticmethod
    def merge(p1, p2):
        p1.extend(p2)
        return sorted(p1)

    def add_token (self, token):
        I       = self.I
        Z       = self.Z
        indexes = self.indexes
        n       = self.n

        Z[0] = LogarithmicIndex.merge(Z[0], [ token ])
        if len(Z[0]) == n:
            i = 0
            while True:
                if i in self.indexes:
                    m = LogarithmicIndex.merge(I[i], Z[i])
                    if len(Z) > i + 1:
                        Z[i + 1] = m
                    else:
                        Z.append(m)
                    del indexes[i]
                else:
                    if len(I) >= len(Z):
                        I[i] = Z[i]
                    else:
                        I.append(Z[i])
                    indexes[i] = True
                    break
                i += 1
            Z[0] = []

    def find(self, token):
        if token in self.Z[0]:
            return True
        for i in self.indexes.keys():
            if token in self.I[i]:
                return True
        return False

    def print_indexes(self):
        print "indexes: %s" % self.indexes
        print "Z[0]: %s (%d)" % (self.Z[0], len(self.Z[0]))
        for i in xrange(len(self.I)):
            if i in self.indexes:
                print "I[%d]: %s (%d)" % (i, self.I[i], len(self.I[i]))
        print

idx = LogarithmicIndex()
for i in xrange(1, 10):
    idx.add_token(i)
    idx.print_indexes()

print idx.find(0)  # False
print idx.find(5)  # True
print idx.find(9)  # True
print idx.find(10) # False
