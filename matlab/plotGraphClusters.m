%plots the Graph and the proposed Itinerary (path)

function [ok] = plotGraphClusters(G,A,Points,RatingsNodes,RatingsEdges,MinTimeNodes,path,params)
ok = 1;
global toPlot
if toPlot == 0
    return;
end
Cat = G.CategoriesNodes;


fig1 = figure;

cmap = jet(256);
M = 1;
DX = max(Points(:,1))-min(Points(:,1));
path
for i=1:size(A,1)
    for j=1:size(A,2)
        if A(i,j) > 0
            %u = max(1,round(256*RatingsEdges(i))/M);
         %   plot([Points(i,1) Points(j,1)],[Points(i,2) Points(j,2)],'b','LineWidth',1);
            hold on;
        end
    end
end
for i=1:size(Points,1)
    u = max(1,round(256*RatingsNodes(i)/M));
    x = 8+round(12*MinTimeNodes(i)/max(MinTimeNodes));
    plot(Points(i,1),Points(i,2),'o','MarkerFaceColor',cmap(u,:),'MarkerEdgeColor',cmap(u,:),'MarkerSize',x,'LineWidth',1);
    hold on;
    text(Points(i,1)+0.015*DX,Points(i,2),sprintf('%d (c%d)',i,Cat(i)),'fontsize',17);
    hold on;
end

Nmin = params.Nmin;
Nmax = params.Nmax;
for i=1:length(Nmin)
    str{i} = sprintf('c%d: [%d %d]',i,Nmin(i),Nmax(i));
end
text(1,15,str,'FontSize',14);
%if ~isempty('params.validSet')
%    vSet = params.validSet;
%    for i1=1:length(vSet)
%        i = vSet(i1);
%        hold on;
%        text(Points(i,1)+0.015*DX,Points(i,2),sprintf('%d',i),'Color','red');
%        hold on;
%    end
%end

if ~isempty(path)
    nodeStart =  params.nodeStart;
    nodeEnd = params.nodeEnd;
    
    i = nodeStart; %draw startPoint 
    plot(Points(i,1),Points(i,2),'o','MarkerFaceColor',[1 1 1],'MarkerSize',8); 
    hold on;
    %text(Points(i,1)-0.03*DX,Points(i,2)+0.015*DX,sprintf('Start'));
    hold on;
    i = nodeEnd; %draw endPoint 
    plot(Points(i,1),Points(i,2),'o','MarkerFaceColor',[1 1 1],'MarkerSize',8);
    hold on;
    %text(Points(i,1)+0.015*DX,Points(i,2)+0.015*DX,sprintf('End'));
   
    
    path0 = [nodeStart path nodeEnd]; 
    for i=1:length(path0)-1  %draw the whole path 
        i1 = path0(i);
        i2 = path0(i+1);
        [~,lp,~] = graphshortestpath(A,i1,i2);
        for j=1:length(lp)-1
            p1 = lp(j);
            p2 = lp(j+1);
            plot([Points(p1,1) Points(p2,1)],[Points(p1,2) Points(p2,2)],'r','LineWidth',2);
            hold on;
            quiver(Points(p1,1),Points(p1,2),Points(p2,1)-Points(p1,1),Points(p2,2)-Points(p1,2),0.5,'r','LineWidth',2,'MaxHeadSize',0.5);
            hold on;
        end
        hold on;
    end
    
     hold on;
    for i=1:length(path)  %draw the visited PoI
        i1 = path(i);
        u = max(1,round(256*RatingsNodes(i1)/M));
        x = 8+round(12*MinTimeNodes(i1)/max(MinTimeNodes));
        %plot(Points(i1,1),Points(i1,2),'o','MarkerFaceColor',[1 1 1],'MarkerSize',5);
        plot(Points(i1,1),Points(i1,2),'o','MarkerFaceColor',cmap(u,:),'MarkerEdgeColor',[0 0 0],'MarkerSize',x,'LineWidth',3);
        hold on;
    end
    hold on;
    
    ptext = sprintf('(%d), ',path);
        
    if params.BestFO > 0
        title(sprintf('Time = [%2.2f:%2.2f] (%d->%s->%d) FO = %2.2f',params.timeStart,params.timeEnd,params.nodeStart,ptext,params.nodeEnd,params.BestFO));
    end
    [~,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,params.DistTimes,path,params.nodeStart,params.nodeEnd,params.timeStart,params.timeEnd);
    visitTimeStart
    visitTimeEnd
    Dur = ([params.timeStart visitTimeEnd] - [params.timeStart visitTimeStart])*60;
    X = [params.timeStart visitTimeStart;];
    [X1,~,~] = convertToMinute(X);
    X = [params.timeStart visitTimeEnd];
    [X2,~,~] = convertToMinute(X);
    
    D0 = [path0; X1; X2; Dur]';
    D = sprintfc('%5.2f', D0);
    
    for i=1:size(D,1) 
       D{i,1} = sprintf('%5.0f', D0(i,1)); 
       D{i,4} = sprintf('%5.0f', D0(i,4)); 
       D{i,5} = sprintf('%5.2f', G.RatingsNodes(path0(i))); 
       D{i,6} = sprintf('%5.2f', (1/60)*Dur(i)*G.RatingsNodes(path0(i))); 
    end
    totalGain = sum((1/60)*Dur'.*G.RatingsNodes(path0))*log(1+length(path))
    fig = uifigure;
    uit = uitable(fig,'Data',D,'fontsize',16);
    uit.ColumnName = {'POI','Time-Start','Time-End','Duration','Rec','Gain'};
    uit.ColumnWidth = {50};
end

set(gca,'fontsize',16)