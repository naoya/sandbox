#!/usr/bin/env python

adj = [
    [ 1, 2 ],
    [ 0, 2, 3 ],
    [ 0, 1, 4 ],
    [ 1, 4, 5 ],
    [ 2, 3, 6 ],
    [ 3 ],
    [ 4 ]
    ]

def depth_first (start, goal):
    df_search(goal, [ start ])

def df_search (goal, path):
    n = path[-1]
    if n == goal:
        print path
    else:
        for x in adj[n]:
            if x not in path:
                path.append(x)
                df_search(goal, path)
                path.pop()

def breadth_first (start, goal):
    q = [ [ start ] ]

    while len(q) > 0:
        path = q.pop(0)
        n = path[-1]
        if n == goal:
            print path
        else:
            for x in adj[n]:
                if x not in path:
                    new_path = path[:]
                    new_path.append(x)
                    q.append(new_path)

depth_first(0, 6)    

print

breadth_first(0, 6)
