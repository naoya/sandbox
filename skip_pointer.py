#!/usr/bin/env python
# -*- coding: utf-8 -*-

class PostingList:
   def __init__(self, p):
       self.p = p

   def __getitem__(self, i):
       item = self.p[i]
       if type(item) is tuple:
           return item[0]
       else:
           return item

   def __len__(self):
       return len(self.p)

   def skip(self, i):
       return self.p[i][1]

   def has_skip(self, i):
       if type(self.p[i]) is tuple:
           return True
       else:
           return False

def intersect_with_skips(p1, p2):
    answer = []
    i = 0
    j = 0
    c = 0 # loop couner
    while i < len(p1) and j < len(p2):
        c += 1
        if p1[i] == p2[j]:
            answer.append(p1[i])
            i += 1
            j += 1
        else:
            if p1[i] < p2[j]:
                while p1.has_skip(i) and p1[ p1.skip(i) ] <= p2[j]:
                    i = p1.skip(i)
                else:
                    i += 1
            else:
                while p2.has_skip(j) and p2[ p2.skip(j) ] <= p1[i]:
                    j = p2.skip(j)
                else:
                    j += 1
    print 'loop count: %d' % c
    return answer

brutus = PostingList(( 2, 4, 8, 16, 19, 23, 28, 43, ))
caesar = PostingList(( 1, 2, 3, 5, 8, 41, 51, 60, 71, ))
print intersect_with_skips(brutus, caesar)

brutus = PostingList(( (2, 3), 4, 8, (16, 6), 19, 23, 28, 43, ))
caesar = PostingList(( (1, 3), 2, 3, (5, 6), 8, 41, 51, 60, 71,))
print intersect_with_skips(brutus, caesar)
