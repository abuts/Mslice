function ms_bkgd_sub(wback)
% Subtract 1D cut from data (must have already performed 'Calculate Projections')
%
%   >> ms_bkgd_sub(wback)
%
% wback must have fields wback.x, wback.y, wback.e, or an object with a method
% called 'xye' that returns a structure with these fields.

% Check mslice is open
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   error('Mslice control window does not exist')
end

% Get temporary structure from input
if isstruct(wback)  % assume is mslice 1D cut
    tmp.x=wback.x; tmp.y=wback.y; tmp.e=wback.e;
else % try assuming is an object with a method xye which returns x,y,e arrays (e.g. mgenie spectrum, IXTdataset_1d)
    try
        tmp=xye(wback);
    catch
        error('input must be mslice 1D cut, a structure with fields x, y, e, or object with a method called xye that returns such a structure')
    end
end

data=fromwindow;

% Check that the x-axis matches that of the data
en=tmp.x;
if length(data.en)~=length(en)
    error('Number of energy bins in data and background do not match')
end

if max(abs(data.en(:)-en(:)))>0.00001
    error('Energy bins of background do not match those of data')
end

y=tmp.y;
if any(isnan(y))
    error('One or more data points in background spectrum are NaN')
end

% Perform subtraction
data.S=data.S-repmat(y',size(data.S,1),1);

towindow(data);
