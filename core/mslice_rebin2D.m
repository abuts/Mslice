function [X,Y,Z] = mslice_rebin2D(data,img_range)
% function does 2-dimensional centerpoint rebinning of mslice data 
% on a square grid in the range specified by the second
% argument. Tested on crystal rebinned as powder. 
%
% Input parameters:
% Data -- mslice data structure. 
% Procedure uses data fields:
% S   -- [npix,ne] signal array.
% V   -- [npix,ne] the centerpoints of the detectors projections into
%                   selected coordinate system
% img_range:
%                   structure with fields:
%: vx_min, vx_max -- min and max X values for interpolation region
%: vy_min, vy_max -- min and max Y values for interpolation region
%: dx_step,dy_step -- steps of the interpolation grid in x and y directions
%: dx_step_min, dy_step_min -- min detector sized (not used currently)
%
%
%  $Revision: 57 $   ($Date: 2010-01-08 17:22:35 +0000 (Fri, 08 Jan 2010) $)
% 


dx = img_range.dx_step;
dy = img_range.dy_step;
% estimate the size of the interpolation grid;
DVX  = img_range.vx_max-img_range.vx_min;
DVY  = img_range.vy_max-img_range.vy_min;
n_dx = floor(DVX/dx)+1;
n_dy = floor(DVY/dy)+1;
dx   = DVX/(n_dx-1); % make the step precise to cover the whole range;
dy   = DVY/(n_dy-1);

% get the detectors centres:
RX  = data.v(:,:,1);
RY  = data.v(:,:,2);

% select the one, contributing into the range
valid= (RX>=img_range.vx_min)&(RX<=(img_range.vx_max))& ...
       (RY>=img_range.vy_min)&(RY<=(img_range.vy_max));

RX  = RX(valid);  
RY  = RY(valid);  
S   = data.S(valid);
%ERR = data.ERR(valid).^2;
% calculate the detectors positions within the interpolation grid:

RX  = floor((RX-img_range.vx_min)/dx);
RY  = floor((RY-img_range.vy_min)/dy);
ind = RY*n_dx+RX+1;


% rebin
N   = ones(numel(ind),1);
N   = accumarray(ind,N);

SN  = accumarray(ind,S);
%ERN = accumarray(ind,ERR);
Z   = SN./N;
if numel(Z)<n_dx*n_dy
    Z((end+1):n_dx*n_dy)=0;
end
Z   = reshape(Z,n_dx,n_dy);

x_axis=img_range.vx_min+(0:(n_dx-1))*dx;
y_axis=img_range.vy_min+(0:(n_dy-1))*dy;
[X,Y]=meshgrid(x_axis,y_axis);
X=X';
Y=Y';    
%[X,Y,Z]= rebin_polyhons(data,img_range);

end


function [X,Y,Z]= rebin_polyhons(data,img_range)
%estimante the size of interpolation grid, given that dx/dy_step min are 
% the minimal detectors projections
[ndet,ne]=size(data.S);
ndat=ndet*ne;

if img_range.dx_step>img_range.dx_step_min
    n_ds = floor(img_range.dx_step/img_range.dx_step_min)+1;
    dx =   img_range.dx_step/n_ds;
else
    dx=img_range.dx_step_min;
end
if img_range.dy_step>img_range.dy_step_min
    n_ds = floor(img_range.dy_step/img_range.dy_step_min)+1;
    dy =   img_range.dy_step/n_ds;
else
    dy=img_range.dy_step_min;
end
% estimate the size of the interpolation grid;
n_dx= floor((img_range.vx_max-img_range.vx_min)/dx);
n_dy= floor((img_range.vy_max-img_range.vy_min)/dy);


% calculate signal and error densities for further interpolation
[S,ERR,RX,RY]=find_signal_density(data,ndat);


% select detectors, with at least one point contributing into the selection range
r_v = any((RX>=img_range.vx_min),1)&any((RX<img_range.vx_max),1)& ...
      any((RY>=img_range.vy_min),1)&any((RY<img_range.vy_max),1);
% remove singleton dimension
r_v=squeeze(r_v);
% resize the signal and error arrays according to selected area
S   = S(r_v);
ERR = ERR(r_v);

% expand ndet*ne boolean on 4*ndet*ne boolean to work with 4D polyhons
r_v = reshape(repmat(reshape(r_v,1,ndat),4,1),4,ndet,ne);
ndat =numel(S);
RX   = RX(r_v);
RY   = RY(r_v);
% suppress rundomisztion error;
ABSRELERR=1.e-4;
x_min = min(RX);
if abs(x_min-img_range.vx_min)<ABSRELERR||(img_range.vx_min>ABSRELERR&&abs((x_min-img_range.vx_min)/(x_min+img_range.vx_min))>ABSRELERR)
    img_range.vx_min=x_min;
end
y_min = min(RY);
if abs(y_min-img_range.vy_min)<ABSRELERR||(img_range.vy_min>ABSRELERR&&abs((y_min-img_range.vy_min)/(y_min+img_range.vy_min))>ABSRELERR)
    img_range.vy_min=y_min;
end


% indexes of old detectors in the new interpolation grid;
RX  = (RX-img_range.vx_min)/dx+1;
RY  = (RY-img_range.vy_min)/dy+1;
RX  = reshape(RX,4,ndat);
RY  = reshape(RY,4,ndat);

% backward procedure: the indexes of new interpolation grid in the old
% coordinate system:

Z=zeros(n_dx,n_dy);
ic=0;
for i=1:ndat;
    ix_min=floor(min(RX(:,i)));
    ix_min=max(1,ix_min);
    ix_max=floor(max(RX(:,i))); 
    ix_max=floor(min(ix_max,n_dx*0.99999));
    iy_min=floor(min(RY(:,i)));
    iy_min=max(1,iy_min);
    iy_max=floor(max(RY(:,i))); 
    iy_max=floor(min(iy_max,n_dy*0.99999));
    
    rx=ix_min:ix_max;
    ry=iy_min:iy_max;
    [xx,yy] = meshgrid(rx,ry);
    xx=reshape(xx,numel(xx),1);
    yy=reshape(yy,numel(yy),1);    
    IN = inpolygon(xx,yy,RX(:,i),RY(:,i));
    xx = xx(IN);
    yy = yy(IN);
    Z(xx,yy)=Z(xx,yy)+S(i)*dx*dy;
    ic=ic+1;
    if ic>10000
        fprintf('MSLICE:rebin2D, doing step %d of %d, which is %f\#\n',i,ndat,i/ndat);
        ic=0;
    end
end
% in simple case this is it, convert signal into mslice format
x_axis=img_range.vx_min+(0:(n_dx-1))*dx;
y_axis=img_range.vy_min+(0:(n_dy-1))*dy;
[X,Y]=meshgrid(x_axis,y_axis);
X=X';
Y=Y';    
    
end


function [S,ERR,RX,RY]=find_signal_density(data,ndat)

% 
% X(2*i-1,:)=data.vb(i,:,1);	% vx values of the boundary on the "left"
% X(2*i,:)  =data.vb(i,:,3);	% vx values of the boundary on the "right"
% Y(2*i-1,:)=data.vb(i,:,2);
% Y(2*i,:)  =data.vb(i,:,4);
[ndet,ne]=size(data.S);

RX=zeros(4,ndat);
RY=zeros(4,ndat);
RX(1,:)= reshape(data.vb(:,1:(end-1),1),ndat,1);
RX(2,:)= reshape(data.vb(:,1:(end-1),3),ndat,1);
RX(3,:)= reshape(data.vb(:,2:end,3),ndat,1);
RX(4,:)= reshape(data.vb(:,2:end,1),ndat,1);
%
RY(1,:)= reshape(data.vb(:,1:(end-1),2),ndat,1);
RY(2,:)= reshape(data.vb(:,1:(end-1),4),ndat,1);
RY(3,:)= reshape(data.vb(:,2:end,4),ndat,1);
RY(4,:)= reshape(data.vb(:,2:end,2),ndat,1);

%j=(1:ndat)';

%Surf=zeros(ndat,1);

Surf=polyarea(RX,RY,1);

ERR=data.ERR./data.S;
S  = data.S./reshape(Surf,ndet,ne);
RX = reshape(RX,4,ndet,ne);
RY = reshape(RY,4,ndet,ne);

end