function msma3d;
% function msma3d;
%
% Once the mslice program has been launched, and projection on to viewing axes performed
% we can calculate a multiresolution volume, (i.e: an adaptive binning routine to bin pixels  
% locally, up to an acceptable minimum S/N ratio while preserving high statistics areas from 
% being unnecessarily binned).
% 
% Syntax
%           msma3d
%
% Description 
%           msma3d display a multiresolution slice, where all the data information will be 
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
   for i=1:length(data),
      if ~isfield(data{i},'S')|isempty(data{i}.S),
         disp(['No intensity matrix in data set ' num2str(i) '. Construct set again.']);
         return;
      elseif ~isfield(data{i},'v')|isempty(data{i}.v),
         disp(['Calculate projections for set ' num2str(i) ', then do MA.']);
         return;
     elseif ~isfield(data{i},'ERR')|isempty(data{i}.ERR),
         disp(['No error matrix in data set ' num2str(i) '. Construct set again.']);
         return;
      end
    end
end

obj=findobj(figg,'Tag','ms_analysis_mode');
if isempty(obj),
   disp('No analysis mode selected. Return.')
   return;
end

obj=findobj(figg,'Tag','ms_det_type');
if isempty(obj),
   disp('No detector type selected. Return.')
   return;
end

% === if no change to the type of detectors, return
psd=(get(obj,'Value')==1);

if (psd==0),
   disp('## Multiresolution Routine has been built specifically for')
   disp('   Position Sensitive Detectors. Return.')
   return;
end

fig=findobj('Tag','plot_MA3d');
if isempty(fig),
   disp('MULTIRESOLUTION 3d window NOT active: Open MULTIRESOLUTION 3d first.');
   return;
end
% ===== read parameters from ControlWindow
vars=str2mat('vz_min','vz_max','bin_vz','fix_z','vx_min','vx_max','bin_vx','fix_x');
vars=str2mat(vars,'vy_min','vy_max','bin_vy','fix_y');
%vars=str2mat(vars,'colmap','nsmooth','shad');
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
%   	disp([name '=' value ';']);   
   else
      eval([name '=[];']);
%      disp([name '=[];']);
   end
end

fix_x=logical(fix_x);
fix_y=logical(fix_y);
fix_z=logical(fix_z);

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


   
% % === read shading option
% shad_opt=get(findobj(fig,'Tag','MA_shad'),'String');
% shad=shad_opt{shad};	% change type from number to 'flat','faceted','interp'


% % === read colour table
% if colmap==3,
%    map=jet;	% MATLAB blue -> red 'jet.m' RGB colour table
% 	linearlog='linear';   
% else
%    % read PHOENIX-type colour map black->red
%    map=get(findobj('Tag','ms_slice_colmap'),'UserData');
% 	 if colmap==1,
%       linearlog='linear';	% linear scale 
%    else
%       linearlog='log';		% logarithmmic scale
%    end
% end




% === highlight red button indicating 'busy'
h_status=findobj(figg,'Tag','ms_status');
if ~isempty(h_status)&ishandle(h_status),
   red=[1 0 0];
   set(h_status,'BackgroundColor',red);
   drawnow;
end

% === call MA routine with the 'noplot' option
colordef none;


v=reshape(data.v,prod(size(data.v(:,:,1))),3);

h_ma=findobj('Tag','plot_MA3d');
    if isempty(h_ma)|~ishandle(h_ma),
        disp('## Could not locate object to store multiresoultion data');
        return;
    end
MA3d_d=get(h_ma,'UserData');
z=MA3d_d.z;

    if  z==1,
        x=2;
        y=3;
        elseif z==2,
            x=3;
            y=1;
        elseif z==3,
            x=1;
            y=2;
    end

vx=v(:,x);
vy=v(:,y);
vz=v(:,z);

int=reshape(data.S,[],1);
err=reshape(data.ERR,[],1);

if(fix_x),
    Dx=bin_vx;
else
    Dx=bin_vx.*(2.^(NLEVEL-1));
end

if(fix_y),
    Dy=bin_vy;
else
    Dy=bin_vy.*(2.^(NLEVEL-1));
end

if(fix_z),
    Dz=bin_vz;
else
    Dz=bin_vz.*(2.^(NLEVEL-1));
end

   MA3d_d=[];
   if isempty(MA3d_d),
      % === perform new slice
      % disp('Perform new slice.')      
      MA3d_d=multires3d(vx,vy,vz, int, err, vx_min,vx_max,Dx,fix_x,vy_min,vy_max,Dy,fix_y,vz_min,vz_max,Dz,fix_z,NLEVEL,NS,0);
   else
      % disp('Use stored slice data.')
   end
  
if (~isempty(MA3d_d)),

    MA3d_d.axis_label=data.axis_label;
    MA3d_d.z=z; % normal axis to slice plane 
    MA3d_d.slice=[vx_min vx_max bin_vx vy_min vy_max bin_vy vz_min vz_max bin_vz]; % slice parameters

     
    % === store slice data under ControlWindow label 'MA_d' 
    % === 'tag','ms_MA_data','type','uicontrol', MA_d will be in field 'UserData
    
    h_ma=findobj('Tag','plot_MA3d');
    if isempty(h_ma)|~ishandle(h_ma),
        disp('## Could not locate object to store multiresoultion data');
        return;
    end
    
    set(h_ma,'UserData',MA3d_d);
    
    %checking process: vx vy and vz must be of length > 1
    if( length(MA3d_d.vx)<2 | length(MA3d_d.vy)<2 | length(MA3d_d.vz)<2 ),
       disp('!! Warning: In order to plot the volume by means of ''sliceomatic''')
       disp('   The result volume must be a 3D matrix:')
       disp('   length of x, y and z must be > 2.') 
       disp('   Try changing input parameters ')
       return;
    end
    
    
%   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    % here we call to sliceomatic !!
sliceomatic (MA3d_d.vx, MA3d_d.vy, MA3d_d.vz, MA3d_d.intensity,...
MA3d_d.axis_label(x,:),MA3d_d.axis_label(y,:), MA3d_d.axis_label(z,:),...
MA3d_d.axis_label(x,:),MA3d_d.axis_label(y,:), MA3d_d.axis_label(z,:),...
[0, 0.5])

%- to be overwritten --
colormap('jet')
axis square
%- to be overwritten --


    % === highlight green button indicating 'not busy' 
    if ~isempty(h_status)&ishandle(h_status),
        green=[0 1 0];
	    set(h_status,'BackgroundColor',green);
        drawnow;
    end
end  