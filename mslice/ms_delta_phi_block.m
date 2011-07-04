function delta_phi_block = ui_delta_phi_range(h_root,position, white)
% function defines block of three test controls for phi range and places it
% in specified location wrt the root object

width =0.8*position(3);


pos    =position;
pos(3)=1.4*width;
h=uicontrol('Parent',h_root,'Style','text','String','2Theta::  min:','HorizontalAlignment','left','Visible','off');
delta_phi_block =graph_objects_collection(h,pos);

pos(3) = width;
delta_phi_block=add_right(delta_phi_block,...
                        uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_polar_min',...
   	                    'Position',pos,'HorizontalAlignment','left','BackgroundColor',white,'Visible','off'));

pos(3) = 0.5*width;
delta_phi_block=add_right(delta_phi_block,...
                         uicontrol('Parent',h_root,'Style','text','String','max:', 'Position',pos,'Visible','off'));


pos(3) = width;
delta_phi_block=add_right(delta_phi_block,...
                         uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_polar_max',...
   	                     'Position',pos,'HorizontalAlignment','left','BackgroundColor',white,'Visible','off'));

pos(3) = 0.8*width;
delta_phi_block=add_right(delta_phi_block,...
                        uicontrol('Parent',h_root,'Style','text','String','delta: ','Position',pos,'Visible','off'));
pos(3) = width;
delta_phi_block=add_right(delta_phi_block,...
                          uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_polar_delta',...
                        	'Position',pos,'HorizontalAlignment','left','BackgroundColor',white,'Visible','off'));
                        
make_visible(delta_phi_block);                     

end

