function wout=ixt(data)
% Convert mslice data structure to corresponding Horace dnd structure
%
% T.G.Perring   Feb 2009

% Check input data
if ~isstruct(data)
    error('Input must be a structure')
end

% Get dimensionality
ndim=convert_ms_getdim(data);

if ndim==1
    wout = IXTdataset_1d (IXTbase, data.title, data.y, data.e, IXTaxis(data.y_label), data.x, IXTaxis(data.x_label), false);
elseif ndim==2
    wout = IXTdataset_2d (IXTbase, data.title, data.intensity(1:end-1,1:end-1)', data.error_int(1:end-1,1:end-1)',...
        IXTaxis(data.axis_label(3,:)), data.vx, IXTaxis(data.axis_label(1,:)), false, data.vy, IXTaxis(data.axis_label(2,:)), false);
elseif ndim==3
    s_axis = IXTaxis (data.axis_label(4,:));
    axis_1 = IXTaxis (data.axis_label(1,:));
    axis_2 = IXTaxis (data.axis_label(2,:));
    axis_3 = IXTaxis (data.axis_label(3,:));
    wout = IXTdataset_3d (IXTbase, data.title, data.intensity, data.error_int, s_axis,...
        data.vx, axis_1, false, data.vy, axis_2, false, data.vz, axis_3, false);
else
    error('Unable to convert data structure')
end
