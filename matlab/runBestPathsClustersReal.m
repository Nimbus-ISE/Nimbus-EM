%Main script
%https://www.mathworks.com/help/matlab/ref/graph.allpaths.html
all_fig = findall(0, 'type', 'figure');
close(all_fig);
clear all;

%ITMETHOD = 0; % (Fast Sequential Itinerary Creation) with extra History  (M-PIREM) [1]
ITMETHOD = 1; % (Fast Sequential Itinerary Creation)  (PIREM) [1]

%[1] C. Panagiotakis, E. Daskalaki H. Papadakis, and P. Fragopoulou,  The tourist trip design problem with POI categories via an Expectation-Maximization based method, RecSys Workshop on Recommenders in Tourism, 2022.

EXP_MAX = 1; %Expectation Maximization
RUN_REMOVAL = 0; %RUN REMOVAL STAGE
ITERATIONS = 16; %default is 256
LOAD_PARAMS = 1; %Load parameters for running

global toPlot;
toPlot = 0;

DataDirD{1} = 'datasets\syntnetic2\'; %Input Directory Synthetic data
filesD{1} = ['sd_32_1.mat sd_32_10.mat sd_32_11.mat sd_32_12.mat sd_32_13.mat sd_32_14.mat sd_32_15.mat sd_32_16.mat sd_32_2.mat sd_32_3.mat sd_32_4.mat sd_32_5.mat sd_32_6.mat sd_32_7.mat sd_32_8.mat sd_32_9.mat sd_64_1.mat sd_64_10.mat sd_64_11.mat sd_64_12.mat sd_64_13.mat sd_64_14.mat sd_64_15.mat sd_64_16.mat sd_64_2.mat sd_64_3.mat sd_64_4.mat sd_64_5.mat sd_64_6.mat sd_64_7.mat sd_64_8.mat sd_64_9.mat sd_96_1.mat sd_96_10.mat sd_96_11.mat sd_96_12.mat sd_96_13.mat sd_96_14.mat sd_96_15.mat sd_96_16.mat sd_96_2.mat sd_96_3.mat sd_96_4.mat sd_96_5.mat sd_96_6.mat sd_96_7.mat sd_96_8.mat sd_96_9.mat sd_128_1.mat sd_128_10.mat sd_128_11.mat sd_128_12.mat sd_128_13.mat sd_128_14.mat sd_128_15.mat sd_128_16.mat sd_128_2.mat sd_128_3.mat sd_128_4.mat sd_128_5.mat sd_128_6.mat sd_128_7.mat sd_128_8.mat sd_128_9.mat '];
filesParams{1} = 'params_data4C1.mat';

DataDirD{2} = 'datasets\real\'; %Input Directory real data
filesD{2} = ['lin-austria.mat '];
filesParams{2} = 'params_real_data4C2.mat';

DataDirD{3} = 'datasets\real\'; %Input Directory real data
filesD{3} = ['lin-budapest.mat '];
filesParams{3} = 'params_real_data4C2.mat';

DataDirD{4} = 'datasets\real\'; %Input Directory real data
filesD{4} = ['lin-delh.mat '];
filesParams{4} = 'params_real_data4C4.mat';

%filesD{1} = ['sd_16_1.mat '];

ResultsDirD = DataDirD;

for DATASET = 1:1
    stats = [];
    DataDir = DataDirD{DATASET};
    files = filesD{DATASET};
    ResultsDir = ResultsDirD{DATASET};
    apo = 1;
    s = find(isspace(files) == 1);
    data = cell(1, length(s));
    id = 1;
    j0 = 1;

    if LOAD_PARAMS == 1
        load(sprintf('%s%s%d', DataDir, filesParams{DATASET}));
    end

    for j = j0:length(s)
        eos = s(j);
        fname = files(apo:eos - 1)
        apo = eos + 1;
        load(sprintf('%s%s', DataDir, fname));
        imagePerRUN = j / length(s)

        for iter = 1:ITERATIONS

            if LOAD_PARAMS == 1
                [params] = getUserParamsClusters(Params{j}{iter}, LOAD_PARAMS, G.N, 8, iter)
            else
                [params] = getUserParamsClusters([], LOAD_PARAMS, G.N, 8, iter)
            end

            params.iter = iter;
            params.ITERATIONS = ITERATIONS;
            params.fname = fname;
            params.DistTimes = graphallshortestpaths(sparse(G.MinTimeEdges)); %time-distance matrix of all pair of nodes
            %Johnson's algorithm has a time complexity of O(N*log(N)+N*E), where N and E are the number of nodes and edges respectively.
            params.EXP_MAX = EXP_MAX;
            params.RUN_REMOVAL = RUN_REMOVAL;
            plotGraphClusters(G, sparse(G.MinTimeEdges), G.Points, G.RatingsNodes, G.RatingsEdges, G.MinTimeNodes, [], params);
            tic

            if ITMETHOD == 0 %proposed methods
                [It, params] = getSeqItSelectionExtraHist2(G, params, ITMETHOD, 40);
            elseif ITMETHOD <= 3 %proposed methods
                [It, params] = getSeqItSelection(G, params, ITMETHOD);
            end

            timerVal = toc
            params.timerVal = toc;
            plotGraphClusters(G, sparse(G.MinTimeEdges), G.Points, G.RatingsNodes, G.RatingsEdges, G.MinTimeNodes, It, params);
            params
            params.DistTimes = [];
            stats{j}{iter} = params;
        end

    end

    MEAN_OBJ = getMeanOBJ(stats);
    save(sprintf('RES//resRC_H40_data_%d_%d_%d_%d_%2.3f.mat', ITMETHOD, EXP_MAX, RUN_REMOVAL, DATASET, MEAN_OBJ), 'stats');

end
k
