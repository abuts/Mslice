function this=add_bottom(this,h,gap)
% Method adds list of graphical handles to the existing object collection
% from the biottom of the current box
%
% Modifys the location and the coordinates of the enclosing box accordingly
%
%   $Rev: 201 $ ($Date: 2011-11-24 17:30:22 +0000 (Thu, 24 Nov 2011) $)
%


if ~ishandle(h); return; end                           
    
[h_exist,nh] = is_handle_exist(this,h);
if h_exist                                
   return                
else
   this.handles{nh+1}=h;
end

position = get(h,'Position');
new_position=[this.r_min(1),this.r_min(2)-position(4),position(3),position(4)];
if exist('gap','var')
   new_position(2)=new_position(2)-gap;
end

set(h,'Position',new_position)
this.r_min(2)=new_position(2);

