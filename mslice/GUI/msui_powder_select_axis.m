function pos     = msui_powder_select_axis(h_root,pos,white)

this_name = 'powder_axis';
mslice_gui = msui_collection(h_root,'mslice_gui');
if exist(mslice_gui,this_name)
     pos = get_line_pos(get(mslice_gui,this_name)); 
    return;
end

width = pos(3);
%========= Viewing Axes + Label ==================
axis_cel = graph_objects_collection(this_name,...
                                    uicontrol('Parent',h_root,'Style','text','String','Viewing Axes',...
                                    'Position',pos,'BackgroundColor',white,'Visible','off'));
axis_cel =add_right(axis_cel ,...
                                    uicontrol('Parent',h_root,'Style','text','String','Selection',...
                                     'Visible','off'));                                                       
axis_cel=add_right(axis_cel ,...
                                    uicontrol('Parent',h_root,'Style','text','String','Label',...
                                     'BackgroundColor',white,'Position',pos+[0,0,width,0],'Visible','off'));                                                        
%========= u1  ==================
AxisNames={'Energy','|Q|','2Theta','Azimuth','Det Group Number'};
%
u1_row =graph_objects_collection('u1_row',...,
                 uicontrol('Parent',h_root,'Style','text','String','u1','Position',pos,'Visible','off'));
grey = get(u1_row.handles{1},'BackgroundColor');

u1_row =add_right(u1_row,...
                 uicontrol('Parent',h_root,'Style','popupmenu','Tag','ms_u1',...
                              'HorizontalAlignment','left',...
                              'BackgroundColor',white,'String',AxisNames,'Value',2,...
                              'Callback',{@powder_update_selection,1},'Visible','off')); 
u1_row =add_right(u1_row,...                          
                uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_u1label',...
                               'HorizontalAlignment','left','Callback',{@powder_updatelabel,1},...
                              'BackgroundColor',white,'Position',pos+[0,0,width,0],'String','u1','Visible','off'));    
axis_cel= add_collection(axis_cel,u1_row,[0,-1]);

%========= u2  ==================
u2_row =graph_objects_collection('u2_row',...,
               uicontrol('Parent',h_root,'Style','text','String','u2','Position',pos,'Visible','off'));
u2_row =add_right(u2_row,...
              uicontrol('Parent',h_root,'Style','popupmenu','Tag','ms_u2',...
                             'HorizontalAlignment','left',...
                            'BackgroundColor',white,'String',AxisNames,'Value',1,...
                         	'Callback',{@powder_update_selection,2},'Visible','off'));
u2_row =add_right(u2_row,...
             uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_u2label',...
                           'HorizontalAlignment','left','Callback',{@powder_updatelabel,2},...
                          'BackgroundColor',white,'Position',pos+[0,0,width,0],'String','u2','Visible','off'));
axis_cel= add_collection(axis_cel,u2_row,[0,-1]);

col_width = [width,width,0.7*width];
axis_cel=set_width(axis_cel,col_width);
height = pos(4);
axis_cel=add_bottom(axis_cel,...
              uicontrol('Parent',h_root,'Style','frame','Position',[0,0,sum(col_width),0.4*height],...
             'ForegroundColor',grey,'Visible','off'));

%========= Calculate Projections Button ==================
r_min = axis_cel.r_min;
r0       = [r_min(1)+6*width,r_min(2)];
pos(1:2)=r0;
pos(3)   =2*width;

h=uicontrol('Parent',h_root,'Style','pushbutton','String','Calculate Projections',...
   'Callback','ms_calc_proj;',...
   'Position',pos,'Visible','off'); 
axis_cel= add_handles(axis_cel,h);


% add the handles to the collection and add it to the mslice_gui;
add(mslice_gui,axis_cel);       
pos(1:2) = axis_cel.r_min;


%%=========
function powder_update_selection(hAxis1,event,n) %#ok<INUSD>
value1 = get(hAxis1,'Value');
labels   =get(hAxis1,'String');

% find label object and set its label accordingly
hLabeld=findobj('Tag',['ms_u',num2str(n),'label']);
if isempty(hLabeld)
    error('MSLICE:gui_powder_select_axis',' can not find label for axis %d',n);
end
powder_updatelabel(hLabeld,event,n,labels{value1});
% find second object and verify if it has the same label
nn=n+1; 
if (nn>2) ; nn=1; end

hAxis2=findobj('Tag',['ms_u',num2str(nn)]);
value2 = get(hAxis2,'Value');

if(value1==value2) % have to change settings for label2
    all_labels = get(hAxis1,'String');
    value2=value1+1;
    if value2>numel(all_labels)
        value2=1;
    end
    % this also seta change selection 2 and modify its labels;
    set(hAxis2,'Value',value2);
    
    powder_update_selection(hAxis2,event,nn);
end

function powder_updatelabel(hLabel,event,n,theLabel) %#ok<INUSD>
if exist('theLabel','var') % set the label value from the agruments;
    set(hLabel,'String',theLabel);    
else   % the function ivoked from uicontrol and  we need to get the label from the uicontrol
    theLabel = get(hLabel,'String');
end



% update dependent fields in other gui elements;

% MODIFY DISPLAY AXIS
switch n
    case 1
        labelx=get(findobj('Tag','ms_u1label'),'String');
        set(findobj('Tag','ms_disp_x_axis'),'String',['horizontal range* ' labelx ]);
        % clear limits in display range box
        ms_setvalue('disp_vx_min','');
        ms_setvalue('disp_vx_max','');
        ms_setvalue('disp_dx_step','');        
    case 2
        labely=get(findobj('Tag','ms_u2label'),'String');
        set(findobj('Tag','ms_disp_y_axis'),'String',['vertical range* ' labely ]);
        ms_setvalue('disp_vy_min','');
        ms_setvalue('disp_vy_max','');
        ms_setvalue('disp_dy_step','');                
    otherwise
        error('MSUI_POWDER_SELECT_AXIS:updatelabel',' unknown option %d while trying to updated powder axis labels',n);
end

% update cut along axis selection list
hCutLabels=findobj('Tag','ms_cut_x');
cutLabels    =get(hCutLabels,'String');
cutLabels{n} = theLabel;
set(hCutLabels,'String',cutLabels);

ms_cut_axes;

