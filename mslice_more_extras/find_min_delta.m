function [dx_min,dy_min] = find_min_delta( range,grid )
% function finds minimal x and y width of 2D greed img_grid 
%
%Usage:
%>>[dx_min,dy_min] =find_min_delta( img_range,img_grid );
%Inputs:
%img_range  -- structure with fields vx_min,vx_max,vy_min,vy_max which
%              define the range where min and max grid width have to be
%              determined
% img_grid  -- 2D grid array in the form  (:,x_i,x_(i+1),y_i,y_(i+1))
%              this array usually determines the mslice polygons; 
%
%
%  $Revision: 57 $   ($Date: 2010-01-08 17:22:35 +0000 (Fri, 08 Jan 2010) $)
%
gr_size= size(grid);
grid=reshape(grid,gr_size(1)*gr_size(2),gr_size(3));
r_out = (grid(:,1)<range.vx_min)&(grid(:,3)>range.vx_max)& ...
        (grid(:,2)<range.vy_min)&(grid(:,4)>range.vy_max);

grid(r_out,:)=NaN;

dx=grid(:,3)-grid(:,1);
dy=grid(:,4)-grid(:,2);

dx_min=min(dx);
dy_min=min(dy);

