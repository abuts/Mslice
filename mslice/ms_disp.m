function ms_disp

% function ms_disp;
% callback function for the 'Display' button on the MSlice Control Window

% == return if no Control Window present, no data read or projections of data or bin boundaries not calculated yet
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   disp('Control Window not active. Return.');
   return;
end
data=get(fig,'UserData');
if isempty(data)||~isfield(data,'S'),
   disp('Load data first, calculate projections and then do display.');
   return;
elseif ~isfield(data,'v'),
   disp('Calculate projections first, then do display.');
   return;
end

% === read disp parameters from ControlWindow
disp_par=struct('vx_min',[],'vx_max',[],'vy_min',[],'vy_max',[],...
                'i_min',[],'i_max',[],'colmap',[],'nsmooth',[],'shad','',...
                'dx_step',[],'dy_step',[]);
fields=fieldnames(disp_par);
raw_fields={'colmap','shad'};
for i=1:numel(fields)
    name=['disp_',fields{i}];
    if any(ismember(raw_fields,fields{i}))
        disp_par.(fields{i})=ms_getvalue(name,'raw');
    else
        disp_par.(fields{i})=ms_getvalue(name);        
    end
end

% === establish shading option
shad_opt=get(findobj('Tag','ms_disp_shad'),'String');
if ~isempty(shad_opt),
   disp_par.shad=shad_opt{disp_par.shad};	% change type from number to 'flat','faceted' or 'interp'
else
   disp_par.shad='flat';
   disp('Default "flat" shading option chosen');
end
   
% === read colour table
if disp_par.colmap==3,
   map=jet;	% MATLAB blue -> red 'jet.m' RGB colour table
   linearlog='linear';
else
   % read PHOENIX-type colour map black->red
   map=get(findobj('Tag','ms_disp_colmap'),'UserData');
   if disp_par.colmap==1
      linearlog='linear';	% linear scale 
   else
      linearlog='log';		% logarithmmic scale
   end
end   
colordef none;

% === call disp_spe function
if isempty(disp_par.nsmooth)||~isnumeric(disp_par.nsmooth)||(disp_par.nsmooth<1)
   disp_spe(data,disp_par,map,linearlog);
else
   disp_spe(smooth_spe(data,disp_par.nsmooth),disp_par,map,linearlog);
end
