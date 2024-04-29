function this=add_bottom(this,h,gap)
% Method adds list of graphical handles to the existing object collection
% from the biottom of the current box
%
% Modifys the location and the coordinates of the enclosing box accordingly
%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
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

