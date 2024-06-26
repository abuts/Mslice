function detectorview
% function detectorview
% start DetectorView programme to 
% plot sum and mask files on top of the detector map in real space
% Radu Coldea 02-October-1999


% === define colours in RGB format
colordef white;
white=[1 1 1];
black=[0 0 0];
grey=[0.752941 0.752941 0.752941];

% === close previous DetectorView Windows
h=findobj('Tag','detectorview');
if ~isempty(h),
   disp(['Closing previous DetectorView windows']);
   delete(h);
end

% === draw DetectorView Window and establish positions and dimensions of menu items
fig=figure;
colordef none;
set(fig,'Name','DetectorView : Control Window',...
   'NumberTitle','off',...
   'Tag','detectorview',...
   'MenuBar','none','Resize','off');
h=uicontrol(fig,'Style','text','String','Spectrometer',...
   'BackgroundColor',grey);
pos=get(h,'Extent');
lineheight=pos(4);
interlines=ceil(lineheight/5);
nlines=7;
width=8*pos(3);
bottomx=6;
bottomy=500;

set(fig,'Position',[bottomx bottomy width lineheight*nlines+interlines*(nlines-1)]);
pos=[0 lineheight*(nlines-1)+interlines*(nlines-1) pos(3) pos(4)];
set(h,'Position',pos); 
oneline=[0 lineheight+0*interlines 0 0];
pos=pos-[0 interlines 0 0];

%========== Top Menu : Exit ===========================
hmenu=uimenu(fig,'Label','Exit');
uimenu(hmenu,'Label','Exit','Callback','close(gcf);');

%========== Top Menu : Help ===========================
%hmenu=uimenu(fig,'Label','Help');
%uimenu(hmenu,'Label','Display help file','Callback','type dv_help.txt ');

%========== Top Menu : About ==========================
hmenu=uimenu(fig,'Label','About DetectorView...');
hmenu1=uimenu(hmenu,'Label','DetectorView version 16-Sep-2000');
hmenu1=uimenu(hmenu,'Label','written by Radu Coldea (ORNL/ISIS)');
hmenu1=uimenu(hmenu,'Label','radu@isise.rl.ac.uk');

%========= spectrometer and bank =========
set(h,'String','SpectraMap','Position',pos);
h=uicontrol('Parent',fig,'Style','popupmenu','Enable','on','Tag','dv_spectramap',...
   'Position',pos+[pos(3) 0 pos(3) interlines],...
   'HorizontalAlignment','left',...
	'BackgroundColor',white,'String',{'HET PSD-4m'},'Value',1);
%  {'HET PSD-4m','HET 2m','MARI','MAPS','IRIS'}
%========= Sum File + Load Sum ==================
pos=pos-1.5*oneline;
h=uicontrol('Parent',fig,'Style','text','String',[pwd '\'],...
   'Position',pos,'Visible','off','Tag','dv_SumDir');
h=uicontrol('Parent',fig,'Style','text','String','SumFile(.sum)',...
   'Position',pos);
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','dv_SumFile',...
   'Position',pos+[pos(3) 0 2*pos(3) interlines],...
   'HorizontalAlignment','left',...
	'BackgroundColor',white,'UserData',[]);  % will contain loaded sum file
h=uicontrol('Parent',fig,'Style','pushbutton','String','Browse',...
   'Callback',...
   'ms_getfile(findobj(''Tag'',''dv_SumDir''),findobj(''Tag'',''dv_SumFile''),''*.sum'',''Choose Sum File'');',...
   'Position',pos+[4*pos(3) 0 0 0]);   
h=uicontrol('Parent',fig,'Style','pushbutton','String','Load Sum',...
   'Callback','dv_load_file(''Sum'');',...
   'Position',pos+[7*pos(3) 0 0 0]);   

% === intensity range + Plot Sum ====
pos=pos-oneline-[0 interlines 0 0];
h=uicontrol('Parent',fig,'Style','text','String','Intensity *',...
   'Position',pos+[0 interlines 0 0]);
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','dv_i_min',...
   'Position',pos+[pos(3) 0 0 interlines],...
   'HorizontalAlignment','left',...
   'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','text','String','to *',...
   'Position',pos+[2*pos(3) interlines -pos(3)/2 0]);
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','dv_i_max',...
   'Position',pos+[2.5*pos(3) 0 0 interlines],...
   'HorizontalAlignment','left',...
   'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','pushbutton','String','Plot Sum',...
   'Callback','dv_plot_sum;',...
   'Position',pos+[7*pos(3) interlines 0 0]);   

%========= MaskFile and Plot Mask pushbuttons ==============
pos=pos-1.5*oneline;
h=uicontrol('Parent',fig,'Style','text','String',[pwd '\'],...
   'Position',pos,'Visible','off','Tag','dv_MskDir');
h=uicontrol('Parent',fig,'Style','text','String','MskFile(.msk)',...
   'Position',pos);
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','dv_MskFile',...
   'Position',pos+[pos(3) 0 2*pos(3) interlines],...
   'HorizontalAlignment','left',...
	'BackgroundColor',white,'UserData',[]);  % will contain loaded msk file
h=uicontrol('Parent',fig,'Style','pushbutton','String','Browse',...
   'Callback',...
   'ms_getfile(findobj(''Tag'',''dv_MskDir''),findobj(''Tag'',''dv_MskFile''),''*.msk'',''Choose Mask File'');',...
   'Position',pos+[4*pos(3) 0 0 0]);   
h=uicontrol('Parent',fig,'Style','pushbutton','String','Load Mask',...
   'Callback','dv_load_file(''Msk'');',...
   'Position',pos+[7*pos(3) 0 0 0]);   

%========= Contour levels ==============
pos=pos-oneline-[0 interlines 0 0];
h=uicontrol('Parent',fig,'Style','Text','String','Contours',...
   'Position',pos+[0 interlines 0 0]);   
h=uicontrol('Parent',fig,'Style','popup','String',{'none','intensity'},...
   'Tag','dv_int_cont','Value',1,...
   'BackgroundColor','white',...
   'Position',pos+[pos(3) 0 0 interlines]);   
h=uicontrol('Parent',fig,'Style','text','String','from',...
	'Position',pos+[2*pos(3) interlines -pos(3)/2 0]);
h=uicontrol('Parent',fig,'Style','edit','Tag','dv_cont_min',...
	'Position',pos+[2.5*pos(3) 0 0 interlines],...
	'HorizontalAlignment','left',...
	'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','text','String','to',...
	'Position',pos+[3.5*pos(3) interlines -pos(3)/2 0]);
h=uicontrol('Parent',fig,'Style','edit','Tag','dv_cont_max',...
	'Position',pos+[4*pos(3) 0 0 interlines],...
	'HorizontalAlignment','left',...
 	'BackgroundColor',white);  
h=uicontrol('Parent',fig,'Style','text','String','step',...
	'Position',pos+[5*pos(3) interlines -pos(3)/2 0]);
h=uicontrol('Parent',fig,'Style','edit','Tag','dv_cont_step',...
	'Position',pos+[5.5*pos(3) 0  0 interlines],...
	'HorizontalAlignment','left',...
   'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','pushbutton','String','Plot Mask',...
   'Callback','dv_plot_msk;',...
   'Position',pos+[7*pos(3) interlines 0 0]);   

%========= threshold for futher masking ==============
pos=pos-oneline-[0 interlines 0 0];
h=uicontrol('Parent',fig,'Style','Text','String','Threshold',...
   'Position',pos+[0 interlines 0 0]); 
h=uicontrol('Parent',fig,'Style','edit','Tag','dv_threshold',...
	'Position',pos+[pos(3) 0 0 interlines],...
	'HorizontalAlignment','left',...
   'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','pushbutton','String','Mask Bellow Threshold',...
   'Callback','dv_mask;',...
   'Position',pos+[2*pos(3) interlines pos(3) 0]);   
h=uicontrol('Parent',fig,'Style','pushbutton','String','Save Mask',...
   'Callback','dv_save_msk;',...
   'Position',pos+[4*pos(3) interlines 0 0]);   











  