function [slice_d,slice_full]=ms_slice_write(flname_in,cmd)

% function slice_d=ms_slice_write(cmd);
%
% 21 May 2004 T.G.Perring
% Slightly modified version of ms_slice, to write slice to file if single input dataset.
% Calls new  function slice_spe_full:
%
%       >> slice = ms_slice_write ('')               % write slice; prompts for filename
%
%       >> slice = ms_slice_write ('$nofile')          % do not write a file
%
%       >> slice = ms_slice_write ('c:\myfile.slc')  % writes to named file
%
% Full syntax:
%   >> slice_d = ms_slice_write (flname, cmd)
%
% flname ='' prompts for output filename
%         'myfile.slc' saves slice to ASCII file named myfile.slc
%
% cmd='',[] or absent for normal slice plot
%     'noplot'  for calculation only 
%     'surf'    for calculation and surface plot
%     'clear'   clear slice data stored in ControlWindow object 'tag','ms_slice_data' 
% nb  'plot'    will result in a plot
%

% T.G.Perring   Feb 2009
% - add slice_full as second output argument
% - give error if data is a cell array (as slice_spe_full doesn't handle this)

% == return if no Control Window present, no data read or projections not calculated yet
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   disp('Control Window not active. Return.');
   return;
end
% === if clear request given, clear slice data and return 
if exist('cmd','var')&ischar(cmd)&strcmp(lower(cmd(~isspace(cmd))),'clear'),
   % disp('Clearing stored slice data.')
   h=findobj(fig,'tag','ms_slice_data');
   if isempty(h)|~ishandle(h),
      disp('Could not locate object storing slice data. Return.');
      return;
   end
   set(h,'UserData',[]);
   return;
end

data=get(fig,'UserData');
if isempty(data),
   % === no data loaded
   disp('Load data first, then do slice.');
   return;
elseif isstruct(data),
   % == one data set only
   if ~isfield(data,'S')|isempty(data.S),
   	disp('Loaded data set has no intensity matrix. Load data again.');
      return;
   elseif ~isfield(data,'v')|isempty(data.v),
      disp(['Calculate projections first and then take slices.']);
      return;
   end   
elseif iscell(data),
   % === multiple data sets
   error('Cannot handle multiple data sets')
%    for i=1:length(data),
%       if ~isfield(data{i},'S')|isempty(data{i}.S),
%          disp(['No intensity matrix in data set ' num2str(i) '. Construct set again.']);
%          return;
%       elseif ~isfield(data{i},'v')|isempty(data{i}.v),
%          disp(['Calculate projections for set ' num2str(i) ', then do slice.']);
%          return;
%       end
%     end
end

% ===== read parameters from ControlWindow
vars=str2mat('z','vz_min','vz_max','vx_min','vx_max','bin_vx');
vars=str2mat(vars,'vy_min','vy_max','bin_vy','i_min','i_max');
vars=str2mat(vars,'colmap','nsmooth','shad');
for i=1:size(vars,1),
   name=vars(i,:);
   name=name(~isspace(name));
   h=findobj(fig,'Tag',['ms_slice_' name]);
   if isempty(h),
      disp(['Warning: object with Tag ms_slice_' name ' not found']);
   end
   if strcmp(get(h,'Style'),'popupmenu')|strcmp(get(h,'Style'),'checkbox'),
      value=num2str(get(h,'Value'));
   else
      value=get(h,'String');
   end
   if ~isempty(value),	    
      eval([ name '=' value ';']); 
%   	disp([name '=' value ';']);   
   else
      eval([name '=[];']);
%      disp([name '=[];']);
   end
end

% === read shading option
shad_opt=get(findobj(fig,'Tag','ms_slice_shad'),'String');
shad=shad_opt{shad};	% change type from number to 'flat','faceted','interp'

% === read colour table
if colmap==3,
   map=jet;	% MATLAB blue -> red 'jet.m' RGB colour table
	linearlog='linear';   
else
   % read PHOENIX-type colour map black->red
   map=get(findobj('Tag','ms_slice_colmap'),'UserData');
	 if colmap==1,
      linearlog='linear';	% linear scale 
   else
      linearlog='log';		% logarithmmic scale
   end
end 

% === highlight red button indicating 'busy'
h_status=findobj(fig,'Tag','ms_status');
if ~isempty(h_status)&ishandle(h_status),
   red=[1 0 0];
   set(h_status,'BackgroundColor',red);
   drawnow;   
end

% === call slice_spe routine with the 'noplot' option
colordef none;
if iscell(data),
   % === multiple data sets
      error('Cannot handle multiple data sets')
%    n=length(data);	% number of data sets
%    slice_d=cell(size(data));
%    weights=zeros(1,n);
%    for i=1:n,
% 	   slice_d{i}=slice_spe(data{i},z,vz_min,vz_max,vx_min,vx_max,bin_vx,vy_min,vy_max,bin_vy,...
%          i_min,i_max,shad,'noplot');
%    	if isempty(slice_d{i}),
%    		disp(['Warning : Slice through data set ' num2str (i) ' contains no data.']);
%       end
%       weights(i)=data{i}.monitor;
%    end
%    slice_d=add_slice(slice_d,weights);
else
   % === check if range/binning has changed since the last stored slice
   h=findobj(fig,'tag','ms_slice_data');
   v=[vz_min vz_max vx_min vx_max bin_vx vy_min vy_max bin_vy];   
   if isempty(h)|~ishandle(h)|isempty(get(h,'UserData')),
      % disp('No stored slice data');
      slice_d=[];
   else
      slice_d=get(h,'UserData');
      if ~(isfield(slice_d,'z')&all(slice_d.z==z)&isfield(slice_d,'v')&all(slice_d.v==v)),      
         slice_d=[];
      end   
   end
   if exist('flname_in','var')&ischar(flname_in)&~isempty(flname_in)
       if ~strcmp(flname_in,'$nofile')
            flname = flname_in;
       else
            flname='';
       end
   else
       flname = ms_putfile_full('*.slc');
   end
   [slice_d,slice_full]=slice_spe_full(data,z,vz_min,vz_max,vx_min,vx_max,bin_vx,vy_min,vy_max,bin_vy,...
      i_min,i_max,shad,'noplot',flname);
end   

if isempty(slice_d),
 	disp(['Slice contains no data.']);
   return
end

if exist('cmd','var')&ischar(cmd)&strcmp(cmd,'noplot'),
	disp('No plot slice');
elseif exist('cmd','var')&ischar(cmd)&strcmp(cmd,'surf'),
   surf_slice(smooth_slice(slice_d,nsmooth),i_min,i_max,shad,map);
else
   if ~isempty(nsmooth)&(nsmooth>=1),   
%      disp(['plotting smoothed slice ' num2str(nsmooth)]);
      plot_slice(smooth_slice(slice_d,nsmooth),i_min,i_max,shad,map,linearlog);
   else
%      disp('plotting un-smoothed slice');
      plot_slice(smooth_slice(slice_d,0),i_min,i_max,shad,map,linearlog);
   end 
end

% === store slice data under ControlWindow label 'Slice plane' 
% === 'tag','ms_slice_data','type','uicontrol', slice_d will be in field 'UserData'
h=findobj(fig,'tag','ms_slice_data');
if isempty(h)|~ishandle(h),
   disp('Could not locate object to store slice data');
   return;
end
slice_d.z=z; % normal axis to slice plane 
slice_d.v=[vz_min vz_max vx_min vx_max bin_vx vy_min vy_max bin_vy]; % slice parameters
set(h,'UserData',slice_d);

% === highlight green button indicating 'not busy' 
if ~isempty(h_status)&ishandle(h_status),
   green=[0 1 0];
	set(h_status,'BackgroundColor',green);
   drawnow;
end
   
   