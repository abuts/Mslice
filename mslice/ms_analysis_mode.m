function ms_analysis_mode
% function ms_analysis_mode;
% draw menu options for single crystal analysis mode (single crystal or powder mode)


% === if Control Window non-existent, return
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   disp('Control Window non-existent. Return.')
   return;
end

% === if Sample not identifyable or not sigle crystal, return
sampobj=findobj(fig,'Tag','ms_sample');
if isempty(sampobj),
   disp('Could not locate object with sample type. Return.')
   return;
end
sample=get(sampobj,'Value');
if sample~=1,
   disp('Different analysis modes are only available for single crystal samples. Return.')
   return;
end

% === if Analysis Mode not defined, return
analobj=findobj(fig,'Tag','ms_analysis_mode');
if isempty(analobj),
   disp('Could not locate object with analysis mode. Return.')
   return;
end
analmode=get(analobj,'Value');
%
%
 % === get position parameters for items displayed on the Control Window
pos=get(findobj(fig,'String','AnalysisMode'),'Position');
lineheight=pos(4);
oneline=[0 lineheight 0 0];

pos1=get(sampobj,'Position');
interlines=pos1(4)-lineheight;
white=get(sampobj,'BackgroundColor');


% === if AnalysisMode=single crystal put menu option for detector types  
if (analmode==1),	% === change analysis from powder to single crystal mode   
     msui_detector_type(fig,pos,interlines,white);
    
     ms_disp_or_slice;
else 	% powder analysis mode
  
 position  = pos;
 %position(3)=position(3)/0.82;
 msui_powder_menu(fig,position,white,analmode,sample); 

%  	if psd==1,		% single crystal + PSD detectors
%       strings={'Q_x','Q_y','Q_z','H','K','L','u1','u2','u3','Energy','|Q|','2Theta','Azimuth','Det Group Number'};
%       lineoffset=0;
% 	elseif psd==2,	% single crystal + conventional detectors
%       strings={'Q_x','Q_y','Q_z','H','K','L','u1','u2','Energy','|Q|','2Theta','Azimuth','Det Group Number'};
%       lineoffset=2;
lineoffset=2;
 % === update detector trajectories axes lists
strings={'Q_x','Q_y','Q_z','H','K','L','Energy','|Q|','2Theta','Azimuth','Det Group Number'};
%  
msui_detector_tragectories(fig,oneline,lineoffset,interlines,white,strings,sample) ;
%   set(findobj(fig,'Tag','ms_plot_traj_x'),'Value',2,'String',strings);
%   set(findobj(fig,'Tag','ms_plot_traj_y'),'Value',1,'String',strings);
%   strings{length(strings)+1}='none';
%   set(findobj(fig,'Tag','ms_plot_traj_z'),'String',strings,'Value',length(strings));

end
