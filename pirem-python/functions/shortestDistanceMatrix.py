# return shortest distance matrix for every node in the graph
# uses Floyd Warshall algorithm
# input : 2-N distance matrix from all nodes to all nodes
# output : 2-N shortest distance matrix from all nodes to all nodes

import math

def shortestDistanceMatrix(dist_matrix):
     N = len(dist_matrix)

    # only for testing dataset where some edges are 0
     for i in range(0, N):
        for j in range(0, N):
            if (dist_matrix[i][j] == 0 and i != j):
                dist_matrix[i][j] = math.inf

     dist = list(map(lambda i: list(map(lambda j: j, i)), dist_matrix))
     for k in range(N):
          # pick all vertices as source one by one
          for i in range(N):
               # Pick all vertices as destination for the above picked source
               for j in range(N):
                    # If vertex k is on the shortest path from
                    # i to j, then update the value of dist[i][j]
                    dist[i][j] = min(dist[i][j],
                                   dist[i][k] + dist[k][j])
     return dist
