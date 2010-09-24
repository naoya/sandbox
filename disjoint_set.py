#!/usr/bin/env python
# -*- coding: utf-8 -*-

class DisjointSet:
    def __init__ (self, size):
        self.parent = [0] * size
        self.rank =   [0] * size
        for i in xrange(size):
            self.parent[i] = i

    def union(self, x, y):
        self.link( self.find_set(x), self.find_set(y) )
            
    def link (self, x, y):
        if self.rank[x] > self.rank[y]:
            self.parent[y] = self.parent[x]
        else:
            self.parent[x] = self.parent[y]
            if (self.rank[x] == self.rank[y]):
                self.rank[x] += self.rank[y] + 1

    def find_set (self, x):
        if x != self.parent[x]:
            self.parent[x] = self.find_set(self.parent[x])
        return self.parent[x]

set = DisjointSet(10)
print set.find_set(0)
print set.find_set(1)

set.union(0, 1)
set.union(1, 2)

print set.find_set(0)
print set.find_set(1)
print set.find_set(2)
print set.find_set(3)

set.union(1, 3)
set.union(1, 5)

print set.find_set(2)
print set.find_set(3)
