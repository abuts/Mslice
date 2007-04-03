function ms_updatelabel_MApow
% function ms_updatelabel_MApow(n)
%
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






% === return if ControlWindow not present
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   disp('Control Window not active: Open Mslice first.');
   return;
end

% h_ma=findobj('Tag','plot_MApow');
% MApow_d=get(h_ma,'UserData');
% 
% axis_label=MApow_d.axis_label;





% ... we still need to update this section... here
