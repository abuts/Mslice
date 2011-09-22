function  msui_powder_menu(h_root,position,white,analmode,sample)
%
% remove the part of ui responsible for crystal analysis
mslice_gui = msui_collection(h_root,'mslice_gui');
mslice_gui = delete(mslice_gui,{'cryst_analysis_psd','cryst_analysis_nonpsd','detector_type_psd'});
if sample==2
    mslice_gui=delete(mslice_gui,{'single_crystal_gui','analysis_mode'});
end

width      = position(3);
height      = position(4);
oneline    = [0,height,0,0];
interlines = 0;

pos    =position-1.5*oneline;
% build select axis block
pos=msui_powder_select_axis(h_root,pos,white);

%build slice block
% LOAD COLOR TAB
global coltab;
if isempty(coltab)
    load coltab.dat -ascii;
end
pos(3) = width;
pos     = msui_powder_display_slice(pos,h_root,oneline,interlines,white,coltab);

% build cut block;
pos =ui_powder_cut(pos,h_root,oneline,interlines,white,sample);

% cut output block -- the same for crystall and powder mode, so does its
% own existance check;
pos(2)  = pos(2)-0.1*height;
msui_cut_output(pos,h_root,oneline,interlines,white,sample);

if (analmode == 2)  % powder;
     delete(mslice_gui,'delta_phi_range');
end
 
if (analmode == 3)  % powder remap;
    % if it has been created above, mslice_gui knows nothing about it here; need to retrieve it from fig singleton; 
    axis_selection =get(msui_collection(h_root,'mslice_gui'),'powder_axis'); 
    r_max = axis_selection.r_max;
    position(1) = pos(1) + 3*width;
    position(2) = r_max(2)-height;

    msui_delta_phi_range(h_root,position, white);
end


%
%
function pos =ui_powder_cut(pos,h_root,oneline,interlines,white,sample)

this_name = 'powder_cut';
mslice_gui = msui_collection(h_root,'mslice_gui');
if exist(mslice_gui,this_name)
     pos = get_line_pos(get(mslice_gui,this_name)); 
    return;
end

% Defube all graphical elements of powder cut. 
hc=cell(10,1);
width = pos(3);
height= pos(4);
%========= Cut  ==================
pos(2)=pos(2)-height;
hc{1}=uicontrol('Parent',h_root,'Style','text','String','Cut',...
                      'Position',pos,'BackgroundColor',white,'Visible','off');

%========= Cut axis, vx_min, vx_max ==================
pos=pos-oneline;
hc{2}=uicontrol('Parent',h_root,'Style','text','String',' along axis ',...
                      'Position',pos,'Visible','off');
%
pos(3)=width;
        %Axis selector
hc{3}=uicontrol('Parent',h_root,'Style','popupmenu','String',{'u1','u2'},...
                      'Tag','ms_cut_x',...
                      'Position',pos+[pos(3) 0 pos(3)*1/4 interlines],...
                      'HorizontalAlignment','left',...
                      'BackgroundColor',white,...
                      'Callback','ms_cut_axes;','Visible','off');
         %FROM
hc{5}=uicontrol('Parent',h_root,'Style','text','String','from',...
                      'Position',pos+[2*pos(3)+pos(3)*1/4 0 -pos(3)*1/4 0],'Visible','off');                  
hc{6}=uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_cut_vx_min',...
                     'Position',pos+[3*pos(3) 0 0 interlines],...
                     'HorizontalAlignment','left',...
                     'BackgroundColor',white,'Visible','off');
          %TO:
hc{7}=uicontrol('Parent',h_root,'Style','text','String','to',...
                       'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hc{8}=uicontrol('Parent',h_root,'Style','edit','Enable','on','Tag','ms_cut_vx_max',...
                      'Position',pos+[5*pos(3) 0 0 interlines],...
                      'HorizontalAlignment','left',...
                      'BackgroundColor',white,'Visible','off');
         %STEP:
hc{9}=uicontrol('Parent',h_root,'Style','text','String','step',...
                        'Position',pos+[6*pos(3) 0 0 0],'Visible','off');
hc{10}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_cut_bin_vx',...
                       'Position',pos+[7*pos(3) 0 0 interlines],...
                       'HorizontalAlignment','left',...
                        'BackgroundColor',white,'Visible','off');

%========= Cut vy_min, vy_max ==================
pos=pos-oneline;
hc{11}=uicontrol('Parent',h_root,'Style','text','String','thickness range',...
                    	'Tag','ms_cut_y_axis',...
                        'Position',pos+[pos(3) 0 pos(3) 0],'Visible','off');
hc{12}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_cut_vy_min',...
                       'Position',pos+[3*pos(3) 0 0 interlines],...
                       'HorizontalAlignment','left',...
                       'BackgroundColor',white,'Visible','off');
hc{13}=uicontrol('Parent',h_root,'Style','text','String','to',...
                      'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hc{14}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_cut_vy_max',...
                      'Position',pos+[5*pos(3) 0 0 interlines],...
                      'HorizontalAlignment','left',...
                      'BackgroundColor',white,'Visible','off');
hc{15}=uicontrol('Parent',h_root,'Style','text','String','Symbol',...
                      'Position',pos+[6*pos(3) 0 0 0],'Visible','off');
hc{16}=uicontrol('Parent',h_root,'Style','popupmenu','Tag','ms_cut_symbol_colour',...
                       'Position',pos+[7*pos(3) 0 0 interlines],...
                       'String',{'white','red','blue','magenta','green','cyan','yellow','black'},...
                       'BackgroundColor',white,'Visible','off');

%========= Cut Intensity range and Data Symbol ==================
pos=pos-oneline;
strings={'Intensity','Energy','|Q|','2Theta','Azimuth','Det Group Number'};
if (sample==1),	% single crystal sample anlysed as powder
   strings={'Intensity','Q_x','Q_y','Q_z','H','K','L','Energy','|Q|','2Theta','Azimuth','Det Group Number'};
end
hc{17}=uicontrol('Parent',h_root,'Style','popupmenu','String',strings,...
                        'Value',1,'BackgroundColor',white,'Tag','ms_cut_intensity',...
                        'Position',pos+[pos(3) 0 pos(3)*1/4 interlines],'Visible','off');
hc{18}=uicontrol('Parent',h_root,'Style','text','String','range*',...
                        'Position',pos+[(2+1/4)*pos(3) 0 -pos(3)*1/4 0],'Visible','off');
hc{19}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_cut_i_min',...
                        'Position',pos+[3*pos(3) 0 0 interlines],...
                        'HorizontalAlignment','left',...
                        'BackgroundColor',white,'Visible','off');
hc{20}=uicontrol('Parent',h_root,'Style','text','String','to *',...
                         'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hc{21}=uicontrol('Parent',h_root,'Style','edit','Tag','ms_cut_i_max',...
                         'Position',pos+[5*pos(3) 0 0 interlines],...
                         'HorizontalAlignment','left',...
                         'BackgroundColor',white,'Visible','off');
hc{22}=uicontrol('Parent',h_root,'Style','popupmenu','Tag','ms_cut_symbol_type',...
                        'Position',pos+[6*pos(3) 0 0 interlines],...
                        'String',{'circle o','square','diamond','pentagram','hexagram','star *','cross x','plus +',...
                        'triangle u','triangle d','triangle r','triangle l','point .'},...
                        'BackgroundColor',white,'Visible','off');
hc{23}=uicontrol('Parent',h_root,'Style','popupmenu','Tag','ms_cut_symbol_line',...
                        'Position',pos+[7*pos(3) 0 0 interlines],...
                       'String',{'no line','solid -','dashed --','dotted ..','dash-dot _.'},...
                       'BackgroundColor',white,'Visible','off');



 % create graphic elements colllection
powder_cut =graph_objects_collection(this_name);
% add the handles to the collection and add it to the mslice_gui;
add(mslice_gui,add_handles(powder_cut,hc));
