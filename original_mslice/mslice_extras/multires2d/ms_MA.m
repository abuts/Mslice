function ms_MA(NLEVEL, NS);
% function ms_MA(NLEVEL, NS);
%
% Once the mslice program has been launched, and projection on to viewing axes performed
% we can calculate a multiresolution slice, (i.e: an adaptive binning routine to bin pixels  
% locally, up to an acceptable minimum S/N ratio while preserving high statistics areas from 
% being unnecessarily binned).
% 
% Syntax
%           ms_MA(NLEVEL, NS)
%           ms_MA(NLEVEL)
%           ms_MA
%
% Description 
%           ms_MA(NLEVEL, NS) display a multiresolution slice, where NLEVEL= number of levels 
%           the algorithm will cover. Starting from Dx, Dy (loaded from MSlice Control Window)
%           to dx= Dx/(2.^(NLEVEL-1)), dy= Dy/(2.^(NLEVEL-1)). where NS is the noise-to-signal 
%           ratio; ERR/S. That will act as a threshold. Resulting in a image, which ERR/S is
%           below the imposed value NS.
%
%           ms_MA(NLEVEL) NS will be considered to be equal = 1, thus: ERR/S =100%. Only those 
%           pixels above 100% ratio will not be collected.
%           
%           ms_MA(NLEVEL) NS will be considered to be equal = 1, thus: ERR/S =100%. Only those 
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
% More Info: 'A multiresolution data visualization tool for applications in neutron 
%             time-of-flight spectroscopy' Nuclear Instruments and Methods
%             2005.
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

obj=findobj(fig,'Tag','ms_analysis_mode');
if isempty(obj),
   disp('## No analysis mode selected. Return.')
   return;
end

obj=findobj(fig,'Tag','ms_det_type');
if isempty(obj),
   disp('## No detector type selected. Return.')
   return;
end

% === if no change to the type of detectors, return
psd=(get(obj,'Value')==1);

if (psd==0),
   disp('## Multiresolution Routine has been built specifically for')
   disp('   Position Sensitive Detectors. Return.')
   return;
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

% % === read shading option
% shad_opt=get(findobj(fig,'Tag','ms_slice_shad'),'String');
% shad=shad_opt{shad};	% change type from number to 'flat','faceted','interp'


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


Dx=bin_vx.*(2.^(NLEVEL-1));
Dy=bin_vy.*(2.^(NLEVEL-1));



% === highlight red button indicating 'busy'
h_status=findobj(fig,'Tag','ms_status');
if ~isempty(h_status)&ishandle(h_status),
   red=[1 0 0];
   set(h_status,'BackgroundColor',red);
   drawnow;   
end

% === call MA routine with the 'noplot' option
%colordef none;
if iscell(data),
   % === multiple data sets
   n=length(data);	% number of data sets
   MA_d=cell(size(data));
   weights=zeros(1,n);
   for i=1:n,
       MA_d{i}=MA(data{i},z,vz_min,vz_max,vx_min,vx_max,Dx,vy_min,vy_max,Dy,NLEVEL,NLEVEL,NS);
   	if isempty(MA_d{i}),
   		disp(['Warning : Slice through data set ' num2str (i) ' contains no data.']);
      end
      weights(i)=data{i}.monitor;
   end
   MA_d=add_slice(MA_d,weights);
else
    
    
   % === check if range/binning has changed since the last stored slice
   h=findobj(fig,'tag','MA_d');
   v=[vz_min vz_max vx_min vx_max bin_vx vy_min vy_max bin_vy];   
   if isempty(h)|~ishandle(h)|isempty(get(h,'UserData')),
      % disp('No stored slice data');
      MA_d=[];
   else
      MA_d=get(h,'UserData');
      if ~(isfield(MA_d,'z')&all(MA_d.z==z)&isfield(MA_d,'v')&all(MA_d.v==v)),      
         MA_d=[];
      end
   end
   if isempty(MA_d),
      % === perform new slice
      % disp('Perform new slice.')   
      
      %MA_d=MA(data,z,vz_min,vz_max,vx_min,vx_max,Dx,vy_min,vy_max,Dy,NLEVEL,NLEVEL,NS);

%-----------------------------------------      
      if  z==1,
        x=2;
        y=3;
        elseif z==2,
            x=3;
            y=1;
        elseif z==3,
            x=1;
            y=2;
        else
            disp(['## Warning: Cannot perform slice perpendicular to axis number ' num2str(z)]);
	        return
      end
      
   v=reshape(data.v,prod(size(data.v(:,:,1))),3);   % matrix (ndet*ne,3) with projections
   int=data.S(:);
   err=data.ERR(:);
   index=((v(:,z)>=vz_min)&(v(:,z)<=vz_max));	    % include [] on the boundaries to agree with Phoenix 4.1
   v=v(index,:);
   int=int(index);
   err=err(index);
  
   n=floor((vx_max+bin_vx-(vx_min-bin_vx/2))/bin_vx);	% number of vx bins
   m=floor((vy_max+bin_vy-(vy_min-bin_vy/2))/bin_vy);	% number of vy bins
   
   index=((v(:,x)>=(vx_min-bin_vx/2))&(v(:,x)<(vx_min-bin_vx/2+n*bin_vx))&(v(:,y)>=(vy_min-bin_vy/2))&...
      (v(:,y)<(vy_min-bin_vy/2+m*bin_vy))); % [) in both directions to agree with Phoenix 4.1
   v=v(index,:);
   int=int(index);
   err=err(index);
   vx=v(:,x);
   vy=v(:,y);

fix_x=logical(0);
fix_y=logical(0);   

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

      
MA_d=multires2d(vx, vy, int, err, vx_min, vx_max, Dx, fix_x, vy_min,vy_max, Dy, fix_y, NLEVEL,NS);      
   
   % ==== construct slice title
form='%7.5g';	% number format 
titlestr1=[avoidtex(data.filename) ', ' data.title_label];
if data.emode==1,	% direct geometry Ei fixed
    titlestr1=[titlestr1 ', Ei=' num2str(data.efixed,form) ' meV'];
    elseif data.emode==2,	% indirect geometry Ef fixed
        titlestr1=[titlestr1 ', Ef=' num2str(data.efixed,form) ' meV'];
    else
        disp(sprintf('## Could not identify spectrometer type (only direct/indirect geometry allowed), emode=%g',data.emode));
        titlestr1=[titlestr1 ', E=' num2str(data.efixed,form) ' meV'];   
end   

% if sample is single crystal and uv orientation and psi_samp are defined, include in title
if isfield(data,'uv')&~isempty(data.uv)&isnumeric(data.uv)&(size(data.uv)==[2 3])&...
     isfield(data,'psi_samp')&~isempty(data.psi_samp)&isnumeric(data.psi_samp)&...
        (prod(size(data.psi_samp))==1),
     titlestr2=sprintf('{\\bfu}=[%g %g %g], {\\bfv}=[%g %g %g], Psi=({\\bfu},{\\bfki})=%g',...
        data.uv(1,:),data.uv(2,:),data.psi_samp*180/pi);
     else
        titlestr2=[];
end

titlestr3=['MultiR slice '  num2str(vz_min,form) '<' deblank(data.axis_label(z,:)) '<' num2str(vz_max,form) ];
titlestr3=[titlestr3 ' , ' deblank(data.axis_label(x,:)) '=' num2str(vx_min,form) ':'  num2str(vx_max,form)];
titlestr3=[titlestr3 ' , ' deblank(data.axis_label(y,:)) '=' num2str(vy_min,form) ':'  num2str(vy_max,form) ];
if ~isempty(titlestr2),
    MA_d.title={titlestr1, titlestr2, titlestr3};
    else
        MA_d.title={titlestr1, titlestr3};
end   

% === construct axis labels ============================================
labelx=[combil(deblank(data.axis_label(x,:)),data.u(x,:),data.u(z,:)*mean([vz_min vz_max])) ...
      ' ' deblank(data.axis_unitlabel(x,:))];
labely=[combil(deblank(data.axis_label(y,:)),data.u(y,:),data.u(z,:)*mean([vz_min vz_max])) ...
      ' ' deblank(data.axis_unitlabel(y,:))];
MA_d.axis_label2=str2mat(labelx,labely,deblank(data.axis_unitlabel(4,:)));
MA_d.axis_unitlength=data.axis_unitlength([x;y]);
%-----------------------------------------

   end
end   

% if ~isempty(MA_d),
%    set(h_ma,'MAData',MA_d);
% end


nsmooth=[]; 

if (~isempty(MA_d)),

    MA_d.axis_label=data.axis_label;
    MA_d.z=z; % normal axis to slice plane
    MA_d.slice=[vz_min vz_max vx_min vx_max bin_vx vy_min vy_max bin_vy]; % slice parameters

 
%     fig=findobj('Tag','ms_ControlWindow');
%     if isempty(fig),
%         disp('Control Window not active: Open Mslice first.');
%         return;
%     end
% 
%     h=findobj(fig,'tag','ms_slice_data');
%     if isempty(h)|~ishandle(h),
%         disp('Could not locate object to store slice data');
%         return;
%     end
    
    
    
fig=findobj('Tag','plot_MA');
if isempty(fig),
   %colordef none;
   
      fig=figure('Resize','on',...
              'Position',[560    395   450   350],...
              'Name','MSlice : MULTIRESOLUTION 2D',...
              'NumberTitle','off',...
              'Tag','plot_MA','PaperPositionMode','auto',...
              'Renderer','zbuffer');
          
%    fig=figure('Tag','plot_MA','PaperPositionMode','auto','Name',':: MULTIRESOLUTION Slice ::','Renderer','zbuffer',...
%        'Position',[560    395   450   350]);
else
        figure(fig);
        clf;
end

h_ma=findobj('Tag','plot_MA');
set(h_ma,'UserData',MA_d);

    
    % === store slice data under plot_MA, with label: 'MA_d'
    % === 'tag','ms_MA_data','type','uicontrol', MA_d will be in field 'MA_d'
    
    plot_MA(i_min,i_max,NLEVEL,NS);
    
    % === highlight green button indicating 'not busy' 
    if ~isempty(h_status)&ishandle(h_status),
        green=[0 1 0];
	    set(h_status,'BackgroundColor',green);
        drawnow;
    end
end


h_ma=findobj('Tag','plot_MA');
if isempty(h_ma)|~ishandle(h_ma),
   disp('Could not locate object to store MA_d');
   return;
end
set(h_ma,'UserData',MA_d);

% === store slice data under ControlWindow label 'MA_d' 
% === 'tag','MA_d','type','uicontrol', MA_d will be in field 'UserData'
% set(h,'UserData',MA_d);
% 
% h=findobj(fig,'tag','MA_d');
% if isempty(h)|~ishandle(h),
%    disp('Could not locate object to store MA_d');
%    return;
% end


