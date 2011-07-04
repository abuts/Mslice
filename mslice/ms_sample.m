function ms_sample
% function ms_sample
% draw ControlWindow menu options according to the selected sample type 
%

% === if ControlWindow non-existent or Sample popupmenu not present, return
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   disp('ControlWindow non existent');
   return
end

% === identify sample type 
sampobj=findobj(fig,'Tag','ms_sample');
if isempty(sampobj),
   disp('Sample type could not be identified. Return');
   return;
end
sample=get(sampobj,'Value');	% =1 if single crystal sample, =2 if powder sample

% === get position parameters for a typical item displayed on the Control Window
pos=get(findobj(fig,'String','Sample'),'Position');
lineheight=pos(4);
oneline=[0 lineheight 0 0];
pos1=get(sampobj,'Position');
interlines=pos1(4)-lineheight;
pos=pos-oneline;
white=get(sampobj,'BackgroundColor');
%

% SAMPLE
if sample==1, % === sample is crystal, build menu options in ControlWindow      
    % build crystal description
    pos = ui_crystal_description(fig,pos,oneline,interlines,white);
    
	%========= Analysis mode  ==================
    msui_analysis_mode(fig,pos,oneline,interlines,white,{'single crystal','powder','powder_remap'});
    % start analysis mode selection; 	
    ms_analysis_mode;
   
  % === update detector trajectories axes  
   detobj=findobj(fig,'Tag','ms_det_type');
    if isempty(detobj),
       disp('Could not identify detector type for the single crystal sample in single crystal analysis mode. Return.');
       return;
    end
   
   % === by default in single crystal analysis mode
      psd=get(detobj,'Value');	%=1 psd , =2 conventional
	  if psd==1,		% single crystal + PSD detectors
         strings={'Q_x','Q_y','Q_z','H','K','L','u1','u2','u3','Energy','|Q|','2Theta','Azimuth','Det Group Number'};
         lineoffset=0;
	  elseif psd==2,	% single crystal + conventional detectors
        strings={'Q_x','Q_y','Q_z','H','K','L','u1','u2','Energy','|Q|','2Theta','Azimuth','Det Group Number'};
        lineoffset=2;
      else
        disp(['Single crystal sample with unknown type of detectors ' num2str(psd)]);
        return;
    end      
  
elseif sample==2,      % === sample is powder, draw menu options in ControlWindow   
    msui_analysis_mode(fig,pos,oneline,interlines,white,{'powder'});   
    % for powder, analysis mode can be only powder (2)
    msui_powder_menu(fig,pos,white,2,sample) ;
    
    
   % === update detector trajectories axes     
   lineoffset=2;
   strings={'Energy','|Q|','2Theta','Azimuth','Det Group Number'};    
else  % unknown sample
  disp(sprintf('Unknown sample type (=1 single crystal, =2 powder), not %g',sample)); 
end

% === update detector trajectories axes
 
% draw or refresh all Detector Trajectories menu structure 
msui_detector_tragectories(fig,oneline,lineoffset,interlines,white,strings,sample);


return;
% TODO: What is that?
%========= Note on Optional Parameters ==================
if isempty(findobj(fig,'String','* Optional Parameter')),
	figure(findobj('Tag','ms_ControlWindow'));
	pos=[0 0 pos(3) pos(4)]; 
	h=uicontrol('Parent',fig,'Style','text','String','* Optional Parameter',...
   	'Position',pos+[0 0 pos(3) 0]);
end


%
function pos=ui_crystal_description(fig,pos,oneline,interlines,white)

this_name = 'single_crystal_gui';
mslice_gui = get(findobj('Tag','mslice_gui'),'UserData');
if exist(mslice_gui,this_name)
    pos = get_line_pos(get(mslice_gui,this_name));
    return
end
width = pos(3);

hc=cell(20,1);
%========= Lattice parameters ==================
hc{1}=uicontrol('Parent',fig,'Style','text','String','Unit cell lattice parameters',...
	   'Position',pos+[0 0 1.5*pos(3) 0],'Visible','off');
	
%========= as bs cs (Angs)==================
pos=pos-oneline;
hc{2}=uicontrol('Parent',fig,'Style','text','String','a (Å)',...
	   'Position',pos,'Visible','off');
hc{3}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_as',...
	   'Position',pos+[pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{4}=uicontrol('Parent',fig,'Style','text','String','b (Å)',...
	   'Position',pos+[2*pos(3) 0 0 0],'Visible','off');
hc{5}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_bs',...
	   'Position',pos+[3*pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{6}=uicontrol('Parent',fig,'Style','text','String','c (Å)',...
	   'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hc{7}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_cs',...
	   'Position',pos+[5*pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
	
%========= aa bb cc (deg)==================
	pos=pos-oneline;
hc{8}=uicontrol('Parent',fig,'Style','text','String','aa (deg)',...
	   'Position',pos,'Visible','off');
hc{9}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_aa',...
	   'Position',pos+[pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{10}=uicontrol('Parent',fig,'Style','text','String','bb (deg)',...
	   'Position',pos+[2*pos(3) 0 0 0],'Visible','off');
hc{11}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_bb',...
	   'Position',pos+[3*pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{12}=uicontrol('Parent',fig,'Style','text','String','cc (deg)',...
	   'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hc{13}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_cc',...
	   'Position',pos+[5*pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
	
%========= Crystal orientation ==================
pos=pos-oneline;
hc{14}=uicontrol('Parent',fig,'Style','text',...
	   'String',...
	   'Crystal orientation:(u,v) reciprocal space axes in principal scattering plane (Qx || ki,Qy), i.e. u=[100]=a*,v=[010]=b*',...
	   'Position',pos+[-0.99*width, 0, 9*width, 0],'Visible','off');

%========= ux uy uz ==================
pos=pos-oneline;
hc{15}=uicontrol('Parent',fig,'Style','text','String','ux',...
	   'Position',pos,'Visible','off');
hc{16}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_ux',...
	   'Position',pos+[pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{17}=uicontrol('Parent',fig,'Style','text','String','uy',...
	   'Position',pos+[2*pos(3) 0 0 0],'Visible','off');
hc{18}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_uy',...
	   'Position',pos+[3*pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{19}=uicontrol('Parent',fig,'Style','text','String','uz',...
	   'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hc{20}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_uz',...
	   'Position',pos+[5*pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
	
%========= vx vy vz ==================
pos=pos-oneline;
hc{21}=uicontrol('Parent',fig,'Style','text','String','vx',...
	     'Position',pos,'Visible','off');
hc{22}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_vx',...
	   'Position',pos+[pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{23}=uicontrol('Parent',fig,'Style','text','String','vy',...
	   'Position',pos+[2*pos(3) 0 0 0],'Visible','off');
hc{24}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_vy',...
	   'Position',pos+[3*pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{25}=uicontrol('Parent',fig,'Style','text','String','vz',...
	   'Position',pos+[4*pos(3) 0 0 0],'Visible','off');
hc{26}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_vz',...
	   'Position',pos+[5*pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
	
%========= psi_samp (deg) ==================
pos=pos-oneline;
hc{27}=uicontrol('Parent',fig,'Style','text','String','Psi(deg)',...
	   'Position',pos,'Visible','off');
hc{28}=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_psi_samp',...
	   'Position',pos+[pos(3) 0 0 interlines],...
	   'HorizontalAlignment','left',...
	   'BackgroundColor',white,'Visible','off');
hc{29}=uicontrol('Parent',fig,'Style','text',...
	   'String',' angle between ki and u, +ve if (ki x u) || Q_z',...
	   'HorizontalAlignment','left','Position',pos+[2*pos(3) 0 6*pos(3) 0],'Visible','off');
	%extent=get(h,'Extent');
	%set(h,'Position',pos+[2*pos(3) 0 extent(3) 0])
   cryst = graph_objects_collection(this_name); 
   add(mslice_gui,add_handles(cryst,hc));
   
