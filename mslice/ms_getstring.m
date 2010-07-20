function [str,value]=ms_getstring(h_cw,tag)
% Get string property of object with given tag in the ControlWindow (handle h_cw)
%
% Get string value:
%   >> str=ms_getstring(h_cw,tag)       
%   
% Get raw value as well:
%   >> [str,raw_value]=ms_getstring(h_cw,tag)   
%           if check box:     raw_value = 0 or 1 for 'off' or 'on'
%           if pulldown menu: raw_value = index of string (1,2,3...) in pull down list

% === return if handle to COntrol Window is invalid or if error reading tag 
if ~exist('h_cw','var')|isempty(h_cw)|~ishandle(h_cw),
   disp('Could not locate ControlWindow. Return.');
   str=[]; value=[];
   return;   
end
if ~exist('tag','var')|isempty(tag)|~ischar(tag),
   disp('Error reading handle Tag. Return.');
   str=[]; value=[];
   return;
end


% === locate object in the ControlWindow
h=findobj(h_cw,'Tag',tag);
if isempty(h),
   % may be the object is saved in mslice configuration?
   disp(['Could not find handle of object with Tag ' tag ' in the figure with handle' num2str(h_cw)]);
   str=[]; value=[];
   return;
end
if length(h)>1,
   disp(['Have located more instances of an object with the same handle.']);
   disp(['Cannot extract string property uniquely. Return.']);
   str=[]; value=[];
   return;
end

% === extract string property if editable text, simple text, 
% === selected entry in a popupmenu or on/of if checkbox
if strcmp(get(h,'Style'),'popupmenu'),
   value=get(h,'Value');
   strings=get(h,'String');
   str=strings{value};
elseif strcmp(get(h,'Style'),'checkbox'),
   value=get(h,'Value');
   if value==0,
      str='off';
   else
      str='on';
   end
elseif strcmp(get(h,'Style'),'text')|strcmp(get(h,'Style'),'edit'),
   value=get(h,'string');
   str=get(h,'string');
else
   disp(['Have not defined string property of an object of style ' get(h,'Style')]);
   str=[]; value=[];
   return;
end
