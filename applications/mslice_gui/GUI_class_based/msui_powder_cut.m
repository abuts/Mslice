function [pos,pos_u1step,pos_u2step] = msui_powder_cut(pos,h_root,oneline,interlines,white,coltab)
% Interface to Powder: Cut display
% Outputs:
% pos        -- position of the last row of this menu
% pos_u1step -- the starting position of the step for rebinning in x-direction
% pos_u2step -- the starting position of the step for rebinning in y-direction


width = pos(3);
height= pos(4);
pos(2)=pos(2)-height;


this_name = 'powder_slice';
mslice_gui = msui_collection(h_root,'mslice_gui');
if exist(mslice_gui,this_name)
    pos = get_line_pos(get(mslice_gui,this_name)); 
    
    % positions of the binning controls
    pos(3)=width;
    pos=pos-oneline;
    pos_u1step=pos+[6*pos(3) 0 0 interlines];
    pos=pos-oneline;
    pos_u2step=pos+[6*pos(3) 0 0 interlines];       
    return;
end


hb = cell(20,1);
%========= Slice plane/Display  ==================
hb{1}=uicontrol('Parent',h_root,'Style','text','String','Display',...
    'Position',pos,'BackgroundColor',white,'Visible','off');

%========= Display vx_min, vx_max, bin_vx ==================
%
pos(3)=width;

pos=pos-oneline;
hb{2}=uicontrol('Parent',h_root,'Style','text','String','horizontal range ',...
	'Tag','ms_disp_x_axis',...
  	'Position',pos+[pos(3) 0 pos(3) 0],'Visible','off');
hb{3}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_vx_min',...
 	'Position',pos+[3*pos(3) 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');
hb{4}=uicontrol('Parent',h_root,'Style','text','String','to *',...
  	'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hb{5}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_vx_max',...
  	'Position',pos+[5*pos(3) 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');
    % provisional position of the step tab:
     pos_u1step=pos+[6*pos(3) 0 0 interlines];

%========= Display vy_min, vy_max, bin_vy ==================
pos=pos-oneline;
hb{6}=uicontrol('Parent',h_root,'Style','text','String','vertical range',...
	'Tag','ms_disp_y_axis',...
  	'Position',pos+[pos(3) 0 pos(3) 0],'Visible','off');
hb{7}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_vy_min',...
  	'Position',pos+[3*pos(3) 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');
hb{8}=uicontrol('Parent',h_root,'Style','text','String','to *',...
  	'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hb{9}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_vy_max',...
  	'Position',pos+[5*pos(3) 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');
    % provisional position of the step tab:
     pos_u2step=pos+[6*pos(3) 0 0 interlines];
   
%========= Display Intensity range ==================
pos=pos-oneline;
hb{10}=uicontrol('Parent',h_root,'Style','text','String','Intensity range*',...
  	'Position',pos+[pos(3) 0 pos(3) 0],'Visible','off');
hb{11}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_i_min',...
  	'Position',pos+[3*pos(3) 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');
hb{12}=uicontrol('Parent',h_root,'Style','text','String','to *',...
  	'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hb{13}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_i_max',...
  	'Position',pos+[5*pos(3) 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');
hb{14}=uicontrol('Parent',h_root,'Style','text','String','Colour map',...
  	'Position',pos+[6*pos(3) 0 0 0],'Visible','off');

hb{15}=uicontrol('Parent',h_root,'Style','popupmenu','Tag','ms_disp_colmap',...
  	'Position',pos+[7*pos(3) -interlines 0 interlines],...
  	'HorizontalAlignment','left',...
  	'String',{'black->red','log10(blk-red)','blue->red'},...
  	'BackgroundColor',white,'Value',1,'UserData',coltab,'Visible','off');

   
%========= Display Smooth Level and Shading ==================
pos=pos-oneline;
hb{16}=uicontrol('Parent',h_root,'Style','text','String','Smoothing level*',...
   'Position',pos+[pos(3) 0 pos(3) 0],'Visible','off');
hb{17}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_nsmooth',...
  	'Position',pos+[3*pos(3) 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');
hb{18}=uicontrol('Parent',h_root,'Style','text','String','Shading',...
  	'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hb{19}=uicontrol('Parent',h_root,'Style','popupmenu','Tag','ms_disp_shad',...
  	'Position',pos+[5*pos(3) -interlines 0 interlines],...
  	'HorizontalAlignment','left',...
  	'String',{'flat','faceted'},...
   'BackgroundColor',white,'Value',1,'Visible','off');
%=============================================

%========= Do Display ==================
%pos=pos-oneline;
hb{20}=uicontrol('Parent',h_root,'Style','pushbutton','String','Display',...
  	'Callback','ms_disp;',...
  	'Position',pos+[6*pos(3) 0 width 0],'Visible','off');    
                             
% create graphic elements colllection
powder_slice =graph_objects_collection(this_name);
% add the handles to the collection and add it to the mslice_gui;
add(mslice_gui,add_handles(powder_slice,hb));
