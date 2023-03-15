% It check if is a given Itinerary is valid according t time constraints
% (OpenHours,timeEnd)
% valid: vector of N+1 size that is 1 if It(i) is ok to be visited according t time constraints 
% It(N+1)-> nodeEnd
%duration: total time duration of the Itinerary
function [valid,visitTimeStart,visitTimeEnd] = isItineraryValid(OpenHours,MinTimeNodes,DistTimes,It,nodeStart,nodeEnd,timeStart,timeEnd)

valid = zeros(1,length(It)+1);
visitTimeStart = zeros(1,length(It)+1);
visitTimeEnd = zeros(1,length(It)+1);

t = timeStart+DistTimes(nodeStart,It(1));
for i=1:length(It)
    visitTimeStart(i) = t;
    t = t+MinTimeNodes(It(i));
    visitTimeEnd(i) = t;
    if i < length(It)
        t = t+DistTimes(It(i),It(i+1));
    else
        t = t+DistTimes(It(i),nodeEnd);
    end
    if isOpen(OpenHours{It(i)},visitTimeStart(i),visitTimeEnd(i)) < 0.95
        valid(i) = -1;
    else
        valid(i) = 1;
    end
end
visitTimeStart(length(It)+1) = t;%endnode
visitTimeEnd(length(It)+1) = t;
%duration = visitTimeEnd(length(It)+1) - timeStart;

if visitTimeEnd(length(It)+1) > timeEnd
    valid(length(It)+1) = -1;
else
    valid(length(It)+1) = 1;
end

end

