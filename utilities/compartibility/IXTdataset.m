function [wout,ndim]=IXTdataset(data)
% Convert 1D, 2D or 3D mslice data structure to corresponding Libisis structure
%
%   >> wout=IXTdataset(data)
%   >> [wout,ndim]=IXTdataset(data)

% Has to be a function with name *different* to IXTdatset_1d, IXTdataset_2d, IXTdataset_3d and IXTdataset_nd
% because otherwise Matlab will call the IXTdataset_1d (2D,3D,nd) constructor, as the argument
% is a structure, not a user-defined class.

% T.G.Perring   Feb 2009

% Check input data
if ~isstruct(data)
    error('Input must be a structure')
end

for i=1:numel(data)
    ndim_tmp=convert_ms_getdim(data(1));
    if i==1
        ndim=ndim_tmp;
    else
        if ndim_tmp~=ndim
            error('Not all input structures have the same dimensionality of the cut')
        end
    end
end

for i=1:numel(data)
    if ndim==1
        if i==1
            wout=IXTdataset_1d;
            if numel(data)>1, wout(numel(data))=wout; end  % allocate array
        end
        wout(i) = IXTdataset_1d (IXTbase, data(i).title, data(i).y, data(i).e, IXTaxis(data(i).y_label), data(i).x, IXTaxis(data(i).x_label), false);
    elseif ndim==2
        if i==1
            wout=IXTdataset_2d;
            if numel(data)>1, wout(numel(data))=wout; end  % allocate array
        end
        if numel(data)>1, wout(numel(data))=wout; end  % allocate array
        wout(i) = IXTdataset_2d (IXTbase, data(i).title, data(i).intensity(1:end-1,1:end-1)', data(i).error_int(1:end-1,1:end-1)',...
            IXTaxis(data(i).axis_label(3,:)), data(i).vx, IXTaxis(data(i).axis_label(1,:)), false, data(i).vy, IXTaxis(data(i).axis_label(2,:)), false);
    elseif ndim==3
        if i==1
            wout=IXTdataset_3d;
            if numel(data)>1, wout(numel(data))=wout; end  % allocate array
        end
        if numel(data)>1, wout(numel(data))=wout; end  % allocate array
        s_axis = IXTaxis (data(i).axis_label(4,:));
        axis_1 = IXTaxis (data(i).axis_label(1,:));
        axis_2 = IXTaxis (data(i).axis_label(2,:));
        axis_3 = IXTaxis (data(i).axis_label(3,:));
        wout(i) = IXTdataset_3d (IXTbase, data(i).title, data(i).intensity, data(i).error_int, s_axis,...
            data(i).vx, axis_1, false, data(i).vy, axis_2, false, data(i).vz, axis_3, false);
    else
        error('Unable to convert data structure')
    end
end
