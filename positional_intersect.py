#!/usr/bin/env python
# -*- coding: utf-8 -*-

class PostingList:
    def __init__(self, p):
        self.p = p

    def __getitem__(self, i):
        return self.p[i][0]

    def __len__(self):
        return len(self.p)

    def positions(self, i):
        return self.p[i][1]

def positional_intersect(p1, p2, k):
    answer = []
    i = 0
    j = 0
    while (i < len(p1) and j < len(p2)):
        if p1[i] == p2[j]:
            l = []
            pp1 = p1.positions(i)
            pp2 = p2.positions(j)
            for x in pp1:
                for y in pp2:
                    if abs(x - y) <= k:
                        l.append(y)
                    elif y > x:
                        break
                while len(l) > 0 and abs(l[0] - x) > k:
                    l.pop(0)
                for y in l:
                    answer.append((p1[i], x, y))
            i += 1
            j += 1
        else:
            if p1[i] < p2[j]:
                i += 1
            else:
                j += 1
    return answer

to = PostingList((
    (1, (7, 18, 33, 72, 86, 231)),
    (2, (1, 17, 74, 222, 255)),
    (4, (8, 16, 190, 429, 433)),
    (5, (363, 367)),
    (7, (13, 23, 191)),
    ))

be = PostingList((
    (1, (17, 25)),
    (4, (17, 191, 291, 430, 434)),
    (5, (14, 19, 101)),
    ))

print positional_intersect(to, be, 3)
