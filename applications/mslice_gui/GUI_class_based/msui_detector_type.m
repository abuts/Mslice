function pos=msui_detector_type(fig,pos,interlines,white)

this_name = 'detector_type_psd';
mslice_gui = msui_collection(fig,'mslice_gui');
if exist(mslice_gui,this_name)
    pos = get_line_pos(get(mslice_gui,this_name));
    return
end

%=========  Detector type (if single crystal sample): conventional(non-PDS)/PSD ==================
h{1}=uicontrol('Parent',fig,'Style','text','String','Detectors',...
   	'Position',pos+[3*pos(3) 0 0 0],'BackgroundColor',white,'Visible','off');
h{2}=uicontrol('Parent',fig,'Style','popupmenu','String',{'PSD','conventional (non-PSD)'},...
   	'Tag','ms_det_type','BackgroundColor',white,...
   	'Position',pos+[4*pos(3), -0.5*interlines, 1.3*pos(3) ,interlines],...
      'Callback','ms_disp_or_slice','Value',1,'Visible','off');

det= graph_objects_collection(this_name); 
add(mslice_gui,add_handles(det,h));
