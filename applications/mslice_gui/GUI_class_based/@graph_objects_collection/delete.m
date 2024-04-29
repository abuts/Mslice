function this=delete(this)
% Method clears all object present in the class and invalidate the collection box
%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%

for i=1:numel(this.handles)
    if ishandle(this.handles{i})
        delete(this.handles{i});
    end
end

this.handles={};
this.r_min  = [ 1.e+32, 1.e+32];
this.r_max  = [-1.e+32,-1.e+32];            
    
