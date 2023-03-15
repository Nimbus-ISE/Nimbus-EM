%It computes the Itinerary using a Sequential Itinerary Creation
%method 
function [It,params] = getSeqItSelection(G,params,method)
EXP_MAX = params.EXP_MAX;
RUN_REMOVAL = params.RUN_REMOVAL;

BestIt = [];
It = [];  %final Itinerary
N = size(G.RatingsNodes,1);
BestExpFO = 0; %Expected Gain
BestFO = 0;
change = 0;
for ite0=1:N %%%_change to N
    for ite=1:N                     %N is max size of path
        fsave = [];
        fsaveexp = [];
        Set = setdiff([1:N],It);    %candicate nodes for visiting
        %Set
        %It
        first = 0;
        change = 0;
        for i=1:length(Set)
            nodeAdd = Set(i);
            [newIt,~,f,fexp] = checkNode(G,params,nodeAdd,It,method);
            fsave(i) = f;
            fsaveexp(i) = fexp;
            if first == 0 && f > BestFO && EXP_MAX == 1
                first = 1;
                BestFO = f;
                BestExpFO = fexp;
                BestIt = newIt;
                change = 1;
            elseif fexp > BestExpFO && EXP_MAX == 1
                BestFO = f;
                BestExpFO = fexp;
                BestIt = newIt;
                change = 1;
            elseif f > BestFO && EXP_MAX == 0
                BestFO = f;
                BestExpFO = fexp;
                BestIt = newIt;
                change = 1;
            end
        end
        
        if change == 0
            break;
        end
        It = BestIt;
    end
    
    if RUN_REMOVAL == 1  %REMOVAL STAGE (OPTIONAL)
        for ite=1:1
            change = 0;
            Set = setdiff([1:N],It);
            if length(It) > 1
                for i=1:length(It)
                    testIt = It(setdiff([1:length(It)],i));
                    for j=1:length(Set)
                        nodeAdd = Set(j);
                        [newIt,~,f,fexp] = checkNode(G,params,nodeAdd,testIt,method);
                        if f > BestFO && EXP_MAX == 1
                            BestFO = f;
                            BestExpFO = fexp;
                            BestIt = newIt;
                            change = 2
                        elseif f > BestFO && EXP_MAX == 0
                            BestFO = f;
                            BestExpFO = fexp;
                            BestIt = newIt;
                            change = 2
                        end
                    end
                end
            end
            if change == 0
                break;
            end
            It = BestIt;
        end
    end
    if change == 0
        break;
    end
end
params.BestFO = BestFO;
params.BestExpFO = BestExpFO;

[~,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,params.DistTimes,It,params.nodeStart,params.nodeEnd,params.timeStart,params.timeEnd);
params.visitTimeStart = visitTimeStart;
params.visitTimeEnd = visitTimeEnd;
params.It = It;
