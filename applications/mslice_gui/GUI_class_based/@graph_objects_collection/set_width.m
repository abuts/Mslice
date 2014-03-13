function this=set_width(this,width,gap)
%
%   $Rev$ ($Date$)
%

nw = numel(width);
if ~exist('gap','var')
    gap = zeros(nw,1);
else
    if numel(gap)~=nw
        error('GRAPH_OBJECT_COLLECTION:set_width',' gap, if present has to have the same size as width')
    end
end
ic=1;
x1 =this.r_min(1);
for i=1:numel(this.handles)
    pos = get(this.handles{i},'Position');
    %
    pos(3) =width(ic);
    pos(1)= x1;                
    set(this.handles{i},'Position',pos);                                    
    % next x
    x1      = x1+width(ic)+gap(ic);
    x_max= x1;
    %
    ic=ic+1;
    if ic>nw
        ic=1;
        x1 =this.r_min(1);
    end
end
this.r_max(1) = x_max;

