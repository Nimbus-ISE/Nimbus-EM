# The Objective Function of a legal tour It
# visitTimeStart(i),visitTimeEnd(i) show the start and end times of visiting PoI
# It(i) 
# f: objective function
# f_Exp: expected value of f

import numpy as np

def getObjectiveFunction(It, timeStart, timeEnd, visitTimeStart, visitTimeEnd, RatingsNodes, N, Nmin, Nmax, Cat):
    f = 0
    dp = 0
    for i in range(len(It)):
        dp = dp + visitTimeEnd[i] - visitTimeStart[i]
        f = f + (visitTimeEnd[i] - visitTimeStart[i]) * RatingsNodes[It[i]]

    # e = 0.01
    # f = f - e * (visitTimeEnd[-1] - timeStart - dp)
    f = f * np.log(1 + len(It)) / (np.log(1 + N) * (timeEnd - timeStart))
    f0 = f

    NR = np.zeros(len(Nmin))
    for i in range(len(It)):
        NR[Cat[It[i]]-1] += 1

    # categories
    c = np.zeros(3)
    c[0] = len(np.where((NR >= Nmin) & (NR <= Nmax))[0])
    pos_c2 = np.where(NR < Nmin)[0]
    if len(pos_c2) > 0:
        c[1] = np.sum(NR[pos_c2] / Nmin[pos_c2])

    pos_c3 = np.where(NR > Nmax)[0]
    if len(pos_c3) > 0:
        c[2] = np.sum((Nmax[pos_c3] / NR[pos_c3]) ** 2)

    NC = len(Nmin)
    cat = np.sum(c) / (NC + 1)
    fr = f
    f = cat + (fr / (NC + 1))  # Objective function f

    LT = (timeEnd - timeStart) / (visitTimeEnd[-1] - timeStart)
    fr_exp = fr * LT
    fc_exp = cat - (c[1] / (NC + 1)) + min(len(pos_c2), LT * c[1]) / (NC + 1)

    f_Exp = fr_exp + fc_exp  # expected value of f

    return f, f_Exp, c, f0
