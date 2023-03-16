import numpy as np
import scipy.sparse as sparse
from graphallshortestpaths import graphallshortestpaths

# ITMETHOD = 0; # (Fast Sequential Itinerary Creation) with extra History  (M-PIREM) [1]
ITMETHOD = 1; # (Fast Sequential Itinerary Creation)  (PIREM) [1]


EXP_MAX = 1 # Expectation Maximization
RUN_REMOVAL = 0 # RUN REMOVAL STAGE
ITERATIONS = 16 # default is 256
LOAD_PARAMS = 1 # Load parameters for running

# 1 to plot the result
toPlot = 0

DataDirD = ['datasets/syntnetic2/'] # Input Directory Synthetic data
filesD = ['sd_32_1.mat', 'sd_32_10.mat', 'sd_32_11.mat', 'sd_32_12.mat', 'sd_32_13.mat', 'sd_32_14.mat', 'sd_32_15.mat', 'sd_32_16.mat', 'sd_32_2.mat', 'sd_32_3.mat', 'sd_32_4.mat', 'sd_32_5.mat', 'sd_32_6.mat', 'sd_32_7.mat', 'sd_32_8.mat', 'sd_32_9.mat', 'sd_64_1.mat', 'sd_64_10.mat', 'sd_64_11.mat', 'sd_64_12.mat', 'sd_64_13.mat', 'sd_64_14.mat', 'sd_64_15.mat', 'sd_64_16.mat', 'sd_64_2.mat', 'sd_64_3.mat', 'sd_64_4.mat', 'sd_64_5.mat', 'sd_64_6.mat', 'sd_64_7.mat', 'sd_64_8.mat', 'sd_64_9.mat', 'sd_96_1.mat', 'sd_96_10.mat', 'sd_96_11.mat', 'sd_96_12.mat', 'sd_96_13.mat', 'sd_96_14.mat', 'sd_96_15.mat', 'sd_96_16.mat', 'sd_96_2.mat', 'sd_96_3.mat', 'sd_96_4.mat', 'sd_96_5.mat', 'sd_96_6.mat', 'sd_96_7.mat', 'sd_96_8.mat', 'sd_96_9.mat', 'sd_128_1.mat', 'sd_128_10.mat', 'sd_128_11.mat', 'sd_128_12.mat', 'sd_128_13.mat', 'sd_128_14.mat', 'sd_128_15.mat', 'sd_128_16.mat', 'sd_128_2.mat', 'sd_128_3.mat', 'sd_128_4.mat', 'sd_128_5.mat', 'sd_128_6.mat', 'sd_128_7.mat', 'sd_128_8.mat', 'sd_128_9.mat']
filesParams = ['params_data4C1.mat']

DataDirD.append('datasets/real/') # Input Directory real data
filesD.append('lin-austria.mat')
filesParams.append('params_real_data4C2.mat')

DataDirD.append('datasets/real/') # Input Directory real data
filesD.append('lin-budapest.mat')
filesParams.append('params_real_data4C2.mat')

DataDirD.append('datasets/real/') # Input Directory real data
filesD.append('lin-delh.mat')
filesParams.append('params_real_data4C4.mat')

ResultsDirD = DataDirD.copy()

for DATASET in range(1):
    stats = []
    DataDir = DataDirD[DATASET]
    files = filesD[DATASET]
    ResultsDir = ResultsDirD[DATASET]
    apo = 1
    s = np.where(np.char.isspace(files) == True)[0]
    data = [None] * len(s)
    id = 1
    j0 = 1

    if LOAD_PARAMS == 1:
        np.load(DataDir + filesParams[DATASET])

    for j in range(j0, len(s)):
        eos = s[j]
        fname = files[apo:eos - 1]
        apo = eos + 1
        np.load(DataDir + fname)
        imagePerRUN = j / len(s)

        for iter in range(ITERATIONS):
            if LOAD_PARAMS == 1:
                getUserParamsClusters(Params[j][iter], LOAD_PARAMS, G.N, 8, iter)
            else:
                getUserParamsClusters(None, LOAD_PARAMS, G.N, 8, iter)

            params.iter = iter
            params.ITERATIONS = ITERATIONS
            params.fname = fname
            params.DistTimes = graphallshortestpaths(sparse(G.MinTimeEdges)) # time-distance matrix of all pair of nodes
            params.EXP_MAX = EXP_MAX
            params.RUN_REMOVAL = RUN_REMOVAL
            plotGraphClusters(G, sparse(G.MinTimeEdges), G.Points, G.RatingsNodes, G.RatingsEdges, G.MinTimeNodes, None, params)
            tic()

            if ITMETHOD == 0:
                getSeqItSelectionExtraHist2(G, params, ITMETHOD, 40)
            elif ITMETHOD <= 3:
                getSeqItSelection(G, params, ITMETHOD)

            timerVal = toc()
            params.timerVal = toc()
            plotGraphClusters(G, sparse(G.MinTimeEdges), G.Points, G.RatingsNodes, G.RatingsEdges, G.MinTimeNodes, It, params)
            params.DistTimes = []
            stats[j][iter] = params

    MEAN_OBJ = getMeanOBJ(stats)
    np.save('RES//resRC_H40_data_{0}_{1}_{2}_{3}_{4:.3f}.mat'.format(ITMETHOD, EXP_MAX, RUN_REMOVAL, DATASET, MEAN_OBJ), stats)

