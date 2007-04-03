function plot_MA(i_min,i_max,NLEVEL,NERROR,shad,map,linearlog)
% function plot_MA(i_min,i_max,NLEVEL,NERROR,shad,map,linearlog)
%
% produces a colourmap plot of the Multiresolution data 
% with a colour_axis in the range [i_min i_max], by default [min(intensity(:)) max(intensity(:))]
% to add more postscript printers to the list under 'ColorPrint' menu go to line 338 
%-----------------------------------------------------------
% Ibon Bustinduy [started in 09-July-2003]
%-----------------------------------------------------------
%___________________________________________________________________________________________
% More Info: 'A multiresolution data visualization tool for applications in neutron 
%             time-of-flight spectroscopy' Nuclear Instruments and Methods
%             2005.
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/2.0/ 
% or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
%___________________________________________________________________________________________


h_ma=findobj('Tag','plot_MA');
if isempty(h_ma),
   disp('''plot_MA'' window not active: type ms_MA first.');
   return;
end

MA_d=get(h_ma,'UserData');

 
% fig=findobj('Tag','ms_ControlWindow');
% if isempty(fig),
%    disp('Control Window not active: Open Mslice first.');
%    return;
% end
%h=findobj(fig,'tag','ms_slice_data');
%MA_d=get(h,'UserData');

%-----------------------------------------------------------
 
% === return if slice_d is empty
if isempty(MA_d),
   disp('## MA_d contains no data. Plot not performed.');
   return;
end
 

% ==== establish limits for the caxis (colour range along the intensity axis)
if ~exist('i_min','var')|isempty(i_min)|~isnumeric(i_min)|(length(i_min)~=1),
    %disp('dentro i_min *1*');
   i_min=min(MA_d.SS(:));
end
if ~exist('i_max','var')|isempty(i_max)|~isnumeric(i_max)|(length(i_max)~=1),
    %disp('dentro i_max *1*');
   i_max=max(MA_d.SS(:));
   if i_max-i_min<eps,
      i_min=min(0,i_min);
      
   end
end


fig=findobj('Tag','plot_MA');
if isempty(fig),
   colordef none;
   fig=figure('Tag','plot_MA','PaperPositionMode','auto','Name',':: MULTIRESOLUTION Slice ::','Renderer','zbuffer',...
       'Position',[560    395   450   350]);
   
   % === find any old plot slice figure and set current figure size to match 
   % === the dimensions of the last old figure of the same type
   oldfig=findobj('Tag','old_plot_MA'); 
   if ~isempty(oldfig),
      oldfig=sort(oldfig);
      set(fig,'Position',get(oldfig(length(oldfig)),'Position'));
   end
else
        figure(fig);
        clf;
end


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


%%%%% FRAME for the ERR/S controls...
ft_dir = uicontrol(gcf,...
'Style','frame',...
'BackgroundColor',[0.5,0.5,0.5],...
'Units','normalized','Position',[0.01 0.01 0.98 0.2]);
%%%%% FRAME for the x y controls...
ft_dir = uicontrol(gcf,...
'Style','frame',...
'BackgroundColor',[0.5,0.5,0.5],...
'Units','normalized','Position',[0.02 0.02 0.73 0.13]);

% %%%%% FRAME for the OTHER controls...
ft_dir = uicontrol(gcf,...
'Style','frame',...
'BackgroundColor',[0.1,0.1,0.1],...
'Units','normalized','Position',[0.76 0.01 0.15 0.2]);

% %%%%% FRAME for the axes...
% ft_dir = uicontrol(gcf,...
% 'Style','frame',...
% 'Units','normalized','Position',[0.01 0.19 0.8 0.8]);

%%%%% AXES
h_axes = axes(...
'Units','normalized',...
'Position',[0.11 0.27 0.8 0.65],...
'Tag','axes1');

% %%%%% FRAME for the intensity slidebar...
% ft_dir = uicontrol(gcf,...
% 'Style','frame',...
% 'Units','normalized','Position',[0.83 0.01 0.16 0.98]);



%========= Calculate Projections ==================
h=uicontrol('Parent',fig,'Style','pushbutton','String','GO',...
   'Callback','msma',...
   'Units','normalized','Position',[0.93 0.14 0.05 0.05]);

%%%%% LABEL for the ERR/S controls...
ERR_label = uicontrol(gcf,...
'Style','text',...
'BackgroundColor','yellow',...
'FontSize',8,'FontName','Arial',...
'String','ERR/S',...
'Tag','ERR_label',...
'Units','normalized','Position',[0.84 0.15 0.05 0.05]);

%%%%% TEXT EDITOR for the ERR/S controls...
ERR_te = uicontrol(gcf,...
'Style','edit',...
'BackgroundColor','yellow',...
'FontSize',8,'FontName','Arial',...
'String',NERROR,...
'Tag','ERR_te',...
'Units','normalized','Position',[0.84 0.09 0.05 0.05],...
'CallBack','micall_MA(gcf,''ERR_te'')');

%%%%% SLIDER for the ERR/S 
ERR_slider = uicontrol(gcf,'Style','slider','Units','normalized','Position',[0.84 0.03 0.05 0.05],...
'Min',0,'Max',9e9,'Value',NERROR,...
'Tag','ERR_slider',...
'CallBack','micall_MA(gcf,''ERR_slider'')');


%%%%% LABEL for the NLEVEL controls...
NLEVEL_label = uicontrol(gcf,...
'Style','text',...
'BackgroundColor','red',...
'FontSize',8,'FontName','Arial',...
'String','NLEVEL',...
'Tag','NLEVEL_label',...
'Units','normalized','Position',[0.77 0.15 0.05 0.05]);

%%%%% TEXT EDITOR for the NLEVEL controls...
NLEVEL_te = uicontrol(gcf,...
'Style','edit',...
'BackgroundColor','red',...
'FontSize',8,'FontName','Arial',...
'String',NLEVEL,...
'Tag','NLEVEL_te',...
'Units','normalized','Position',[0.77 0.09 0.05 0.05],...
'CallBack',...
'micall_MA(gcf,''NLEVEL_te'')');

%%%%% SLIDER for the NLEVEL 
NLEVEL_slider = uicontrol(gcf,'Style','slider','Units','normalized','Position',[0.77 0.03 0.05 0.05],...
'Min',1,'Max',11,'Value',NLEVEL,'SliderStep',[0.1,0.2],...
'Tag','NLEVEL_slider',...
'CallBack','micall_MA(gcf,''NLEVEL_slider'')');



%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
z=MA_d.z;
vz_min=MA_d.slice(1);
vz_max=MA_d.slice(2);
vx_min=MA_d.slice(3);
vx_max=MA_d.slice(4);
bin_vx=MA_d.slice(5);
vy_min=MA_d.slice(6);
vy_max=MA_d.slice(7);
bin_vy=MA_d.slice(8);

%========= Slice plane, vz_min, vz_max ==================

   h=uicontrol(gcf,'Style','text','String','perp to axis',...
   	'Units','normalized','Position',[0.02 0.15 0.08 0.05]);

	h=uicontrol(gcf,'Style','popupmenu','String',{MA_d.axis_label},...
	    'Tag','MA_z',...
        'Value',z,...
  	 	'Units','normalized','Position',[0.10 0.15 0.08 0.05],...
   	'HorizontalAlignment','left',...
   	'BackgroundColor','white',...
   	'Callback','ms_updatelabel_MA;');

	h=uicontrol(gcf,'Style','text','String','thickness ',...
  		'Units','normalized','Position',[0.22 0.15 0.08 0.05]);
    
	h=uicontrol(gcf,'Style','edit','Enable','on','Tag','MA_vz_min',...
   	'Units','normalized','Position',[0.30 0.15 0.08 0.05],...
    'String',vz_min,...
    'HorizontalAlignment','left',...
   	'BackgroundColor','white');

	h=uicontrol(gcf,'Style','text','String','to',...
  		'Units','normalized','Position',[0.42 0.15 0.08 0.05]);
    
	h=uicontrol(gcf,'Style','edit','Enable','on','Tag','MA_vz_max',...
   	'Units','normalized','Position',[0.50 0.15 0.08 0.05],...
    'String',vz_max,...
    'HorizontalAlignment','left',...
    'BackgroundColor','white');


%========= Slice/Display vx_min, vx_max, bin_vx ==================
   h=uicontrol('Parent',fig,'Style','text','String','horizontal range ',...
		'Tag','MA_x_axis',...
   	    'Units','normalized','Position',[0.02 0.09 0.08 0.05]);

	h=uicontrol('Parent',fig,'Style','edit','Tag','MA_vx_min',...
  	 	'Units','normalized','Position',[0.10 0.09 0.08 0.05],...
        'String',vx_min,...
   	    'HorizontalAlignment','left',...
   	    'BackGroundColor',[1,1,1]);

	h=uicontrol('Parent',fig,'Style','text','String','to',...
   	    'Units','normalized','Position',[0.22 0.09 0.08 0.05]);

	h=uicontrol('Parent',fig,'Style','edit','Tag','MA_vx_max',...
   	    'Units','normalized','Position',[0.30 0.09 0.08 0.05],...
   	    'String',vx_max,...
        'HorizontalAlignment','left',...
   	    'BackGroundColor',[1,1,1]);

	h=uicontrol('Parent',fig,'Style','text','String','from dx=',...
   	    'Units','normalized','Position',[0.42 0.09 0.08 0.05]);

	MA_bin_vx=uicontrol('Parent',fig,'Style','edit','Tag','MA_bin_vx',...
   	    'Units','normalized','Position',[0.50 0.09 0.08 0.05],...
   	    'String',bin_vx,...
        'HorizontalAlignment','left',...
   	    'BackgroundColor',[1,1,1]);

    h=uicontrol('Parent',fig,'Style','text','String','up to Dx=',...
        'Tag','MA_bin_vx_minlabel',...
   	    'Units','normalized','Position',[0.58 0.09 0.08 0.05],'BackgroundColor',[0.8,0.8,0.8]);
    
    MA_bin_vx_min=uicontrol('Parent',fig,'Style','text','String','up to..',...
        'Tag','MA_bin_vx_min',...
   	    'Units','normalized','Position',[0.66 0.09 0.08 0.05],'BackgroundColor',[1,1,1],'ForeGroundColor',[1,0,0]);

%========= Slice/Display vy_min, vy_max, bin_vy ==================
% PDS detectors
	h=uicontrol('Parent',fig,'Style','text','String','vertical range',...
  	'Tag','MA_y_axis',...
   	'Units','normalized','Position',[0.02 0.03 0.08 0.05]);

	h=uicontrol('Parent',fig,'Style','edit','Tag','MA_vy_min',...
   	'Units','normalized','Position',[0.10 0.03 0.08 0.05],...
    'String',vy_min,...
   	'HorizontalAlignment','left',...
   	'BackgroundColor',[1,1,1]);

    h=uicontrol('Parent',fig,'Style','text','String','to',...
   	'Units','normalized','Position',[0.22 0.03 0.08 0.05]);

	h=uicontrol('Parent',fig,'Style','edit','Tag','MA_vy_max',...
   	'Units','normalized','Position',[0.30 0.03 0.08 0.05],...
    'String',vy_max,...
    'HorizontalAlignment','left',...
   	'BackgroundColor',[1,1,1]);

	h=uicontrol('Parent',fig,'Style','text','String','from dy=',...
   	'Units','normalized','Position',[0.42 0.03 0.08 0.05]);

	MA_bin_vy=uicontrol('Parent',fig,'Style','edit','Tag','MA_bin_vy',...
   	'Units','normalized','Position',[0.50 0.03 0.08 0.05],...
    'String',bin_vy,...
   	'HorizontalAlignment','left',...
   	'BackgroundColor',[1,1,1]);

	h=uicontrol('Parent',fig,'Style','text','String','up to Dy=',...
    'Tag','MA_bin_vy_minlabel',...
    'Units','normalized','Position',[0.58 0.03 0.08 0.05],'BackgroundColor',[0.8,0.8,0.8]);

	MA_bin_vy_min=uicontrol('Parent',fig,'Style','text','String','up to',...
    'Tag','MA_bin_vy_min',...
    'Units','normalized','Position',[0.66 0.03 0.08 0.05],'BackgroundColor',[1,1,1],'ForeGroundColor',[1,0,0]);




nl=str2double(get(NLEVEL_te,'String'));
dx=str2double(get(MA_bin_vx,'String'));
dy=str2double(get(MA_bin_vy,'String'));

Dx=dx.*(2.^(nl-1));
Dy=dy.*(2.^(nl-1));

set(MA_bin_vx_min,'String',Dx);
set(MA_bin_vy_min,'String',Dy);


ms_updatelabel_MA


%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%--------------------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% % === create menu option to be able to do colour hardcopy printouts   
% h=uimenu(fig,'Label','ColourPrint','Tag','Color_Print','Enable','on');
% uimenu(h,'Label','Phaser560','Callback','ms_printc('' \\NDAIRETON\Phaser560:'');');
% uimenu(h,'Label','Phaser0','Callback','ms_printc('' \\NDAIRETON\Phaser0:'');');
% uimenu(h,'Label','DACColour','Callback','ms_printc('' \\NDAIRETON\DACColour:'');');
% uimenu(h,'Label','CRISPColour','Callback','ms_printc('' \\NDAIRETON\CRISPColour:'');');      
% uimenu(h,'Label','MAPSColour','Callback','ms_printc('' \\NDAIRETON\MAPSColour:'');');      
% uimenu(h,'Label','R3-COL00','Callback','ms_printc('' \\ndablagrave\R3-COL00'');'); 
% %=== TO ADD ANOTHER POSTSCRIPT PRINTER IN THIS LIST INSERT ANOTHER LINE AS ABOVE AND 
% %=== EDIT NAME (LABEL) 'Phaser0' AND NETWORK PATH '' \\NDAIRETON\Phaser0:''
% uimenu(h,'Label','default printer','Callback','ms_printc;');   
% % % === create menu option to be able to keep figure
% % h=uimenu(fig,'Label','Keep','Tag','keep','Enable','on');
% % uimenu(h,'Label','Keep figure','Callback','keep(gcf);');
% % % === create menu option to be able to make old slice figures current
% % h=uimenu(fig,'Label','Make Current','Tag','make_cur','Enable','off');
% % uimenu(h,'Label','Make Figure Current','Callback','make_cur(gcf);');


%========== Top Menu : About ==========================
hmenu=uimenu(fig,'Label','About');
hmenu1=uimenu(hmenu,'Label','__________________________________________________________________');
hmenu1=uimenu(hmenu,'Label',['Multiresolution version 0.3']);
hmenu1=uimenu(hmenu,'Label', 'Mslice add-on Software for Single Crystal Time-of-Flight Neutron ');
hmenu1=uimenu(hmenu,'Label', 'Data using Position Sensitive Detectors');
hmenu1=uimenu(hmenu,'Label', '-written by ibon bustinduy from 2003 to 2005-');
hmenu1=uimenu(hmenu,'Label','__________________________________________________________________');
hmenu1=uimenu(hmenu,'Label','           [Centro Superior de Investigaciones Cientificas, Spain]');
hmenu1=uimenu(hmenu,'Label','           [and ISIS Facility, Rutherford Appleton Laboratory, UK]');
hmenu1=uimenu(hmenu,'Label','           email : multiresolution@gmail.com');
hmenu1=uimenu(hmenu,'Label','           URL   : http://gtts.ehu.es:8080/Ibon/');
hmenu1=uimenu(hmenu,'Label','__________________________________________________________________');

% ==== plot the different layers from i_min to i_max
plotma(MA_d, i_min, i_max);

% === establish axis limits
axis([vx_min-bin_vx/2 vx_max+bin_vx/2 vy_min-bin_vy/2 vy_max+bin_vy/2 ]);

% ==== choose colormap
if exist('map','var')&isnumeric(map)&(size(map,2)==3),
   colormap(map);
else
   colormap jet;
end


% === set aspect ratio 1:1 if units along x and y are the same and {Å^{-1}}
if (~isempty(findstr(MA_d.axis_label2(1,:),'Å^{-1}')))&...
      (~isempty(findstr(MA_d.axis_label2(2,:),'Å^{-1}'))),
   set(gca,'DataAspectRatioMode','manual');
   a=get(gca,'DataAspectRatio');
   l1=MA_d.axis_unitlength(1);
   l2=MA_d.axis_unitlength(2);
   set(gca,'DataAspectRatio',[1/l1 1/l2 (1/l1+1/l2)/(a(1)+a(2))*a(3)]);
else
   set(gca,'dataAspectRatioMode','auto');
   a=get(gca,'DataAspectRatio');
   set(gca,'DataAspectRatioMode','manual');
   set(gca,'DataAspectRatio',[a(1) 1.15*a(2) a(3)]); 
   % arbitrarily set y scale bigger such that the graph will be scaled down verically and allow for title on top
end


% === put title and axis labels
h=title(MA_d.title);
YLim=get(gca,'YLim');
pos=get(h,'Position');
set(h,'Position',[pos(1) YLim(2)+0*pos(3) pos(3)]);
xlabel(deblank(MA_d.axis_label2(1,:)));
ylabel(deblank(MA_d.axis_label2(2,:)));

h=colorbar;
h_colourbar=h;
set(h,'Tag','Colorbar');
aspect=get(gca,'DataAspectRatio');
YLim=get(gca,'Ylim');
XLim=get(gca,'XLim');
pos=get(gca,'Position');
x=1/aspect(1)*[XLim(2)-XLim(1)];
y=1/aspect(2)*[YLim(2)-YLim(1)];
scx=pos(3)/x;
scy=pos(4)/y;
if scx<scy,
  	height=scx*y;	% real height of graph 
  	pos=get(h,'Position');
    set(h,'PlotBoxAspectRatio',[0.975*pos(3) height 1]); 
   % arbitrarily put a smaller scale along x to have colorbar height=graph height 
   % (probably tick label height is included in total length along y ?) 
end

h=h_colourbar;
% === establish linear or log colour scale
if exist('linearlog','var')&ischar(linearlog)&strcmp(linearlog(~isspace(linearlog)),'log'),
   set(h,'YScale','log');
   index=(MA_d.intensity==0);
   MA_d.intensity(index)=NaN;
   set(hplot,'Cdata',log10(MA_d.intensity));
   caxis([log10(i_min) log10(i_max)]);
else
   % === use linear scale and enable colour sliders
   % === put sliders for adjusting colour axis limits
   pos_h=get(h,'Position');
   range=abs(i_max-i_min);
   
 hh=uicontrol(fig,'Style','slider',...
     'Units',get(h,'Units'),'Position',[pos_h(1) pos_h(2) pos_h(3)*1.5 pos_h(4)/20],...
     'Min',i_min-range/2,'Max',i_max-range*0.1,...
     'SliderStep',[0.01/1.4*2 0.10/1.4],'Value',i_min,'Tag','color_slider_min','Callback','color_slider(gcf,''slider'')');  
     % the SliderStep is adjusted such that in real terms it is [0.02 0.10] of the displayed intensity range 
   
 hh_value=uicontrol(fig,'Style','edit',...
     'Units',get(h,'Units'),'Position',get(hh,'Position')+pos_h(3)*1.5*[1 0 0 0],...
     'String',num2str(get(hh,'Value')),'Tag','color_slider_min_value','Callback','color_slider(gcf,''min'')');
   
 hh=uicontrol(fig,'Style','slider',...
     'Units',get(h,'Units'),'Position',[pos_h(1) pos_h(2)+pos_h(4)-pos_h(4)/20 pos_h(3)*1.5 pos_h(4)/20],...
     'Min',i_min+range*0.1,'Max',i_max+range/2,...
     'SliderStep',[0.01/1.4*2 0.10/1.4],'Value',i_max,'Tag','color_slider_max','Callback','color_slider(gcf,''slider'')');
   
 hh_value=uicontrol(fig,'Style','edit',...
     'Units',get(h,'Units'),'Position',get(hh,'Position')+pos_h(3)*1.5*[1 0 0 0],...
     'String',num2str(get(hh,'Value')),'Tag','color_slider_max_value','Callback','color_slider(gcf,''max'')');
end
