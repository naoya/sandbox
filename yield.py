#!/usr/bin/env python
# -*- coding: utf-8 -*-


list = [ 'a', 'b', 'c', 'd', 'e' ]
def seq ():
    for i in xrange(len(list)):
        yield list[i]

g = seq()
print g.next()
print g.next()
