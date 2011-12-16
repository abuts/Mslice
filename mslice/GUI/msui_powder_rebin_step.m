function msui_powder_rebin_step(h_root,pos_u1step,pos_u2step,interlines,white)
% the function responsible for creating and displaying powder rebin menu 
% e.g. dx and dy rebin steps and acompanying information
%
%
%  $Revision: 57 $   ($Date: 2010-01-08 17:22:35 +0000 (Fri, 08 Jan 2010) $)
%

this_name = 'powder_rebin_step';
mslice_gui = msui_collection(h_root,'mslice_gui');
if exist(mslice_gui,this_name)
     %pos = get_line_pos(get(mslice_gui,this_name)); 
%    pos   = pos_u1step; % WRONG!
    return;
end

pos   = pos_u1step;
%height= pos_u1step(4);
width = pos(3);
%pos(2) =pos_u1step(2)-height;

hb = cell(4,1);

%========= Display dx_step ==================
%

hb{1}=uicontrol('Parent',h_root,'Style','text','String','dx  ',...
	'Tag','ms_disp_dx_step_tag',...
  	'Position',pos+[0 0 0 0],'Visible','off');
hb{2}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_dx_step',...
 	'Position',pos+[width 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');

%========= Display dy_step ==================
pos     = pos_u2step;
hb{3}=uicontrol('Parent',h_root,'Style','text','String','dy  ',...
	'Tag','ms_disp_dy_step_tag',...
  	'Position',pos+[0 0 0 0],'Visible','off');
hb{4}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_disp_dy_step',...
 	'Position',pos+[width 0 0 interlines],...
  	'HorizontalAlignment','left',...
  	'BackgroundColor',white,'Visible','off');


% create graphic elements colllection
rebin_steps =graph_objects_collection(this_name);
% add the handles to the collection and add collection to the mslice_gui;
rebin_steps = add_handles(rebin_steps,hb);
add(mslice_gui,rebin_steps);
get_line_pos(rebin_steps); 
