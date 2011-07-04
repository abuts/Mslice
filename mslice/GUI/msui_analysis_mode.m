function pos=msui_analysis_mode(fig,pos,oneline,interlines,white,modes)

this_name = 'analysis_mode';
mslice_gui = get(findobj('Tag','mslice_gui'),'UserData');
if exist(mslice_gui,this_name)
    control = get(mslice_gui,this_name);
    pos = get_line_pos(control);
    
    set(control.handles{2},'String',modes);
    return
end

%========= Analysis mode  ==================
pos=pos-1.3*oneline;
h{1}=uicontrol('Parent',fig,'Style','text','String','AnalysisMode',...
	   'Position',pos,'BackgroundColor',white,'Visible','off');
h{2}=uicontrol('Parent',fig,'Style','popupmenu','String',modes,...
	   'Tag','ms_analysis_mode','BackgroundColor',white,...
	   'Position',pos+[pos(3), -0.5*interlines, 0.5*pos(3), interlines],...
	   'Callback','ms_analysis_mode','Value',1,'Visible','off');

  det= graph_objects_collection(this_name); 
  add(mslice_gui,add_handles(det,h));
