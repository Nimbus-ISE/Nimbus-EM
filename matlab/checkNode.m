%It updates the path by adding the nodeAdd to the current path
%It also check for validity of the new path
function [newIt, error, BestFO, BestExpFO] = checkNode(G, params, nodeAdd, It, method)
    EXP_MAX = params.EXP_MAX;
    newIt = It;
    error = 0;
    BestFO = 0;
    BestExpFO = 0;

    if ~isempty(find(It == nodeAdd, 1)) %the given node belongs on the given itinerary
        error = 1;
        return;
    end

    NewSet = [It nodeAdd]; %Nodes of new itinerary
    nodeStart = params.nodeStart; %parameters
    nodeEnd = params.nodeEnd;
    timeStart = params.timeStart;
    timeEnd = params.timeEnd;
    AvCostUser = params.AvCostUser;

    if mean(G.AvCostNodes(NewSet)) > AvCostUser %the average cost is higher that the given user average
        error = 2;
        return;
    end

    DistTimes = params.DistTimes;
    %if ~isempty(It)
    %    [~,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,DistTimes,It,nodeStart,nodeEnd,timeStart,timeEnd);
    %    [BestFO,BestExpFO] = getObjectiveFunction(It,params.timeStart,params.timeEnd,visitTimeStart,visitTimeEnd,G.RatingsNodes);
    %end

    if method == 1 %very fast baseline method that uses the current It and only check for the N possible additions of the nodeAdd
        N = length(It);

        for i = 1:N + 1
            testIt(i) = nodeAdd;

            if i > 1 && i < N + 1
                testIt(1:i - 1) = It(1:i - 1);
                testIt(i + 1:N + 1) = It(i:N);
            elseif i == 1
                testIt(2:N + 1) = It(1:N);
            else
                testIt(1:i - 1) = It(1:i - 1);
            end

            [valid, visitTimeStart, visitTimeEnd] = isItineraryValid(G.OpenHours, G.MinTimeNodes, DistTimes, testIt, nodeStart, nodeEnd, timeStart, timeEnd);
            [f, fexp] = getObjectiveFunction(testIt, params.timeStart, params.timeEnd, visitTimeStart, visitTimeEnd, G.RatingsNodes, G.N, params.Nmin, params.Nmax, G.CategoriesNodes);

            if min(valid) == 1 && fexp > BestExpFO && EXP_MAX == 1
                newIt = testIt;
                BestFO = f;
                BestExpFO = fexp;
            elseif min(valid) == 1 && f > BestFO && EXP_MAX == 0
                newIt = testIt;
                BestFO = f;
                BestExpFO = fexp;
            end

        end

    elseif method == 2 %Exhaustive method
        N = length(It);
        It2 = It;
        It2(N + 1) = nodeAdd;
        P = perms(It2);

        for i = 1:size(P, 1)
            testIt = P(i, :);

            [valid, visitTimeStart, visitTimeEnd] = isItineraryValid(G.OpenHours, G.MinTimeNodes, DistTimes, testIt, nodeStart, nodeEnd, timeStart, timeEnd);
            [f, fexp] = getObjectiveFunction(testIt, params.timeStart, params.timeEnd, visitTimeStart, visitTimeEnd, G.RatingsNodes, G.N, params.Nmin, params.Nmax, G.CategoriesNodes);

            if min(valid) == 1 && fexp > BestExpFO && EXP_MAX == 1
                newIt = testIt;
                BestFO = f;
                BestExpFO = fexp;
            elseif min(valid) == 1 && f > BestFO && EXP_MAX == 0
                newIt = testIt;
                BestFO = f;
                BestExpFO = fexp;
            end

        end

    elseif method == 3 %Random method
        N = length(It);
        It2 = It;
        It2(N + 1) = nodeAdd;
        maxIter = min(100 + N ^ 2);

        for ite = 1:maxIter
            RP = randperm(length(It2));
            testIt = It2(RP);

            [valid, visitTimeStart, visitTimeEnd] = isItineraryValid(G.OpenHours, G.MinTimeNodes, DistTimes, testIt, nodeStart, nodeEnd, timeStart, timeEnd);
            [f, fexp] = getObjectiveFunction(testIt, params.timeStart, params.timeEnd, visitTimeStart, visitTimeEnd, G.RatingsNodes);

            if min(valid) == 1 && fexp > BestExpFO && EXP_MAX == 1
                newIt = testIt;
                BestFO = f;
                BestExpFO = fexp;
            elseif min(valid) == 1 && f > BestFO && EXP_MAX == 0
                newIt = testIt;
                BestFO = f;
                BestExpFO = fexp;
            end

        end

    end
