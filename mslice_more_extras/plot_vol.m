function plot_vol (w)
% Plots 3D mslice section using sliceomatic
%
% Syntax:
%   >> plot (w)

% This routine is not very elegant - it decides to use the mgenie plotting or the
% libisis version of sliceomatic according as to which it finds installed. If by
% some curious path, it finds both installed, then will default to libisis.

libisis_ok=false;
mgenie_ok=false;
try
    try
        tmp=IXTdataset_1d;
        libisis_ok=true;
    catch
        tmp=spectrum;
        mgenie_ok=true;
    end
catch
    error('Neither Libisis nor mgenie appears to be installed - cannot plot')
end

if libisis_ok
    plot_vol_libisis(w)
else
    plot_vol_mgenie(w)
end



%=================================================================================================================
function plot_vol_mgenie (w, zmin, zmax)
% plot    Plots 3D dataset using sliceomatic
%
% Syntax:
%   >> plot (w)
%   >> plot (w, i_min, i_max)   % plot with given plot limits
%
%
% NOTES:
%
% - Ensure that the slice color plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Color Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics window.
%
% - To set the default for future Sliceomatic sessions - 
%      On the 'Object_Defaults' menu select 'Slice Color Texture'


% Prepare intensity array
%   - remove zeros in w.n to avoid zero divides
%   - reorder array to account for sliceomatic (as with many instrinsic matlab graphics functions) expects
%    the content of the array to be signal(y,x).

if nargin==1
    zmin = min(w.intensity(:));
    zmax = max(w.intensity(:));
    if isnan(zmin)||isnan(zmax)
        error ('No data in volume')
    end
    if zmin==zmax
        error ('ERROR: All intensity values are the same')
    end
elseif nargin==3
    if zmin>=zmax
        error ('requested intensity minimum must be less than requested intensity maximum')
    end
end

signal = permute(w.intensity,[2,1,3]);   % permute dimensions for sliceomatic

% Plot data
colordef white; % white background
dv1 = (w.vx(end)-w.vx(1))/(length(w.vx)-1);
dv2 = (w.vy(end)-w.vy(1))/(length(w.vy)-1);
dv3 = (w.vz(end)-w.vz(1))/(length(w.vz)-1);
vx_cent_lims = [w.vx(1)+dv1/2, w.vx(end)-dv1/2];
vy_cent_lims = [w.vy(1)+dv2/2, w.vy(end)-dv2/2];
vz_cent_lims = [w.vz(1)+dv3/2, w.vz(end)-dv3/2];
sliceomatic(vx_cent_lims, vy_cent_lims, vz_cent_lims, signal, ...
    ['axis 1: ',deblank(w.axis_shortlabel(1,:))],...
    ['axis 2: ',deblank(w.axis_shortlabel(2,:))],...
    ['axis 3: ',deblank(w.axis_shortlabel(3,:))],...
    w.axis_label(1,:), w.axis_label(2,:), w.axis_label(3,:), [zmin,zmax]);
title(w.title)
set(gca,'Position',[0.225,0.225,0.55,0.55]);
axis normal

% Rescale plot so that aspect ratios reflect relative lengths of Q axes
e_ax=[];
for i=1:3
    if isempty(findstr(w.axis_label(i,:),'Å^{-1}'))
        e_ax=i;
        break
    end
end

ulen = w.axis_unitlength;         % unit length in order of the display axes
if isempty(e_ax)   % none of the plot axes is an energy axis
    aspect = [1/ulen(1), 1/ulen(2), 1/ulen(3)];
else
    aspect = [1/ulen(1), 1/ulen(2), 1/ulen(3)];
    a = get(gca,'DataAspectRatio');
    q_ax = rem([e_ax,e_ax+1],3)+1;      % indices of the other two display axes (cyclic permutation)
    aspect(e_ax) = a(e_ax)/max([ulen(q_ax(1))*a(q_ax(1)), ulen(q_ax(2))*a(q_ax(2))]);
end
set(gca,'DataAspectRatio',aspect);


%=================================================================================================================
function plot_vol_libisis(win, varargin)
% Plots 3D volume from mslice using sliceomatic
%
% Syntax:
%   >> plot_3d (win)
%   >> plot_3d (win, 'isonormals', true)     % to enable isonormals
%
%
% NOTES:
%
% - Ensure that the slice color plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Color Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics window.
%
% - To set the default for future Sliceomatic sessions - 
%      On the 'Object_Defaults' menu select 'Slice Color Texture'


w = IXTdataset_nd(win);             % make IXTdataset_3d from data
if dimensions(w)~=3
    error('Input structure must correspond to a 3D mslice section')
end

ulen = win.axis_unitlength;         % unit length in order of the display axes
clim = [min(w.signal(:)) max(w.signal(:))];

sm(w, 'clim', clim, 'title', win.title, ...
    'xlabel', win.axis_label(1,:),...
    'ylabel', win.axis_label(2,:),...
    'zlabel', win.axis_label(3,:),...
    'x_sliderlabel', ['axis 1: ',deblank(win.axis_shortlabel(1,:))],...
    'y_sliderlabel', ['axis 2: ',deblank(win.axis_shortlabel(2,:))],...
    'z_sliderlabel', ['axis 3: ',deblank(win.axis_shortlabel(3,:))],...
    varargin{:});

% Resize the box containing the data
% set(gca,'Position',[0.225,0.225,0.55,0.55]);
set(gca,'Position',[0.2,0.2,0.6,0.6]);
axis normal

% Rescale plot so that aspect ratios reflect relative lengths of Q axes
e_ax=[];
for i=1:3
    if isempty(findstr(win.axis_label(i,:),'Å^{-1}'))
        e_ax=i;
        break
    end
end

if isempty(e_ax)   % none of the plot axes is an energy axis
    aspect = [1/ulen(1), 1/ulen(2), 1/ulen(3)];
else
    aspect = [1/ulen(1), 1/ulen(2), 1/ulen(3)];
    a = get(gca,'DataAspectRatio');
    q_ax = rem([e_ax,e_ax+1],3)+1;      % indices of the other two display axes (cyclic permutation)
    aspect(e_ax) = a(e_ax)/max([ulen(q_ax(1))*a(q_ax(1)), ulen(q_ax(2))*a(q_ax(2))]);
end
set(gca,'DataAspectRatio',aspect);
