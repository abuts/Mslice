function [r_min,r_max,this]=find_min_max(this,handles,not_reset_class_min_max)
% method to find min-max screen values of the object group. 
%
%
%   $Rev$ ($Date$)
%

if ~iscell(handles)
        error('GRAPH_OBJECT_COLLECTION:find_min_max',' input argument has to be cellarray of handles');
end
r_min = [ 1.e+32, 1.e+32];
r_max = [-1.e+32,-1.e+32];                   
for i=1:numel(handles)
    if isempty(handles{i})||~ishandle(handles{i}); continue; end
        
    pos = get(handles{i},'Position');
    rmi = pos(1:2);
    rma = pos(1:2)+pos(3:4);
    for j=1:2
        if (rmi(j) < r_min(j)); r_min(j)=rmi(j); end
        if (rma(j) > r_max(j)); r_max(j)=rma(j); end                        
    end
end
if exist('not_reset_class_min_max','var')
   return;
else
   for j=1:2
      if (this.r_min(j) < r_min(j)); r_min(j) = this.r_min(j); end
      if (this.r_max(j) > r_max(j)); r_max(j) = this.r_max(j); end                        
   end                
   this.r_min = r_min;
   this.r_max = r_max;                
end

  