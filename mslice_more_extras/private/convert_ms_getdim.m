function ndim = convert_ms_getdim(data)
% Get dimensionaility of mslice output structure
%
% T.G.Perring Feb 2009

% necessary fields to convert
fields_1d={'x','y','e','title','x_label','y_label'};
fields_2d={'vx','vy','intensity','error_int','title','axis_label'};
fields_3d={'vx','vy','vz','intensity','error_int'};

if isstruct(data)
    ok_1d=true;
    for i=1:numel(fields_1d)
        ok_1d = ok_1d & isfield(data,fields_1d{i});
    end
    ok_2d=true;
    for i=1:numel(fields_2d)
        ok_2d = ok_2d & isfield(data,fields_2d{i});
    end
    ok_3d=true;
    for i=1:numel(fields_3d)
        ok_3d = ok_3d & isfield(data,fields_3d{i});
    end
    if ok_2d && ok_3d && isfield(data,'vz')
        ok_2d=false;    % determine that it must be a 3D object
    end
    if (ok_1d+ok_2d+ok_3d)>1
        error('structure does not uniquely correspond to one of 1D, 2D or 3D cut from mslice')
    elseif (ok_1d+ok_2d+ok_3d)<1
        error('Structure is not a 1D, 2D or 3D cut from mslice')
    else
        if ok_1d, ndim=1; end
        if ok_2d, ndim=2; end
        if ok_3d, ndim=3; end
    end
else
    error('Input must be a structure')
end
