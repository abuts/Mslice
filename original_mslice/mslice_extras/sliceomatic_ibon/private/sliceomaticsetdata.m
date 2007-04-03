function appdata = sliceomaticsetdata(d)
% SLICEOMATICSETDATA(rawdata) - Create the data used for
% sliceomatic in the appdata D.
  
% Simplify the isonormals
  disp('Smoothing for IsoNormals...');
  d.smooth=smooth3(d.data);% ,'box',5);
   %modified by srikanth on 9th may 2003
  d.reducenumbers=[1 1 1];

%  d.reducenumbers(d.reducenumbers==0)=1;
%-----------------------------------------------------------------------
%Previous to 26 July 2005:
% dY=(d.ylim(2)-d.ylim(1))/((size(d.data,1)-1)/d.reducenumbers(1));
% dX=(d.xlim(2)-d.xlim(1))/((size(d.data,2)-1)/d.reducenumbers(2));
% dZ=(d.zlim(2)-d.zlim(1))/((size(d.data,3)-1)/d.reducenumbers(3));
%   % Vol vis suite takes numbers in X/Y form.
%   lx = d.xlim(1):dX:d.xlim(2);
%   ly = d.ylim(1):dY:d.ylim(2);
%   lz = d.zlim(1):dZ:d.zlim(2);
%---------------------------------
% Now: (TGP, July 2005)
dY=(d.ylim(2)-d.ylim(1))/((size(d.data,1))/d.reducenumbers(1));
dX=(d.xlim(2)-d.xlim(1))/((size(d.data,2))/d.reducenumbers(2));
dZ=(d.zlim(2)-d.zlim(1))/((size(d.data,3))/d.reducenumbers(3));
  % Vol vis suite takes numbers in X/Y form.
  lx = (d.xlim(1)+dX/2):dX:(d.xlim(2)-dX/2);
  ly = (d.ylim(1)+dY/2):dY:(d.ylim(2)-dY/2);
  lz = (d.zlim(1)+dZ/2):dZ:(d.zlim(2)-dZ/2);
%-----------------------------------------------------------------------
  d.reducelims={lx ly lz };
  disp('Generating reduction volume...');
%-----------------------------------------------------------------------
% (TGP 31 July 2005) replace:
%   d.reduce= reducevolume(d.data,d.reducenumbers);
%--------------------------------
% with:
  zmin = min(min(min(d.data)));
  data_for_isosurfaces = d.data;
  data_for_isosurfaces(find(isnan(d.data))) = zmin;
  d.reduce = reducevolume(data_for_isosurfaces,d.reducenumbers);
%-----------------------------------------------------------------------
  
  d.reducesmooth=smooth3(d.reduce);%,'gaussian',5);
  d.xlabel='U1';
  d.ylabel='U2';
  d.zlabel='U3';
  appdata = d;