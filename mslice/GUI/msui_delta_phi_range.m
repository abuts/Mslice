function msui_delta_phi_range(h_root,position, white)
% function defines block of three test controls for phi range and places it
% in specified location wrt the root object
this_name='delta_phi_range';
mslice_gui = msui_collection(h_root,'mslice_gui');
if exist(mslice_gui,this_name)
    return
end

width      = position(3);
pos        = position;

h=uicontrol('Parent',h_root,'Style','text','String','2Theta:: min:','HorizontalAlignment','left','Visible','off');
delta_phi_block =graph_objects_collection(this_name,h,pos);

pos(3) = width;
delta_phi_block=add_right(delta_phi_block,...
                        uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_polar_min',...
   	                    'Position',pos,'HorizontalAlignment','left','BackgroundColor',white,'Visible','off'));

pos(3) = 0.5*width;
delta_phi_block=add_right(delta_phi_block,...
                         uicontrol('Parent',h_root,'Style','text','String','max:', 'Position',pos,'HorizontalAlignment','left','Visible','off'));


pos(3) = width;
delta_phi_block=add_right(delta_phi_block,...
                         uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_polar_max',...
   	                     'Position',pos,'HorizontalAlignment','left','BackgroundColor',white,'HorizontalAlignment','left','Visible','off'));

pos(3) = 0.5*width;
delta_phi_block=add_right(delta_phi_block,...
                        uicontrol('Parent',h_root,'Style','text','String','delta: ','Position',pos,'HorizontalAlignment','left','Visible','off'));
pos(3) = width;
delta_phi_block=add_right(delta_phi_block,...
                          uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_polar_delta',...
                          'Position',pos,'HorizontalAlignment','left','BackgroundColor',white,'HorizontalAlignment','left','Visible','off'));
                        
           
add(mslice_gui,delta_phi_block);

