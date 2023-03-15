%It computes the Itinerary using Quercia Method [1]
%[1] Quercia D, Schifanella R, Aiello LM (2014) The shortest path to happiness: recommending beautiful, quiet, and happy routes in the city. In: Proc. of HT’14, pp 116–125
function [It,params] = getQuerciaMethod(G,params)
addpath('..\kShortestPath_Yen');
nodeStart = params.nodeStart; %parameters
nodeEnd = params.nodeEnd;
timeStart = params.timeStart;
timeEnd = params.timeEnd;
AvCostUser = params.AvCostUser;
DistTimes = params.DistTimes;



BestvisitTimeStart = timeStart;
BestvisitTimeEnd = timeStart;
M = G.N^2;

k = G.N^2
params.M = M;
params.M = k;

netCostMatrix = G.MinTimeEdges;
netCostMatrix(netCostMatrix == 0) = inf;
[shortestPaths, ~] = kShortestPath(netCostMatrix, params.nodeStart, params.nodeEnd, M);

BestFO = 0;
BestExpFO = 0;
newIt = [];
id = 0;
iter = 0;
while id < M
    BestFOPrev = BestFO;
    iter = iter+1;
    for i=1:k
        id = id+1;
        testIt0 = shortestPaths{id};
        
        for apo=1:2
            for eos=length(testIt0)-1:length(testIt0)
                if apo >= eos
                    continue;
                end
                testIt = testIt0(apo:eos);
                if mean(G.AvCostNodes(testIt)) > AvCostUser
                    continue;
                end
                [valid,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,DistTimes,testIt,nodeStart,nodeEnd,timeStart,timeEnd);
                
                if min(valid) == 1
                    [f,fexp] = getObjectiveFunction(testIt,params.timeStart,params.timeEnd,visitTimeStart,visitTimeEnd,G.RatingsNodes,G.N,params.Nmin,params.Nmax,G.CategoriesNodes);
                    if f > BestFO
                        newIt = testIt;
                        BestFO = f;
                        BestExpFO = fexp;
                        BestvisitTimeStart = visitTimeStart;
                        BestvisitTimeEnd = visitTimeEnd;
                    end
                elseif length(valid) >= 3 && max(valid(1:length(testIt)-1)) == 1
                    testIt = testIt(valid(1:length(testIt)-1) == 1);
                    [valid,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,DistTimes,testIt,nodeStart,nodeEnd,timeStart,timeEnd);
                    if min(valid) == 1
                        [f,fexp] = getObjectiveFunction(testIt,params.timeStart,params.timeEnd,visitTimeStart,visitTimeEnd,G.RatingsNodes,G.N,params.Nmin,params.Nmax,G.CategoriesNodes);
                        
                        if f > BestFO
                            newIt = testIt;
                            BestFO = f;
                            BestExpFO = fexp;
                            BestvisitTimeStart = visitTimeStart;
                            BestvisitTimeEnd = visitTimeEnd;
                        end
                    end
                end
            end
        end
    end
    if (BestFO-BestFOPrev)/k < BestFO/id
        %iter
        %break;
    end
end
It = newIt;
params.BestFO = BestFO;
params.BestExpFO = BestExpFO;
params.visitTimeStart = BestvisitTimeStart;
params.visitTimeEnd = BestvisitTimeEnd;
params.It = newIt;


