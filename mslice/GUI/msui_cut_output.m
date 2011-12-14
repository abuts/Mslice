function [pos,mslice_gui] =  msui_cut_output(h_root,pos,oneline,interlines,white,sample)
% function defines cut output interface for mslice menu
%
%
%Callbacks:
% ms_pick_output
% ms_cut(''tomfit'')
% ms_cut(''store_bkg_E'')
% ms_cut;
% ms_cut(''over'');
%Variables:
% ms_cut_OutputFile
this_name='cut_output';
mslice_gui = msui_collection(h_root,'mslice_gui');
if exist(mslice_gui,this_name)
     pos = get_line_pos(get(mslice_gui,this_name)); 
    return;
end

ho    =cell(10,1);
width = pos(3);
height= pos(4);
pos(2)=pos(2)-height;
% output file
ho{1}=uicontrol('Parent',h_root,'Style','text','String','OutputFile*',...
                        'Position',pos+[0 0 0.0*width 0],'Visible','off');
                    
pos(3)=width;%

CutFileFormat={'none','.cut','.xye','.smh','Mfit .cut'};
if (sample==1), % single crystal sample analysed as powder
   CutFileFormat={'none','.cut','.xye','.smh','Mfit .cut', '.hkl'};
end
%========= OutputFile + To Mfit pushbutton + Generate bkg(E) button ==================
ho{2}=uicontrol('Parent',h_root,'Style','popupmenu','String',CutFileFormat,...
                        'Value',1,'BackgroundColor',white,'Tag','ms_cut_OutputType',...
                        'Position',pos+[1*pos(3) 0 pos(3)*1/4 interlines],'Visible','off');
ho{3}=uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_cut_OutputFile',...
                        'Position',pos+[2*pos(3)+pos(3)*1/4 0 2*pos(3)-pos(3)*1/4 interlines],...
                        'HorizontalAlignment','left',...
                        'BackgroundColor',white,'Visible','off');
ho{4}=uicontrol('Parent',h_root,'Style','pushbutton','String','Browse',...
                        'Callback','ms_pick_output',...
                        'Position',pos+[5*pos(3) 0 0 0],'Visible','off');   
ho{5}=uicontrol('Parent',h_root,'Style','pushbutton','String','To Mfit',...
                        'Callback','ms_cut(''tomfit'');',...
                        'Position',pos+[6*pos(3) 0 0 0],'Visible','off'); 
ho{6}=uicontrol('Parent',h_root,'Style','pushbutton',...
                       'Tag','ms_bkg_E','String','Store bkg(E)',...
                       'Callback','ms_cut(''store_bkg_E'');','UserData',[],...
                       'Position',pos+[7*pos(3) 0 0 0],'Visible','off'); 

%========= Do Cut ==================
h=findobj(h_root,'Tag','ms_cut_intensity');
if ~isempty(h),
   strings=get(h(1),'String');
   strings{1}='cut axis';
else
   strings{1}='cut axis';
end   
%
pos=pos-oneline;
ho{7}=uicontrol('Parent',h_root,'Style','text','String','x-axis',...
   'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
ho{8}=uicontrol('Parent',h_root,'Style','popupmenu','Tag','ms_cut_xaxis',...
  	'Position',pos+[5*pos(3) -interlines/2 0 interlines],...
  	'String',strings,'Value',1,...
  	'BackgroundColor',white,'Visible','off');
ho{9}=uicontrol('Parent',h_root,'Style','pushbutton','String','Plot Cut',...
   'Callback','ms_cut;',...
   'Position',pos+[6*pos(3) 0 0 0],'Visible','off'); 
ho{10}=uicontrol('Parent',h_root,'Style','pushbutton','String','Plot Cut Over',...
   'Callback','ms_cut(''over'');',...
   'Position',pos+[7*pos(3) 0 0 0],'Visible','off'); 

 % create graphic elements colllection
cut_output =graph_objects_collection(this_name);
% add the handles to the collection and add it to the mslice_gui;
mslice_gui=add(mslice_gui,add_handles(cut_output,ho));

