%It computes the Itinerary using Genetic Method [2]
%[2] Wibowo, B. S., & Handayani, M. (2018). A genetic algorithm for generating travel itinerary recommendation with restaurant selection. In 2018 IEEE International Conference on Industrial Engineering and Engineering Management (IEEM) (pp. 427-431). IEEE.
function [It,params] = getGA(G,params)
It = [];
for i=1:200
    try
        [It,params] = getGA2(G,params);
        break;
    catch
    
    end
end
  
function [It,params] = getGA2(G,params)

nodeStart = params.nodeStart; %parameters
nodeEnd = params.nodeEnd;
timeStart = params.timeStart;
timeEnd = params.timeEnd;
AvCostUser = params.AvCostUser;
DistTimes = params.DistTimes;
N = G.N;

%parameters 
MaxIters = 500;
PopSize = 46;
Rate_crossover = 0.72;
Rate_mutation = 0.27;%0.27;
GIT = [];
%Initialization
for i=1:PopSize
    It = [];
    idle = 0;

    for j=1:5*N
        if length(It) == N || idle > 2*N
            break;
        end
        
        pos = setdiff([1:N],It);
        n = randi(length(pos));
        nodeAdd = pos(n);
        testIt = [It nodeAdd];
        if mean(G.AvCostNodes(testIt)) > AvCostUser
            idle = idle+1;
            continue;
        end
        [valid,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,DistTimes,testIt,nodeStart,nodeEnd,timeStart,timeEnd);
        if min(valid) < 1
            idle = idle+1;
            continue;
        else
            idle = 0;
            It = testIt;
        end
    end
    [f,fexp] = getObjectiveFunction(It,params.timeStart,params.timeEnd,visitTimeStart,visitTimeEnd,G.RatingsNodes,G.N,params.Nmin,params.Nmax,G.CategoriesNodes);
    GIT{i}.It = It;
    GIT{i}.f = f;
    prop(i) = f;
end
[BestFO,pos] = max(prop);
BestFO
BestIt = GIT{pos}.It;
[GIT,prop,cprop,~] = sortPop(GIT);
%Crossover and Mutation
for ite=1:MaxIters
      
      % Perform Elitism, that mean 10% of fittest population
      % goes to the next generation
      s1 = round((1-Rate_crossover)*PopSize);
      NGIT = [];
      for i=1:s1
          NGIT{i} = GIT{i};
      end
      %Crossover
      for i=s1+1:PopSize
          nite = 0;
          while 1
              nite = nite+1;
              r = rand;
              pos = find(cprop >= r);
              parent1 = pos(1);
              r = rand;
              pos = find(cprop >= r);
              parent2 = pos(1);
              if parent1 ~= parent2
                  break;
              elseif nite > 10000
                  break;
              end
          end
          if parent1 ~= parent2
            NGIT = getCrossover(G,params,GIT,parent1,parent2,i);
          end
      end
      
    % rand < Rate_crossover %Crossover
    %mutation code 
    for i=1:round(Rate_mutation*PopSize)
        nodeAdd = randi(N);%random location
        id = randi(PopSize);%path 
        testIt = NGIT{id}.It;
        pos = find(testIt == nodeAdd);
        if isempty(pos)
            [newIt,error,f,~] = checkNode(G,params,nodeAdd,testIt,1);
            if error == 0
                NGIT{id}.It = newIt;
                NGIT{id}.f = f;
            end
        else
            newIt = testIt(testIt ~= id);
            [valid,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,DistTimes,newIt,nodeStart,nodeEnd,timeStart,timeEnd);
            if min(valid) == 1
                [f,~] = getObjectiveFunction(newIt,params.timeStart,params.timeEnd,visitTimeStart,visitTimeEnd,G.RatingsNodes,G.N,params.Nmin,params.Nmax,G.CategoriesNodes);
                NGIT{id}.It = newIt;
                NGIT{id}.f = f;
            end
        end
    end
    [GIT,prop,cprop,BestFO1(ite)] = sortPop(NGIT);
    [~,pos1] = max(prop);
    if BestFO1(ite) > BestFO
        BestFO = BestFO1(ite);
        BestIt = GIT{pos1}.It;
        idle = 0;
    else
        idle = idle+1;
    end
    if idle > MaxIters/2
        break;
    end
end

[valid,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,DistTimes,BestIt,nodeStart,nodeEnd,timeStart,timeEnd);
params.BestFO = BestFO;
params.visitTimeStart = visitTimeStart;
params.visitTimeEnd = visitTimeEnd;
params.It = BestIt;
BestFO
%figure; plot(BestFO1);

%Sort the population according to fitness function 
function [SGIT,prop,cprop,BestFO] = sortPop(GIT)

N = length(GIT);
prop = zeros(1,N);
for i=1:N
    prop(i) = GIT{i}.f;
end
[prop,pos] = sort(prop,'descend');
BestFO = prop(1);
SGIT = [];
for i=1:N
    SGIT{i} = GIT{pos(i)};
end
prop = prop/sum(prop);
cprop = cumsum(prop);

function [NGIT] = getCrossover(G,params,GIT,parent1,parent2,id)
It1 = GIT{parent1}.It;
It2 = GIT{parent2}.It;
newIt = [];
NGIT = GIT;
fb = 0;
for i=1:max(length(It1),length(It2))
    p = rand;
    if p < 0.5 && i <= length(It1)
        nodeAdd = It1(i);
        [testIt,error,f,~] = checkNode(G,params,nodeAdd,newIt,1);
        if error == 0
            newIt = testIt;
            fb = f; 
        end
    elseif p > 0.5 && i <= length(It2)
        nodeAdd = It2(i);
        [testIt,error,f,~] = checkNode(G,params,nodeAdd,newIt,1);
        if error == 0
            newIt = testIt;
            fb = f;
        end
    end
end

NGIT{id}.It = newIt;
NGIT{id}.f = fb;


