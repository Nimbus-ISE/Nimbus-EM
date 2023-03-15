%Sets the parameters of the problem (start node, End node, etc)
function [params] = getUserParamsClusters(Params,LOAD_PARAMS,N,Cat,iter)

params = [];
%params.validSet = [];
params.BestFO = 0;
x = rem(iter,4)+1;
%x = 3;
if x == 1  %Nmax = Nmin Hard
    Nmin = randi(3,Cat,1)-1; %[0 1 2]
    Nmax = Nmin;
elseif x == 2 % semi flexible
    Nmin = randi(3,Cat,1)-1; %[0 1 2]
    Nmax = max(1,Nmin);
elseif x == 3 %flexible
    Nmin = randi(3,Cat,1)-1; %[0 1 2]
    Nmax = Nmin+randi(3,Cat,1);
elseif x == 4  %no categories
    Nmin = 0*randi(3,Cat,1); %[0 ]
    Nmax = 100+0*randi(3,Cat,1); %[100]
end

if LOAD_PARAMS == 0 && isempty(Params)  %default 
    params.nodeStart = 7;
    params.nodeEnd = 13;
    params.timeStart = 10;
    params.timeEnd = 18;
    params.AvCostUser = 10;%2
   % Nmin = 0*Nmin;
   % Nmax = 0*Nmin+100;
   % Nmin(1) = 2;
   % Nmax(1) = 2;
    params.Nmin = Nmin;
    params.Nmax = Nmax;
    params.Ntype = x;
elseif LOAD_PARAMS == -1 && isempty(Params) %random
    params.nodeStart = randi(N);
    params.nodeEnd = randi(N);
    params.timeStart = 9;
    params.timeEnd = 9+4+randi(5);
    params.AvCostUser = 10;%2
    params.Nmin = Nmin;
    params.Nmax = Nmax;
    params.Ntype = x;
elseif ~isempty(Params)%given 
    params.nodeStart = Params.nodeStart;
    params.nodeEnd = Params.nodeEnd;
    params.timeStart = Params.timeStart;
    params.timeEnd = Params.timeEnd;
    params.AvCostUser = Params.AvCostUser;
    params.Nmin = Params.Nmin;
    params.Nmax = Params.Nmax;
    params.Ntype = Params.Ntype;
end

