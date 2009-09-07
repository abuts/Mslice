function ms_bkgd_store(wback)
% Store 1D cut as background estimate. Assumes that the cut is an energy cut
%
%   >> ms_bkgd_store(wback)
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

% Store background
set(findobj(fig,'Tag','ms_bkg_E'),'UserData',tmp);
