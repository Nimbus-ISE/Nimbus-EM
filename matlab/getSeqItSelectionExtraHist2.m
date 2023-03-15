%It computes the Itinerary using a Sequential Itinerary Creation
%method
function [It,params] = getSeqItSelectionExtraHist2(G,params,method,HSIZE)
EXP_MAX = params.EXP_MAX;
RUN_REMOVAL = params.RUN_REMOVAL;
HITBestFO = zeros(HSIZE,1);
HITBestExpFO = zeros(HSIZE,1);
BestIt = [];
for k=1:HSIZE
    HIT{k} = [];
end
N = size(G.RatingsNodes,1);
SETs0 = [1:HSIZE];
change = 0;
for ite0=1:1 %%%_change to N
    for ite=1:N*HSIZE                     %N is max size of path
       % HSIZE_C(ite) = length(SETs0);
               
        if isempty(SETs0)
            break;
        end
        
        [~,pos11] = min(HITBestFO(SETs0));
        [~,pos12] = min(HITBestExpFO(SETs0));
        if EXP_MAX == 1
            s0 = pos12(1);
        else
            s0 = pos11(1);
        end
        
        %s0 = 1+rem(ite,length(SETs0));%????
        It = HIT{SETs0(s0)};
        Set = setdiff([1:N],It);    %candicate nodes for visiting
        change = 0;
        BestExpFO1 = 0;
        BestFO1 = 0;
        
        for i=1:length(Set)
            nodeAdd = Set(i);
            [newIt,~,f,fexp] = checkNode(G,params,nodeAdd,It,method+1);
            if f == 0 || fexp == 0
                continue;
            end
            [eq] = checkEQ(HIT,newIt,HSIZE);
            if eq == 1
                continue;
            end
            
            if fexp > BestExpFO1 && EXP_MAX == 1
                BestIt = newIt;
                BestExpFO1 = fexp;
                BestFO1 = f;
            elseif f > BestFO1 && EXP_MAX == 0
                BestIt = newIt;
                BestExpFO1 = fexp;
                BestFO1 = f;
            end
        end
                
        [BestFO,pos1] = min(HITBestFO);
        [BestExpFO,pos2] = min(HITBestExpFO);
        if EXP_MAX == 1
            pos = pos2(1);
        else
            pos = pos1(1);
        end
                
        if BestExpFO1 > BestExpFO && EXP_MAX == 1
         %   [eq] = checkEQ(HIT,BestIt,HSIZE);
         %   if eq == 1
         %       continue;
         %   end
            
            BestFO = BestFO1;
            BestExpFO = BestExpFO1;
            change = 1;
            
            HIT{pos} = BestIt;
            HITBestExpFO(pos) = BestExpFO;
            HITBestFO(pos) = BestFO;
            SETs0 = union(SETs0,pos);
        elseif BestFO1 > BestFO && EXP_MAX == 0
          %  if eq == 1
          %      continue;
          %  end
            BestFO = f;
            BestExpFO = fexp;
            BestIt = newIt;
            change = 1;
            
            HIT{pos} = BestIt;
            HITBestExpFO(pos) = BestExpFO;
            HITBestFO(pos) = BestFO;
            SETs0 = union(SETs0,pos);
        else
            SETs0 = setdiff(SETs0,SETs0(s0));
            continue;
        end
    end
    
    if RUN_REMOVAL == 1  %REMOVAL STAGE (OPTIONAL)
        for ite=1:N
            [~,k] =  max(HITBestFO);
            BestFO = HITBestFO(k);
            BestExpFO = HITBestExpFO(k);
            change = 0;
            for k=1:HSIZE
                It = HIT{k};
                Set = setdiff([1:N],It);
                if length(It) > 1
                    for i=1:length(It)
                        testIt = It(setdiff([1:length(It)],i));
                        for j=1:length(Set)
                            nodeAdd = Set(j);
                            [newIt,~,f,fexp] = checkNode(G,params,nodeAdd,testIt,method+1);
                            
                            
                            if f > BestFO 
                                BestFO = f;
                                BestExpFO = fexp;
                                BestIt = newIt;
                                change = 2;
                            end
                        end
                    end
                    if change == 2
                        HIT{k} = BestIt;
                        HITBestExpFO(k) = BestExpFO;
                        HITBestFO(k) = BestFO;
                    end
                end
            end
            if change == 0
                break;
            end
        end
    end
    if change == 0
        break;
    end
end

[BestFO,pos] = max(HITBestFO);
It = HIT{pos};
params.BestFO = BestFO;
params.BestExpFO = HITBestExpFO(pos);
params.HSIZE = HSIZE;

[~,visitTimeStart,visitTimeEnd] = isItineraryValid(G.OpenHours,G.MinTimeNodes,params.DistTimes,It,params.nodeStart,params.nodeEnd,params.timeStart,params.timeEnd);
params.visitTimeStart = visitTimeStart;
params.visitTimeEnd = visitTimeEnd;
params.It = It;


function [eq] = checkEQ(HIT,newIt,HSIZE)

eq = 0;
for k=1:HSIZE
    v1 = HIT{k};
    v2 = newIt;
    if isequal(v1,v2) == 1
        eq = 1;
        break;
    end
end

