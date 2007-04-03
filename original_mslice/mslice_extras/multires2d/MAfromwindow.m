function MA_d=MAfromwindow
% function MA_d=MAfromwindow
% extract MA_d from mslice ControlWindow into the command line 
%___________________________________________________________________________________________
% More Info: 'A multiresolution data visualization tool for applications in neutron 
%             time-of-flight spectroscopy' Nuclear Instruments and Methods
%             2005.
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/2.0/ 
% or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
%___________________________________________________________________________________________

h_ma=findobj('Tag','plot_MA');
if isempty(h_ma),
   disp('Multiresolution Window not OPEN: type "ms_MA" first.');
   return;
end


MA_d=get(h_ma,'UserData');
