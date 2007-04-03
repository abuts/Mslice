function ms_updatelabel_MA3d
% function ms_updatelabel_MA3d(n)
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
h_ma=findobj('Tag','plot_MA3d');
MA3d_d=get(h_ma,'UserData');

axis_label=MA3d_d.axis_label;




% === return if Sample popupmenu not present
sampobj=findobj(fig,'Tag','ms_sample');
if isempty(sampobj),
   disp(['Sample type not defined. Labels not updated.']);
   return;
end
samp=get(sampobj,'Value');	% 1 single crystal, 2 powder
if samp==1,	% === if single crystal sample
   analobj=findobj(fig,'Tag','ms_analysis_mode');
   if isempty(analobj),
      disp(['Single crystal sample but undefined analysis mode. Labels not updated.']);
      return;
   end   
   analmode=get(analobj,'Value');	% =1 single crystal mode, =2 powder mode
   if analmode==1, 	% if single crystal mode
	   detobj=findobj(fig,'Tag','ms_det_type');
   	if isempty(detobj),
      	disp(['Single crystal sample in single crystal analysis mode, but undefined detector type. Labels not updated.']);
      	return;
   	end
      psd=get(detobj,'Value');	% 1 psd 2 conventional detectors
   end
end
   

% === check consistency of calling syntax for powder and single crystal +psd/conventional detectors
if (samp~=2)&~((samp==1)&(analmode==2))&~((samp==1)&(analmode==1)&((psd==1)|(psd==2))),
	disp(sprintf('Unknown operational mode in Mslice with sample=%g',samp));
   if exist('analmode','var'),
      disp(sprintf('analmode=%g',analmode));
   end
   if exist('psd','var'),
      disp(sprintf('dettype=%g',psd));
   end
   return;      
end   

if (samp==1)&(analmode==1),	% single crystal sample in single crystal analysis mode, axes are in wavevector-enery space 
	
    
	% ==== update slice/display and cut menu
	if psd==1,
		% update label of slice plane perpendicular to axis menu
        
		h=findobj('Tag','MA_z');
		strings=get(h,'String');
        z=get(h,'Value');  
    
        fig=findobj('Tag','plot_MA3d');

        MA_x_axis=findobj(fig,'Tag','MA_x_axis');
        MA_y_axis=findobj(fig,'Tag','MA_y_axis');
        MA_z_axis=findobj(fig,'Tag','MA_z_axis');

    
    if (z==1), 
            set(MA_x_axis,'String',axis_label(2,:)); 
            set(MA_y_axis,'String',axis_label(3,:));  
            set(MA_z_axis,'String',axis_label(1,:)); 
    end
    if (z==2),
            set(MA_x_axis,'String',axis_label(3,:)); 
            set(MA_y_axis,'String',axis_label(1,:));
            set(MA_z_axis,'String',axis_label(2,:));
    end
    if (z==3),
            set(MA_x_axis,'String',axis_label(1,:));
            set(MA_y_axis,'String',axis_label(2,:));
            set(MA_z_axis,'String',axis_label(3,:));
    end
    
    
	else
   	disp('!! Multiresolution Algorithm was created for PSD');
    return;
    end   
   
end	   
