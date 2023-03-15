%it yields the percetange of time that the PoI is open. 
function [per] = isOpen(OpenHours,visitTimeStart,visitTimeEnd) 

vec = [visitTimeStart:0.02:visitTimeEnd];
k = 0;
for i=1:length(vec)
    t = vec(i);
   for j=1:size(OpenHours,1)
       t1 = OpenHours(j,1);
       t2 = OpenHours(j,2);
       if t >= t1 && t <= t2
        k = k+1;
       end
   end
end

per = min(1,k/length(vec));