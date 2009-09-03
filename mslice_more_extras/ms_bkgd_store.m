function ms_bkgd_store(wback)
% Store named mgenie spectrum as background estimate
%
%   >> ms_bkgd_store(wback)
%

fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   error('Mslice control window does not exist')
end

tmp=get(wback);     % get a structure with the fields of wback
xye.x=tmp.x; xye.y=tmp.y; xye.e=tmp.e; 
set(findobj(fig,'Tag','ms_bkg_E'),'UserData',xye);
