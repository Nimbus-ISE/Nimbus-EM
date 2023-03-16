import numpy as np

def getSeqItSelection(G, params, method):
    EXP_MAX = params["EXP_MAX"]
    RUN_REMOVAL = params["RUN_REMOVAL"]

    BestIt = []
    It = []  # final Itinerary
    N = G["RatingsNodes"].shape[0] # node size
    BestExpFO = 0  # Expected Gain
    BestFO = 0
    change = 0
    for ite0 in range(N):
        for ite in range(N):  # N is max size of path
            fsave = []
            fsaveexp = []
            Set = np.setdiff1d(np.arange(1, N + 1), It)  # candidate nodes for visiting
            first = 0
            change = 0

            for i in range(Set.shape[0]): # simulate adding a new node i
                nodeAdd = Set[i]
                newIt, _, f, fexp = checkNode(G, params, nodeAdd, It, method)
                fsave.append(f)
                fsaveexp.append(fexp)
                if first == 0 and f > BestFO and EXP_MAX == 1:
                    first = 1
                    BestFO = f
                    BestExpFO = fexp
                    BestIt = newIt
                    change = 1
                elif fexp > BestExpFO and EXP_MAX == 1:
                    BestFO = f
                    BestExpFO = fexp
                    BestIt = newIt
                    change = 1
                elif f > BestFO and EXP_MAX == 0:
                    BestFO = f
                    BestExpFO = fexp
                    BestIt = newIt
                    change = 1
            if change == 0:
                break
            It = BestIt

        if RUN_REMOVAL == 1:  # REMOVAL STAGE (OPTIONAL)
            for ite in range(1):
                change = 0
                Set = np.setdiff1d(np.arange(1, N + 1), It)
                if len(It) > 1:
                    for i in range(len(It)):
                        testIt = np.delete(It, i)
                        for j in range(Set.shape[0]):
                            nodeAdd = Set[j]
                            newIt, _, f, fexp = checkNode(G, params, nodeAdd, testIt, method)
                            if f > BestFO and EXP_MAX == 1:
                                BestFO = f
                                BestExpFO = fexp
                                BestIt = newIt
                                change = 2
                            elif f > BestFO and EXP_MAX == 0:
                                BestFO = f
                                BestExpFO = fexp
                                BestIt = newIt
                                change = 2
                if change == 0:
                    break
                It = BestIt
        if change == 0:
            break
    # save FOs to params
    params["BestFO"] = BestFO
    params["BestExpFO"] = BestExpFO

    _, visitTimeStart, visitTimeEnd = isItineraryValid(
        G["OpenHours"], G["MinTimeNodes"], params["DistTimes"], It, params["nodeStart"], params["nodeEnd"], params["timeStart"], params["timeEnd"]
    )
    params["visitTimeStart"] = visitTimeStart
    params["visitTimeEnd"] = visitTimeEnd
    params["It"] = It
    return It, params
