# It check if is a given Itinerary is valid according t time constraints
# (OpenHours,timeEnd)
# valid: vector of N+1 size that is 1 if It(i) is ok to be visited according t time constraints 
# It(N+1)-> nodeEnd
# duration: total time duration of the Itinerary

import numpy as np

def isItineraryValid(OpenHours, MinTimeNodes, DistTimes, It, nodeStart, nodeEnd, timeStart, timeEnd):
    valid = np.zeros(len(It) + 1)
    visitTimeStart = np.zeros(len(It) + 1)
    visitTimeEnd = np.zeros(len(It) + 1)

    t = timeStart + DistTimes[nodeStart, It[0]]
    for i in range(len(It)):
        visitTimeStart[i] = t
        t = t + MinTimeNodes[It[i]]
        visitTimeEnd[i] = t
        if i < len(It) - 1:
            t = t + DistTimes[It[i], It[i+1]]
        else:
            t = t + DistTimes[It[i], nodeEnd]
        if isOpen(OpenHours[It[i]], visitTimeStart[i], visitTimeEnd[i]) < 0.95:
            valid[i] = -1
        else:
            valid[i] = 1

    visitTimeStart[len(It)] = t # end node
    visitTimeEnd[len(It)] = t

    if visitTimeEnd[len(It)] > timeEnd:
        valid[len(It)] = -1
    else:
        valid[len(It)] = 1

    return valid, visitTimeStart, visitTimeEnd

def isOpen(openHours, visitTimeStart, visitTimeEnd):
    return (visitTimeStart >= openHours[0]) and (visitTimeEnd <= openHours[1])
