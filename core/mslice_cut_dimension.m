function ndim=mslice_cut_dimension(data)
% Checks if a data structure is a valid mslice structure for 1D, 2D or 3D cut.
%
%   >> ndim=mslice_cut_dimension(data)

try
    ndim = convert_ms_getdim(data);
catch
    ndim=[];
end
