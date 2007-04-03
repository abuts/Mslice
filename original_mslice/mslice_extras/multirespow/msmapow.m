function msmapow;
% function msmapow;
%
% Once the mslice program has been launched, and projection on to viewing axes performed
% we can calculate a multiresolution volume, (i.e: an adaptive binning routine to bin pixels  
% locally, up to an acceptable minimum S/N ratio while preserving high statistics areas from 
% being unnecessarily binned).
% 
% Syntax
%           msmapow
%
% Description 
%           msmapow display a multiresolution slice, where all the data information will be 
%           collected from MSlice Control Window, and the slice limits specification, will
%           be obtained from Multiresolution window. So if both Windows are not present, return.
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



% == return if no Control Window present, no data read or projections not calculated yet
figg=findobj('Tag','ms_ControlWindow');
if isempty(figg),
   disp('Control Window not active: Open Mslice first.');
   return;
end

% === if clear request given, clear slice data and return
if exist('cmd','var')&ischar(cmd)&strcmp(lower(cmd(~isspace(cmd))),'clear'),
   % disp('Clearing stored slice data.')
   h=findobj(figg,'tag','MA3d_d');
   if isempty(h)|~ishandle(h),
      disp('Could not locate object storing slice data. Return.');
      return;
   end
   set(h,'UserData',[]);
   return;
end

data=get(figg,'UserData');
if isempty(data),
   % === no data loaded
   disp('Load data first, then do calculate projections.');
   return;
elseif isstruct(data),
   % == one data set only
   if ~isfield(data,'S')|isempty(data.S),
   	disp('Loaded data set has no intensity matrix. Load data again.');
      return;
   elseif ~isfield(data,'v')|isempty(data.v),
      disp(['Calculate projections first and then display slice.']);
      return;
   end   
elseif iscell(data),
   % === multiple data sets
   for i=1:length(data),
      if ~isfield(data{i},'S')|isempty(data{i}.S),
         disp(['No intensity matrix in data set ' num2str(i) '. Construct set again.']);
         return;
     elseif ~isfield(data{i},'ERR')|isempty(data{i}.ERR),
         disp(['No error matrix in data set ' num2str(i) '. Construct set again.']);
         return;
      end
    end
end

samp=get(findobj(figg,'Tag','ms_sample'),'Value');
if samp==1,
   analmode=get(findobj(figg,'Tag','ms_analysis_mode'),'Value');
end  

if samp==1,%sample is crystal
   if analmode==2,	% analysed as powder
       disp('## Crystal sample, Analysing as powder')
%        vars=str2mat(vars,'u1','u1label','u2','u2label');
   else	% analysed as single crystal
          disp('## This subrutine is for powder samples or ')
          disp('   single crystals Analysed as powder. Return.')
          return;
   end
end  

if samp==2,	%sample is powder 
    disp('## Powder sample ')
%     vars=str2mat('u1','u1label','u2','u2label','efixed','emode','IntensityLabel','TitleLabel');
end



% === read disp parameters from MULTIRESOLUTION powder
fig=findobj('Tag','plot_MApow');
if isempty(fig),
   disp('MULTIRESOLUTION powder window NOT active: Open MULTIRESOLUTION powder first.');
   return;
end

vars=str2mat('fix_x','fix_y');

for i=1:size(vars,1),
   name=vars(i,:);
   name=name(~isspace(name));
   h=findobj(fig,'Tag',['MA_' name]);
   if isempty(h),
      disp(['Warning: object with Tag MA_' name ' not found']);
   end
   if strcmp(get(h,'Style'),'popupmenu')|strcmp(get(h,'Style'),'checkbox'),
      value=num2str(get(h,'Value'));
   else
      value=get(h,'String');
   end
   if ~isempty(value),	    
      eval([ name '=' value ';']); 
   else
      eval([name '=[];']);
   end
end


fix_x=logical(fix_x);
fix_y=logical(fix_y);



h=findobj(fig,'Tag',['NLEVEL_te']);
   if isempty(h),
      disp(['Warning: object with Tag ''NLEVEL_te'' not found']);
   end
   
   value=get(h,'String');
   value = str2num(value);
   
   if ~isempty(value),	    
      NLEVEL=value; 
   else
      NLEVEL=[];
      return
   end
   
   if(NLEVEL~=round(NLEVEL)),
    disp('!! Warning: NLEVEL value has to be an INTEGER value');
    
    return;
   end
   
h=findobj(fig,'Tag',['ERR_te']);
   if isempty(h),
      disp(['!! Warning: object with Tag ''ERR_te'' not found']);
   end
   
      value=get(h,'String');
      value = str2num(value);
      
   if ~isempty(value),	    
      NS=value; 
   else
      NS=[];
      return
   end

   % >> ===== read parameters from Mslice: ControlWindow

vars=[];
vars=str2mat('vx_min','vx_max','vy_min','vy_max');
vars=str2mat(vars,'i_min','i_max');
vars=str2mat(vars,'colmap','nsmooth','shad');
for i=1:size(vars,1),
   name=vars(i,:);
   name=name(~isspace(name));
   h=findobj(figg,'Tag',['ms_disp_' name]);
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





   
% === highlight red button indicating 'busy'
h_status=findobj(figg,'Tag','ms_status');
if ~isempty(h_status)&ishandle(h_status),
   red=[1 0 0];
   set(h_status,'BackgroundColor',red);
   drawnow;
end

% === call MA routine with the 'noplot' option
colordef none;


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



colordef none;

   MApow_d=[];

   if isempty(MApow_d),
      % === perform new slice
      % disp('Perform new slice.')
      MApow_d=multires2d(vx, vy, int, err, vxmin, vxmax, bin_vx, fix_x, vymin, vymax, bin_vy, fix_y, NLEVEL,NS,3);
   end


if (~isempty(MApow_d)),

    MApow_d.s=MApow_d.s(1:size(data.S,1),1:size(data.S,2));
    MApow_d.e=MApow_d.e(1:size(data.S,1),1:size(data.S,2));
    
    MApow_d.slice=[vx_min vx_max vy_min vy_max]; % slice parameters
    
    MApow_d.axis_label=data.axis_label;
    MApow_d.axis_unitlabel=data.axis_unitlabel;
    MApow_d.title_label=data.title_label;
    
    
    
fig=findobj('Tag','plot_MApow');
if isempty(fig),
  disp('## ERROR !! MULTIRESOLUTION powder window should be open !!')
  return
end

h_ma=findobj('Tag','plot_MApow');
set(h_ma,'UserData',MApow_d);

% - to be overwritten --
colormap('jet')
datan=data;
datan.S=MApow_d.s;
datan.ERR=MApow_d.e;
% ---------------------

% === establish shading option
shad_opt=get(findobj(figg,'Tag','ms_disp_shad'),'String');
if ~isempty(shad_opt),
	shad=shad_opt{shad};	% change type from number to 'flat','faceted' or 'interp'
else
   shad='flat';
   disp('Default "flat" shading option chosen');
end
   
% === read colour table
if colmap==3,
   map=jet;	% MATLAB blue -> red 'jet.m' RGB colour table
   linearlog='linear';
else
   % read PHOENIX-type colour map black->red
   map=get(findobj(figg, 'Tag','ms_disp_colmap'),'UserData');
   if colmap==1,
      linearlog='linear';	% linear scale 
   else
      linearlog='log';		% logarithmmic scale
   end
end


if isempty(nsmooth)|~isnumeric(nsmooth)|(nsmooth<1),
	disp_pow(datan,vx_min,vx_max,vy_min,vy_max,i_min,i_max,shad,map,linearlog);
else
    disp('## warning !! if you are using smoothing then') 
    disp('   correlation effects will be added to your data')
    disp_pow(smooth_spe(datan,nsmooth),vx_min,vx_max,vy_min,vy_max,i_min,i_max,shad,map,linearlog);
end

%plot whatever.....

%- to be overwritten --


    % === highlight green button indicating 'not busy'
    if ~isempty(h_status)&ishandle(h_status),
        green=[0 1 0];
	    set(h_status,'BackgroundColor',green);
        drawnow;
    end
end  