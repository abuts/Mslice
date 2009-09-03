function [u,mess,unchanged]=make_ebins(uin,en)
% Fill energy bins doing sensible things if zero bin size requested, and/or limits missing
% - uin         Bin size or [start,step,stop]
% - en          Energy bin centres
%
% - u           New bin descriptor
% - mess        Message; empty if no problems
% - unchanged   =true if u==uin

u=uin;
mess='';
if numel(uin)==1 && uin==0    % just energy bin size
    if numel(en)>1
        u=[en(1),en(2)-en(1),en(end)];
    else
        mess='Only one energy bin in spe file - must give energy step along energy cut';
    end
    
elseif numel(uin)==1
    u=[en(1),uin,en(end)];
    
elseif numel(uin)==3 && uin(2)==0
    if numel(en)>1
        ind=find(en>=uin(1)&en<=uin(3));
        if ~isempty(ind)
            u=[en(ind(1)),en(2)-en(1),en(ind(end))];
        else
            mess='Check limits for energy cut';
        end
    else
        mess='Only one energy bin in spe file - must give energy step along energy cut';
    end
end

if isequal(u,uin)
    unchanged=true;
else
    unchanged=false;
end
