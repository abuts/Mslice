function pos = msui_detector_tragectories(fig,oneline,lineoffset,interlines,white,strings,sample)

this_name='detector_tragectories';
mslice_gui = get(findobj('Tag','mslice_gui'),'UserData');
if exist(mslice_gui,this_name)
    pos = get_line_pos(get(mslice_gui,this_name));
    
    set(findobj(fig,'Tag','ms_plot_traj_x'),'Value',2,'String',strings);
	set(findobj(fig,'Tag','ms_plot_traj_y'),'Value',1,'String',strings);
	strings{length(strings)+1}='none';
	set(findobj(fig,'Tag','ms_plot_traj_z'),'String',strings,'Value',length(strings));
	drawnow;
% === if sample is single crystal then make sure the (khl) check boxes are present
      if (sample==1)
             msui_det_hkl_points(fig,pos,oneline,lineoffset,interlines,white);
      else % and if not -- they are deleted
             delete(mslice_gui,'det_hkl_points');
      end 
   return
end

%========= Plot Detector Trajectories ==================
pos=get(findobj('String','OutputFile*'),'Position')-oneline;	
    
pos=pos-(lineoffset+1)*oneline;
h{1}=uicontrol('Parent',fig,'Style','text','String','Detector Trajectories',...
	  	'Position',pos+[0 0 pos(3) 0],'BackgroundColor',white,'Visible','off');
	
	%========= x variable and range ==================
pos=pos-1.1*oneline-[0 interlines 0 0];
h{2}=uicontrol('Parent',fig,'Style','text','String','x',...
	  	'Position',pos,'Visible','off');
h{3}=uicontrol('Parent',fig,'Style','popupmenu',...
	  	'Tag','ms_plot_traj_x',...
		'String',strings,...
		'Position',pos+[pos(3) 0 pos(3)*1/4 interlines],...
	  	'HorizontalAlignment','left',...
	  	'BackgroundColor',white,'Value',1,'Visible','off');
h{4}=uicontrol('Parent',fig,'Style','text','String','from *',...
		'Position',pos+[2*pos(3)+pos(3)*1/4 0 -pos(3)*1/4 0],'Visible','off');
h{5}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_vx_min',...
	  	'Position',pos+[3*pos(3) 0 0 interlines],...
	  	'HorizontalAlignment','left',...
	  	'BackgroundColor',white,'Visible','off');
h{6}=uicontrol('Parent',fig,'Style','text','String','to *',...
	  	'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
h{7}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_vx_max',...
	  	'Position',pos+[5*pos(3) 0 0 interlines],...
	  	'HorizontalAlignment','left',...
	  	'BackgroundColor',white,'Visible','off');
	
%========= y variable and range ==================
pos=pos-oneline;
h{8}=uicontrol('Parent',fig,'Style','text','String','y',...
	  	'Position',pos,'Visible','off');
h{9}=uicontrol('Parent',fig,'Style','popupmenu',...
	  	'String',strings,...
	  	'Tag','ms_plot_traj_y',...
	  	'Position',pos+[pos(3) 0 pos(3)*1/4 interlines],...
	  	'HorizontalAlignment','left',...
	  	'BackgroundColor',white,'Value',2,'Visible','off');
h{10}=uicontrol('Parent',fig,'Style','text','String','from *',...
		'Position',pos+[2*pos(3)+pos(3)*1/4 0 -pos(3)*1/4 0]);
h{11}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_vy_min',...
	  	'Position',pos+[3*pos(3) 0 0 interlines],...
	  	'HorizontalAlignment','left',...
	  	'BackgroundColor',white,'Visible','off');
h{12}=uicontrol('Parent',fig,'Style','text','String','to *',...
	  	'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
h{13}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_vy_max',...
	  	'Position',pos+[5*pos(3) 0 0 interlines],...
	  	'HorizontalAlignment','left',...
	  	'BackgroundColor',white,'Visible','off');
  
%========= z variable and range ==================
strings{length(strings)+1}='none';
pos=pos-oneline;
h{14}=uicontrol('Parent',fig,'Style','text','String','z',...
  		'Position',pos,'Visible','off');
h{15}=uicontrol('Parent',fig,'Style','popupmenu',...
  		'String',strings,...
  		'Tag','ms_plot_traj_z',...
  		'Position',pos+[pos(3) 0 pos(3)*1/4 interlines],...
  		'HorizontalAlignment','left',...
		'BackgroundColor',white,'Value',3,'Visible','off');
h{16}=uicontrol('Parent',fig,'Style','text','String','from *',...
		'Position',pos+[2*pos(3)+pos(3)*1/4 0 -pos(3)*1/4 0],'Visible','off');
h{17}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_vz_min',...
	  	'Position',pos+[3*pos(3) 0 0 interlines],...
	 	'HorizontalAlignment','left',...
	  	'BackgroundColor',white,'Visible','off');
h{18}=uicontrol('Parent',fig,'Style','text','String','to *',...
	  	'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
h{19}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_vz_max',...
	  	'Position',pos+[5*pos(3) 0 0 interlines],...
	  	'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
  
%========= contour lines ==================
pos=pos-oneline;
h{20}=uicontrol('Parent',fig,'Style','text','String','Contours',...
  		'Position',pos,'Visible','off');
h{21}=uicontrol('Parent',fig,'Style','popupmenu',...
  		'String',{'none','Energy'},...
  		'Tag','ms_plot_traj_cont_lines',...
  		'Position',pos+[pos(3) 0 pos(3)*1/4 interlines],...
  		'HorizontalAlignment','left',...
		'BackgroundColor',white,'Value',1,'Visible','off');
h{22}=uicontrol('Parent',fig,'Style','text','String','from',...
		'Position',pos+[2*pos(3)+pos(3)*1/4 0 -pos(3)*1/4 0]);
h{23}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_cont_min',...
  		'Position',pos+[3*pos(3) 0 0 interlines],...
 		'HorizontalAlignment','left',...
  		'BackgroundColor',white,'Visible','off');
h{24}=uicontrol('Parent',fig,'Style','text','String','to',...
  		'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
h{25}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_cont_max',...
  		'Position',pos+[5*pos(3) 0 0 interlines],...
  		'HorizontalAlignment','left',...
   	'BackgroundColor',white,'Visible','off');  
h{26}=uicontrol('Parent',fig,'Style','text','String','step1',...
  		'Position',pos+[6*pos(3) 0 -1/2*pos(3) 0],'Visible','off');
h{27}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_cont_step1',...
  		'Position',pos+[6.5*pos(3) 0 -1/2*pos(3) interlines],...
 		'HorizontalAlignment','left',...
      'BackgroundColor',white,'Visible','off');
h{28}=uicontrol('Parent',fig,'Style','text','String','step2',...
  		'Position',pos+[7*pos(3) 0 -1/2*pos(3) 0],'Visible','off');
h{29}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_cont_step2',...
  		'Position',pos+[7.5*pos(3) 0 -1/2*pos(3) interlines],...
 		'HorizontalAlignment','left',...
      'BackgroundColor',white,'Visible','off');    
  
% ========= Plot command and Do Plot ==================
pos=pos-oneline;
h{30}=uicontrol('Parent',fig,'Style','text','String','Command*',...
		'Position',pos+[3*pos(3) 0 0 0],'Visible','off');    
h{31}=uicontrol('Parent',fig,'Style','edit','Tag','ms_plot_traj_command',...
  		'Position',pos+[4*pos(3) 0 pos(3) interlines],...
  		'HorizontalAlignment','left',...
  		'BackgroundColor',white,'Visible','off');
h{32}=uicontrol('Parent',fig,'Style','pushbutton','String','Plot Trajectories',...
		'Callback','ms_plot_traj;',...
		'Position',pos+[6*pos(3) 0 pos(3) 0],'Visible','off');    
    
 det_trag= graph_objects_collection(this_name); 
 add(mslice_gui,add_handles(det_trag,h));  
%
% === if sample is single crystal then make sure the (khl) check boxes are present
if (sample==1)
    msui_det_hkl_points(fig,pos,oneline,lineoffset,interlines,white);
else % and if not -- they are deleted
    delete(mslice_gui,'det_hkl_points');
end 
