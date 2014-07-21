function data_out = sub_slice (data, slice_data)
% Subtract the data of a slice (as created from ms_slice or slice_spe)
% from the result of 'calculate projections' on an spe file.
%
%   >> data_out = sub_slice (data, slice_data)
%       data        Data as obtained by typing >> data = fromwindow;
%                  after 'load parameters' and 'calculate projections'
%       slice_data  Result of calling ms_slice or slice_spe.
%
%       data_out    Data after subtraction, suitable for >> towindow(data_out)
%
% OR
%   >> data_out = sub_slice (data, vx, vy, signal, z)
%       data        Data as obtained by typing >> data = fromwindow;
%                  after 'load parameters' and 'calculate projections'
%       vx          Vector of bin centres along x-axis
%       vy          Vector of bin centres along y-axis
%       signal      Array of intensities at the points defined by x and y:
%                  size(signal)=[length(vx),length(vy)]
%       z           Axis perpendicular to slice plane (1,2 or 3). This is
%                  the index of the viewing axis u1, u2, u3 in the slice
%
%       data_out    Data after subtraction, suitable for >> towindow(data_out)
%
%
% T.G.Perring Sept 2006

data_out = data;

% Set up the arrays for interpolation
if nargin==2
    vx = 0.5*(slice_data.vx(2:end)+slice_data.vx(1:end-1));
    vy = 0.5*(slice_data.vy(2:end)+slice_data.vy(1:end-1));
    signal = slice_data.intensity(1:end-1,1:end-1);
    z = slice_data.z;
elseif nargin~=5
    error ('Check number of arguments to sub_slice')
end

% Get values along axes:
if z==1
    x=2; y=3;
elseif z==2
    x=3; y=1;
elseif z==3
    x=1; y=2;
else
    error ('Check axis label perpendicular to slice is in range 1-3')
end

back=interp2(vx,vy',signal,data.v(:,:,x),data.v(:,:,y),'linear',nan);
data_out.S = data.S - back;

