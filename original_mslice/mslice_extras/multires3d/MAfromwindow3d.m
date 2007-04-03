function MA_d=MAfromwindow3d
% function MA_d=MAfromwindow
% extract MA_d structure from 'MSlice: MULTIRESOLUTION 3D' window into the command line 
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





h_ma=findobj('Tag','plot_MA3d');
if isempty(h_ma),
   disp('Multiresolution Window not OPEN: type "ms_MA3d" first.');
   return;
end


ma_d=get(h_ma,'UserData');

MA_d.vx=ma_d.vx;
MA_d.vy=ma_d.vy;
MA_d.vz=ma_d.vz;
MA_d.intensity=ma_d.intensity;
MA_d.error=ma_d.error;
MA_d.L_T=ma_d.L_T;