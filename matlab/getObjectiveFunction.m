%The Objective Function of a legal tour It
%visitTimeStart(i),visitTimeEnd(i) show the start and end times of visiting PoI
%It(i) 
%f: objective function
%f_Exp: expected value of f
function [f,f_Exp,c,f0] = getObjectiveFunction(It,timeStart,timeEnd,visitTimeStart,visitTimeEnd,RatingsNodes,N,Nmin,Nmax,Cat)

f = 0;
dp = 0;
for i=1:length(It)
    dp = dp+visitTimeEnd(i) - visitTimeStart(i);
    f = f+(visitTimeEnd(i) - visitTimeStart(i))*RatingsNodes(It(i));
end
%e = 0.01;
%f = f-e*(visitTimeEnd(length(It)) - timeStart-dp);
f = f*log(1+length(It))/(log(1+N)*(timeEnd-timeStart));
f0 = f;

NR = 0*Nmin;
for i=1:length(It)
    NR(Cat(It(i))) = NR(Cat(It(i)))+1;
end

%categories

c = zeros(1,3);
c(1) = length(find(NR >= Nmin & NR <= Nmax));
pos_c2 = find(NR < Nmin);
if ~isempty(pos_c2)
    c(2) = sum((NR(pos_c2)./Nmin(pos_c2)));
end

pos_c3 = find(NR > Nmax);
if ~isempty(pos_c3)
    c(3) = sum((Nmax(pos_c3)./NR(pos_c3)).^2);
end

NC = length(Nmin);
cat = sum(c)/(NC+1);
fr = f;
f = cat+(fr/(NC+1)); %Objective function f


LT = (timeEnd-timeStart) / (visitTimeEnd(length(It))-timeStart);
fr_exp = fr*LT;
fc_exp = cat - (c(2)/(NC+1)) + min(length(pos_c2), LT*c(2)) / (NC+1);

f_Exp = fr_exp+fc_exp;%expected value of f


