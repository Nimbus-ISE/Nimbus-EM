import numpy as np

def checkNode(G, params, nodeAdd, It, method):
    EXP_MAX = params['EXP_MAX']
    newIt = It.copy()
    error = 0
    BestFO = 0
    BestExpFO = 0
    if np.any(It == nodeAdd): # the given node belongs on the given itinerary (dupe nodes) 
        error = 1
        return newIt, error, BestFO, BestExpFO

    NewSet = It + [nodeAdd] # Nodes of new itinerary
    print(NewSet)
    nodeStart = params['nodeStart'] # parameters 
    nodeEnd = params['nodeEnd']
    timeStart = params['timeStart']
    timeEnd = params['timeEnd']
    AvCostUser = params['AvCostUser']

    # cost control
    costs = [G['AvCostNodes'][i] for i in NewSet]
    if  (sum(costs) / len(costs)) > AvCostUser: #the average cost is higher that the given user average 
        error = 2
        return newIt, error, BestFO, BestExpFO

    DistTimes = params['DistTimes']
    # if not np.array_equal(It, []):
    #    _, visitTimeStart, visitTimeEnd = isItineraryValid(G.OpenHours, G.MinTimeNodes, DistTimes, It, nodeStart, nodeEnd, timeStart, timeEnd)
    #    BestFO, BestExpFO = getObjectiveFunction(It, params['timeStart'], params['timeEnd'], visitTimeStart, visitTimeEnd, G.RatingsNodes)

    if method == 1: # very fast baseline method that uses the current It and only check for the N possible additions of the nodeAdd
        N = len(It)
        for i in range(N+1):
            testIt = np.zeros(N+1, dtype=int)
            testIt[i] = nodeAdd
            if i > 0 and i < N+1: # insert node at the middle
                testIt[0:i] = It[0:i]
                testIt[i+1:N+1] = It[i:N]
            elif i == 0: # insert node at the first
                testIt[1:N+1] = It[0:N]
            else: # insert node at the last
                testIt[0:i] = It[0:i]
                
            valid, visitTimeStart, visitTimeEnd = isItineraryValid(G.OpenHours, G.MinTimeNodes, DistTimes, testIt, nodeStart, nodeEnd, timeStart, timeEnd)
            f, fexp = getObjectiveFunction(testIt, params['timeStart'], params['timeEnd'], visitTimeStart, visitTimeEnd, G.RatingsNodes, G.N, params['Nmin'], params['Nmax'], G.CategoriesNodes)
            if np.min(valid) == 1 and fexp > BestExpFO and EXP_MAX == 1:
                newIt = testIt
                BestFO = f
                BestExpFO = fexp
            elif np.min(valid) == 1 and f > BestFO and EXP_MAX == 0:
                newIt = testIt
                BestFO = f
                BestExpFO = fexp

    return newIt, error, BestFO, BestExpFO
