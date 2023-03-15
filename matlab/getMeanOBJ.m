%Gets the average value of the Objective Function
function [MEAN_OBJ] = getMeanOBJ(stats)

vec = [];
for i=1:length(stats)
    for j=1:length(stats{i})
        vec(i,j) = stats{i}{j}.BestFO;
    end
end
MEAN_OBJ = mean(vec(:));

%figure;
%bar(vec);

