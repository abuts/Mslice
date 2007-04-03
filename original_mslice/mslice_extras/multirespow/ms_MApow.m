function ms_MApow(NLEVEL, NS);
% function ms_MApow(NLEVEL, NS);
%
% Once the mslice program has been launched, and projection on to viewing axes performed
% we can calculate a multiresolution slice, (i.e: an adaptive binning routine to bin pixels  
% locally, up to an acceptable minimum S/N ratio while preserving high statistics areas from 
% being unnecessarily binned).
% 
% Syntax
%           ms_MApow(NLEVEL, NS)
%           ms_MApow(NLEVEL)
%           ms_MApow
%
% Description 
%           ms_MApow(NLEVEL, NS) display a multiresolution slice, where NLEVEL= number of levels 
%           the algorithm will cover. Starting from Dx, Dy (loaded from MSlice Control Window)
%           to dx= Dx/(2.^(NLEVEL-1)), dy= Dy/(2.^(NLEVEL-1)). where NS is the noise-to-signal 
%           ratio; ERR/S. That will act as a threshold. Resulting in a image, which ERR/S is
%           below the imposed value NS.
%
%           ms_MApow(NLEVEL) NS will be considered to be equal = 1, thus: ERR/S =100%. Only those 
%           pixels above 100% ratio will not be collected.
%           
%           ms_MApow(NLEVEL) NS will be considered to be equal = 1, thus: ERR/S =100%. Only those 
%           pixels above 100% ratio will not be collected. and NELEVEL will be considered by 
%           default to be equal 1, i.e: no multiresolution. dx, and dy, will be equal width         
%           along the entire image.
%
%                       
% all the data information as well as limits information, will be collected from MSlice Control Window,
% so if Control Window is not present, return.
%
%
%___________________________________________________________________________________________
% More Info: 
% I. Bustinduy, F.J. Bermejo, T.G. Perring, G. Bordel
% A multiresolution data visualization tool for applications in neutron time-of-flight spectroscopy
% Nuclear Inst. and Methods in Physics Research, A. 546 (2005)  498-508.
%
% Author information: Ibon Bustinduy [multiresolution@gmail.com]
%                URL: http://gtts.ehu.es:8080/Ibon/ISIS/multires.htm
%
%___________________________________________________________________________________________
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/2.0/ 
% or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
%___________________________________________________________________________________________


fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   disp('## Control Window not active: Open Mslice first.');
   return;
end

if ~exist('NLEVEL','var')|isempty(NLEVEL)|~isnumeric(NLEVEL)|(length(NLEVEL)~=1)
   NLEVEL=1;   
end

if ~exist('NS','var')|isempty(NS)|~isnumeric(NS)|(length(NS)~=1)
   NS=1;
end

% === if clear request given, clear slice data and return
if exist('cmd','var')&ischar(cmd)&strcmp(lower(cmd(~isspace(cmd))),'clear'),
   % disp('Clearing stored slice data.')
   h=findobj(fig,'tag','MA_d');
   if isempty(h)|~ishandle(h),
      disp('## Could not locate object storing slice data. Return.');
      return;
   end
   set(h,'UserData',[]);
   return;
end

data=get(fig,'UserData');



if isempty(data),
   % === no data loaded
   disp('## Load data first, then do slice.');
   return;
elseif isstruct(data),
   % == one data set only
   if ~isfield(data,'S')|isempty(data.S),
   	disp('## Loaded data set has no intensity matrix. Load data again.');
      return;
   elseif ~isfield(data,'v')|isempty(data.v),
      disp(['## Calculate projections first and then take slices.']);
      return;
   end   
elseif iscell(data),
   % === multiple data sets
   for i=1:length(data),
      if ~isfield(data{i},'S')|isempty(data{i}.S),
         disp(['## No intensity matrix in data set ' num2str(i) '. Construct set again.']);
         return;
      elseif ~isfield(data{i},'v')|isempty(data{i}.v),
         disp(['## Calculate projections for set ' num2str(i) ', then do MA.']);
         return;
     elseif ~isfield(data{i},'ERR')|isempty(data{i}.ERR),
         disp(['## No error matrix in data set ' num2str(i) '. Construct set again.']);
         return;
      end
    end
end



samp=get(findobj(fig,'Tag','ms_sample'),'Value');
if samp==1,
   analmode=get(findobj('Tag','ms_analysis_mode'),'Value');
end  

if samp==1,%sample is crystal
   if analmode==2,	% analysed as powder
       vars=str2mat(vars,'u1','u1label','u2','u2label');
   else	% analysed as single crystal
          disp('## This subrutine is for powder samples or ')
          disp('   single crystals Analysed as powder. Return.')
          return;
   end
end  

if samp==2,	%sample is powder 
    disp('## Analysing powder sample')
    vars=str2mat('u1','u1label','u2','u2label','efixed','emode','IntensityLabel','TitleLabel');
end


% << ===== read relevant parameters from ControlWindow
for i=1:size(vars,1),
   name=vars(i,:);
   name=name(~isspace(name));
   h=findobj(fig,'Tag',['ms_' name]);
   if isempty(h),
      disp(['Warning: Object ms_' name 'not found;']);
   end;   
   if strcmp(get(h,'Style'),'popupmenu')|strcmp(get(h,'Style'),'checkbox'),
      value=num2str(get(h,'Value'));
   	eval([ name '=' value ';']);   
   else
      value=get(h,'String');
      if strcmp(name,'u1label')|strcmp(name,'u2label')|((samp==1)&(analmode==1)&psd&strcmp(name,'u3label'))|strcmp(name,'IntensityLabel')|...
            strcmp(name,'TitleLabel'),		% interpret value as a string
         if isempty(value),
  				eval([name '=[];']);
			else          
            eval([ name '=''' value ''';']);
         %   disp([name ' gets value ' value ]);
         end
      else	% transform string into number
         if isempty(value), 
           	eval([name '=[];']);
         else
            eval([name '=' value ';']);
         end
      end         
   end
end


% === read disp parameters from ControlWindow
vars=str2mat('vx_min','vx_max','vy_min','vy_max');
vars=str2mat(vars,'i_min','i_max');
vars=str2mat(vars,'colmap','nsmooth','shad');
for i=1:size(vars,1),
   name=vars(i,:);
   name=name(~isspace(name));
   h=findobj('Tag',['ms_disp_' name]);
   if strcmp(get(h,'Style'),'popupmenu')|strcmp(get(h,'Style'),'checkbox'),
      value=num2str(get(h,'Value'));
   else
      value=get(h,'String');
      value=value(~isspace(value));
   end
   if ~isempty(value),	    
      eval([ name '=' value ';']); 
   else
      eval([name '=[];']);
   end
end


% >> ===== read parameters from ControlWindow

axis_label=str2mat(u1label,u2label);
axis_unitlabel=str2mat('','',IntensityLabel);
title_label=TitleLabel;


disp('## loading data from MSlice...');


int=reshape(data.S,[],1);
err=reshape(data.ERR,[],1);

[m,n]=size(data.S);

vx=[1:n];
vy=[1:m];
[vx,vy]=meshgrid(vx,vy);
vx=reshape(vx,[],1);
vy=reshape(vy,[],1);

%by default we will use it as a 'no-multiresolution situation'
%NLEVEL=9; 
%NS=1;

vxmin_min=1;
bin_vx_min=1;
vymin_min=1;
bin_vy_min=1;

n_min = n;
m_min = m;
n=ceil(n_min./(2.^(NLEVEL-1)));
m=ceil(m_min./(2.^(NLEVEL-1)));

fix_x=logical(0);
fix_y=logical(0);

if(fix_x),
    bin_vx=bin_vx_min;
else
    bin_vx=bin_vx_min.*(2.^(NLEVEL-1));
end

if(fix_y),
    bin_vy=bin_vy_min;
else
    bin_vy=bin_vy_min.*(2.^(NLEVEL-1));
end

vxmin = vxmin_min+bin_vx*((2.^(NLEVEL-1))-1)/(2.^(NLEVEL)); 
vymin = vymin_min+bin_vy*((2.^(NLEVEL-1))-1)/(2.^(NLEVEL));

vxmax = -bin_vx+(vxmin-bin_vx/2) + n*bin_vx; % number of vx bins
vymax = -bin_vy+(vymin-bin_vy/2) + m*bin_vy; % number of vx bins



% === highlight red button indicating 'busy'
h_status=findobj(fig,'Tag','ms_status');
if ~isempty(h_status)&ishandle(h_status),
   red=[1 0 0];
   set(h_status,'BackgroundColor',red);
   drawnow;   
end


% === call MA routine with the 'noplot' option
colordef none;

   MApow_d=[];

   if isempty(MApow_d),
      % === perform new slice
      % disp('Perform new slice.')
      MApow_d=multires2d(vx, vy, int, err, vxmin, vxmax, bin_vx, fix_x, vymin, vymax, bin_vy, fix_y, NLEVEL,NS,3);
   end

nsmooth=[];

if (~isempty(MApow_d)),

    MApow_d.s=MApow_d.s(1:size(data.S,1),1:size(data.S,2));
    MApow_d.e=MApow_d.e(1:size(data.S,1),1:size(data.S,2));
    
    %MApow_d.slice=[vx_min vx_max bin_vx_min vy_min vy_max bin_vy_min]; % slice parameters
    
    MApow_d.axis_label=data.axis_label;
    MApow_d.axis_unitlabel=data.axis_unitlabel;
    MApow_d.title_label=data.title_label;
    
    
    
fig=findobj('Tag','plot_MApow');
if isempty(fig),
   colordef none;
   fig=figure('MenuBar','none','Resize','off',...
              'Position',[5    33   536   80],...
              'Name','MSlice : MULTIRESOLUTION powder',...
              'NumberTitle','off',...
              'Tag','plot_MApow','PaperPositionMode','auto');
else
        figure(fig);
        clf;
end

h_ma=findobj('Tag','plot_MApow');
set(h_ma,'UserData',MApow_d);

    
    % === store slice data under plot_MA3d, with label: 'MA3d_d'
    
    
    
    

    
     
    
    
    
    plot_MApow;
    
    % === highlight green button indicating 'not busy' 
    if ~isempty(h_status)&ishandle(h_status),
        green=[0 1 0];
	    set(h_status,'BackgroundColor',green);
        drawnow;
    end
end


h_ma=findobj('Tag','plot_MApow');
if isempty(h_ma)|~ishandle(h_ma),
   disp('Could not locate object to store MApow_d');
   return;
end
set(h_ma,'UserData',MApow_d);



