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
  det_trag_lines=msui_powder_menu(fig,position,white,analmode,sample); 

  lineoffset=2;
 % === update detector trajectories axes lists %  
  msui_detector_tragectories(fig,oneline,lineoffset,interlines,white,det_trag_lines,sample) ;

end
