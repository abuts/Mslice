function this=add_right(this,h,gap)
% Method adds list of graphical handles to the existing object collection
% from the right
%
% Modifys the location and the coordinates of the enclosing box accordingly
%
%   $Rev: 201 $ ($Date: 2011-11-24 17:30:22 +0000 (Thu, 24 Nov 2011) $)
%


if ~ishandle(h); return; end   

[h_exist,nh]= is_handle_exist(this,h);
if h_exist                                
     return                
else
     this.handles{nh+1}=h;
end  

    
position = get(h,'Position');            
new_position=[this.r_max(1),this.r_min(2),position(3),position(4)];
if exist('gap','var')
   new_position(1)=new_position(1)+gap;
end

set(h,'Position',new_position)
size= get(h,'Position');
width = size(3);
height= size(4);            
this.r_max(1)=size(1)+width;

if  this.r_max(2)<size(2)+size(4); 
    this.r_max(2)=size(2)+height;                
end

% do nice box;
for i=1:nh
    alighn = false;                
    pos = get(this.handles{i},'Position');
    if pos(3)~=width
       alighn = true;
       pos(3) = width;
    end
    if pos(4)~=height
       alighn = true;
       pos(4) = height;
    end
    if alighn 
       set(this.handles{i},'Position',pos);
    end                
end


