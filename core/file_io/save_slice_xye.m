function save_slice_xye(s,filename)
% function save_slice(slice,filename)
% function to save the slice data in <filename> in xye format:
%
%       x1(1)   x2(1)    y(1,1)    e(1,1)
%       x1(2)   x2(1)    y(2,1)    e(2,1)
%        :       :          :        :
%       x1(n1)  x2(1)    y(n1,1)   e(n1,1)
%       x1(1)   x2(2)    y(1,2)    e(1,2)
%       x1(2)   x2(2)    y(2,2)    e(2,2)
%        :       :          :        :
%       x1(n1)  x2(2)    y(n1,2)   e(n1,2)
%       x1(1)   x2(3)    y(1,3)    e(1,3)
%        :       :          :        :
%       x1(n1)  x2(n2)   y(n1,n2)  e(n1,n2)

if isempty(filename)
    return
end

% === return if cut is empty
if isempty(s),
   disp('Slice is empty. Cut not saved. Return.');
   return
end

% === open <filename> for writing
fid=fopen(filename,'wt');
if fid==-1,
   disp([ 'Error opening file ' filename ]);
   fclose(fid);
   return
end

% Get x-y-e data
sz=size(s.intensity);
disp(['Saving slice ( ' num2str(sz(2)-1) ' x ' num2str(sz(1)-1) ' point(s)) to file : ']);
disp(filename);
drawnow;

null_value=-1e30;
[x,y,e]=get_xye(s,null_value);

% write data to file
fprintf (fid, '%-20g %-20g %-20g %-20g \n', [x, y, e]');

fclose(fid);

disp('--------------------------------------------------------------');

%==============================================

function [x,y,e]=get_xye(w,null_value)
% Get the bin centres, intensity and error bar for a 1D, 2D, 3D or 4D dataset
%
%   >> [x,y,e]=get_xye(w, null_value)
%
% Input:
% ------
%   w           Result of slice (1D, 2D,...)
%   null_value  Numeric value to substitute for the intensity in bins
%           with no data.
%           Default: NaN
%           The error bar will always be set to zero.
%
% Output:
% -------
%   x       m x 2 array of the x coordinates of the bin centres
%           m = number of points in the slice.
%           The order of the points is usual Fortran order
%           (1,1), (2,1), ... (n1,1),(1,2),(2,2),...
%
%   y       m x 1 array of intensities
%
%   e       m x 1 array of error bars

x{1}=0.5*(w.vx(2:end)+w.vx(1:end-1));
x{2}=0.5*(w.vy(2:end)+w.vy(1:end-1));

xx=cell(size(x));
[xx{:}]=ndgrid(x{:});   % make grid that covers all bins
for i=1:numel(xx)
    xx{i}=xx{i}(:);     % make each coordinate a column array
end
x=[xx{:}];   % concatenate arrays

y=w.intensity(1:end-1,1:end-1)';
e=w.error_int(1:end-1,1:end-1)';
empty=isnan(y);
y(empty)=null_value;
e(empty)=0;
y=y(:);     % make column array
e=e(:);
