import numpy as np

def getUserParamsClusters(Params, LOAD_PARAMS, N, Cat, iter):
    params = {}
    # params.validSet = []
    params['BestFO'] = 0
    x = np.remainder(iter, 4) + 1
    # x = 3
    if x == 1:  # Nmax = Nmin Hard
        Nmin = np.random.randint(3, size=(Cat, 1)) - 1  # [0 1 2]
        Nmax = Nmin
    elif x == 2:  # semi flexible
        Nmin = np.random.randint(3, size=(Cat, 1)) - 1  # [0 1 2]
        Nmax = np.maximum(1, Nmin)
    elif x == 3:  # flexible
        Nmin = np.random.randint(3, size=(Cat, 1)) - 1  # [0 1 2]
        Nmax = Nmin + np.random.randint(3, size=(Cat, 1))
    elif x == 4:  # no categories
        Nmin = 0 * np.random.randint(3, size=(Cat, 1))  # [0]
        Nmax = 100 + 0 * np.random.randint(3, size=(Cat, 1))  # [100]

    if LOAD_PARAMS == 0 and Params is None:  # default
        params['nodeStart'] = 7
        params['nodeEnd'] = 13
        params['timeStart'] = 10
        params['timeEnd'] = 18
        params['AvCostUser'] = 10  # 2
        # Nmin = 0*Nmin;
        # Nmax = 0*Nmin+100;
        # Nmin[0] = 2
        # Nmax[0] = 2
        params['Nmin'] = Nmin
        params['Nmax'] = Nmax
        params['Ntype'] = x
    elif LOAD_PARAMS == -1 and Params is None:  # random
        params['nodeStart'] = np.random.randint(N)
        params['nodeEnd'] = np.random.randint(N)
        params['timeStart'] = 9
        params['timeEnd'] = 9 + 4 + np.random.randint(5)
        params['AvCostUser'] = 10  # 2
        params['Nmin'] = Nmin
        params['Nmax'] = Nmax
        params['Ntype'] = x
    elif Params is not None:  # given
        params['nodeStart'] = Params['nodeStart']
        params['nodeEnd'] = Params['nodeEnd']
        params['timeStart'] = Params['timeStart']
        params['timeEnd'] = Params['timeEnd']
        params['AvCostUser'] = Params['AvCostUser']
        params['Nmin'] = Params['Nmin']
        params['Nmax'] = Params['Nmax']
        params['Ntype'] = Params['Ntype']

    return params
