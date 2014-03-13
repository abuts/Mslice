function [dx_min,dy_min] = find_min_delta( range,grid,u)
% function finds minimal x and y width of 2D greed img_grid 
%
%Usage:
%>>[dx_min,dy_min] =find_min_delta( img_range,img_grid );
%Inputs:
%img_range  -- structure with fields vx_min,vx_max,vy_min,vy_max which
%              define the range where min and max grid width have to be
%              determined
% grid      -- mslice data, containing the grid
%              Unfortunately we have to provide the u too, as the grid
%              is formed differently depending on u field. 
%              for the direction, where u==1, data step is stored in second            
%              next indexes, for all other cases, it in the last
%              intermittent by 2 indexes (:,:,3)-(:,:,1) or (:,:,4)-(:,:,2)
% u         -- mslice data field, describing axis ordering
%
%
%  $Revision: 57 $   ($Date: 2010-01-08 17:22:35 +0000 (Fri, 08 Jan 2010) $)
%
gr_size= size(grid);
grid=reshape(grid,gr_size(1)*gr_size(2),gr_size(3));
r_out = (grid(:,1)<=range.vx_min)&(grid(:,3)>range.vx_max)& ...
        (grid(:,2)<=range.vy_min)&(grid(:,4)>range.vy_max);

grid(r_out,:)=NaN;
clear r_out;
if u(1)==1
    grid=reshape(grid,gr_size);
    dx=grid(:,2:end,1)-grid(:,1:end-1,1);    
    dx=reshape(dx,gr_size(1)*(gr_size(2)-1),1);    
    grid=reshape(grid,gr_size(1)*gr_size(2),gr_size(3));    
else
    dx=grid(:,3)-grid(:,1);
end
dx_min=min(dx);
clear dx;

if u(2)==1
   grid=reshape(grid,gr_size);    
   dy  =grid(:,2:end,2)-grid(:,1:end-1,2);    
   dy  = reshape(dy,gr_size(1)*(gr_size(2)-1),1);       
else
   dy=grid(:,4)-grid(:,2);    
end
dy_min=min(dy);

