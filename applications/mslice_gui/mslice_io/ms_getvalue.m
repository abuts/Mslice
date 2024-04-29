function value=ms_getvalue(input,opt)
% Get value from the Mslice ControlWindow to the command line
%
% Get string value:
%   >> val=ms_getvalue(field_name)     
%   
% Get raw value:
%   >> val=ms_getvalue(field_name,'raw')      
%           if check box:     raw_value = 0 or 1 for 'off' or 'on'
%           if pulldown menu: raw_value = index of string (1,2,3...) in pull down list
%           Edit or text box: raw_value = character string contents
%
% The assumption is that edit or text boxes will generally contain text that is to be
% interpreted as numeric, and so the function attempts to convert to numeric data.
% If it is desired not to do this (e.g. title label), then force no evaluation:
%
%   >> val=ms_getvalue(field_name,'noeval') 
%
%
% For a full list of field names, type >> ms_getfields
%
%  $Rev: 345 $  ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%

h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
   disp('No Control window opened, can not get parameter value');
   value=[];
   return
end

% get the value of the tag as a string
[str,raw_value]=ms_getstring(h_cw,['ms_' input]);

% Catch case of error
if isempty(raw_value)
    value=[];
    return
end

% Return value
if exist('opt','var') && strcmpi(opt,'raw')
    value=raw_value;
elseif (exist('opt','var') && strcmpi('noeval',opt)) || isnumeric(raw_value)
    value=str;
else
    % Convert string into a value, else return the string as the value
    % TGP Nov 2009: This will have side-effects if str contains a variable or function name,
    % because str2num uses eval; however, we want strings to be interpretable e.g. '1-0.05'
    % which str2double does not do.
    value = str2num(str);
    if isempty(value)
        value=str;
    end
end
