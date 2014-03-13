function this=delete(this)
% Method clears all object present in the class and invalidate the collection box
%
%   $Rev: 201 $ ($Date: 2011-11-24 17:30:22 +0000 (Thu, 24 Nov 2011) $)
%

for i=1:numel(this.handles)
    if ishandle(this.handles{i})
        delete(this.handles{i});
    end
end

this.handles={};
this.r_min  = [ 1.e+32, 1.e+32];
this.r_max  = [-1.e+32,-1.e+32];            
    
