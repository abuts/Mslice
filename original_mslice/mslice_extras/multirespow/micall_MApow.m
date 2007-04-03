function micall_MApow(fig,cmd)
% function micall_MApow(fig,cmd)
%
% function that controls the callbacks to replot slidebars, and the push
% button of the :: MULTIRESOLUTION Slice :: 
%
%
%___________________________________________________________________________________________
% More Info: 
% I. Bustinduy, F.J. Bermejo, T.G. Perring, G. Bordel
% A multiresolution data visualization tool for applications in neutron time-of-flight spectroscopy
% Nuclear Inst. and Methods in Physics Research, A. 546 (2005)  498-508.
%
% Author information: Ibon Bustinduy [multiresolution@gmail.com]
%                URL: http://gtts.ehu.es:8080/Ibon/ISIS/multires.htm
%
%___________________________________________________________________________________________
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/2.0/ 
% or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
%___________________________________________________________________________________________


ERR_slider=findobj(fig,'Tag','ERR_slider');
NLEVEL_slider=findobj(fig,'Tag','NLEVEL_slider');
ERR_te=findobj(fig,'Tag','ERR_te');
NLEVEL_te=findobj(fig,'Tag','NLEVEL_te');
axis1=findobj(fig,'Tag','axis1');
min_value=findobj(fig,'Tag','color_slider_min_value');
max_value=findobj(fig,'Tag','color_slider_max_value');


MA_bin_vx=findobj(fig,'Tag','MA_bin_vx'); % it is actually the 'bin_vx_min' value
MA_bin_vy=findobj(fig,'Tag','MA_bin_vy');

MA_bin_vx_max=findobj(fig,'Tag','MA_bin_vx_max');
MA_bin_vy_max=findobj(fig,'Tag','MA_bin_vy_max');

MA_fix_x=findobj(fig,'Tag','MA_fix_x');
MA_fix_y=findobj(fig,'Tag','MA_fix_y');



figg=findobj('Tag','ms_ControlWindow');
if isempty(figg),
   disp('Control Window not active: Open Mslice first.');
   return;
end


h_ma=findobj('Tag','plot_MApow');
MApow_d=get(h_ma,'UserData');

% aa=double(squeeze(evalin('base','data')));
%data=evalin('base','data');

%------------------------------------------
% disp('hello, you are inside micall_MApow');
%------------------------------------------
if strcmp(cmd,'MA_fix_x')|strcmp(cmd,'MA_fix_y'),
    
set(NLEVEL_slider,'Value',str2double(get(NLEVEL_te,'String')));
nl=str2double(get(NLEVEL_te,'String'));
dx=str2double(get(MA_bin_vx,'String'));
dy=str2double(get(MA_bin_vy,'String'));

if(logical((get(MA_fix_x,'Val')))),
    dxmax=dx;
else
    dxmax=dx.*(2.^(nl-1));
end
if(logical((get(MA_fix_y,'Val')))),
    dymax=dy;
else
    dymax=dy.*(2.^(nl-1));
end

set(MA_bin_vx_max,'String',dxmax);
set(MA_bin_vy_max,'String',dymax);


end





if strcmp(cmd,'ERR_te'),
set(ERR_slider,'Value',str2double(get(ERR_te,'String')));
%multislice_spe_correlation_4(INFO.data,INFO.z,INFO.vz_min,INFO.vz_max,INFO.vx_min,INFO.vx_max,INFO.bin_vx,INFO.vy_min,INFO.vy_max,INFO.bin_vy,str2double(get(NLEVEL_te,'String')),...
%str2double(get(ERR_te,'String')),str2double(get(min_value,'String')),...
%str2double(get(max_value,'String')));
end

if strcmp(cmd,'NLEVEL_te'),
set(NLEVEL_slider,'Value',str2double(get(NLEVEL_te,'String')));

nl=str2double(get(NLEVEL_te,'String'));
dx=str2double(get(MA_bin_vx,'String'));
dy=str2double(get(MA_bin_vy,'String'));


if(logical((get(MA_fix_x,'Val')))),
    dxmax=dx;
else
    dxmax=dx.*(2.^(nl-1));
end
if(logical((get(MA_fix_y,'Val')))),
    dymax=dy;
else
    dymax=dy.*(2.^(nl-1));
end

set(MA_bin_vx_max,'String',dxmax);
set(MA_bin_vy_max,'String',dymax);

end

if strcmp(cmd,'ERR_slider'),
set(ERR_te,'String',num2str(get(ERR_slider,'Val')));
% multislice_spe_correlation_4(INFO.data,INFO.z,INFO.vz_min,INFO.vz_max,INFO.vx_min,INFO.vx_max,INFO.bin_vx,INFO.vy_min,INFO.vy_max,INFO.bin_vy,str2double(get(NLEVEL_te,'String')),...
% str2double(get(ERR_te,'String')),str2double(get(min_value,'String')),...
% str2double(get(max_value,'String')));
end

if strcmp(cmd,'NLEVEL_slider'),
set(NLEVEL_te,'String',num2str(round(get(NLEVEL_slider,'Val'))));

nl=str2double(get(NLEVEL_te,'String'));
dx=str2double(get(MA_bin_vx,'String'));
dy=str2double(get(MA_bin_vy,'String'));


if(logical((get(MA_fix_x,'Val')))),
    dxmax=dx;
else
    dxmax=dx.*(2.^(nl-1));
end
if(logical((get(MA_fix_y,'Val')))),
    dymax=dy;
else
    dymax=dy.*(2.^(nl-1));
end

set(MA_bin_vx_max,'String',dxmax);
set(MA_bin_vy_max,'String',dymax);

% multislice_spe_correlation_4(INFO.data,INFO.z,INFO.vz_min,INFO.vz_max,INFO.vx_min,INFO.vx_max,INFO.bin_vx,INFO.vy_min,INFO.vy_max,INFO.bin_vy,str2double(get(NLEVEL_te,'String')),...
% str2double(get(ERR_te,'String')),str2double(get(min_value,'String')),...
% str2double(get(max_value,'String')));
end


