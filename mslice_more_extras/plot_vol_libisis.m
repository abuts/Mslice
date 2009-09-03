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


w = ixt(win);                       % make IXTdataset_3d from data
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
