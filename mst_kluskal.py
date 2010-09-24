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

class Edge:
    def __init__(self, src, dst, weight):
        self.src   = src
        self.dst   = dst
        self.weight = weight

edges = [
    Edge('a', 'b', 4),
    Edge('a', 'h', 8),
    Edge('b', 'c', 8),
    Edge('b', 'h', 11),
    Edge('c', 'd', 7),
    Edge('c', 'f', 4),
    Edge('c', 'i', 2),
    Edge('d', 'f', 14),
    Edge('d', 'e', 9),
    Edge('e', 'f', 10),
    Edge('f', 'g', 2),
    Edge('g', 'h', 1),
    Edge('g', 'i', 6),
    Edge('h', 'i', 7),
    ]

c2i = { 'a':0, 'b':1, 'c':2, 'd':3, 'e':4, 'f':5, 'g':6, 'h':7, 'i':8 }
set = DisjointSet(9) # the number of vertices
mst = []

edges.sort(lambda x, y: x.weight - y.weight )
for x in edges:
    u = c2i[x.src]
    v = c2i[x.dst]
    if set.find_set(u) != set.find_set(v):
        mst.append(x)
        set.union(u, v)

print sum(map(lambda x: x.weight, mst))
