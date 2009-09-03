function value=ms_getvalue(input)
% Get values from the Mslice ControlWindow to the command line
%
%   >> ms_setvalue(field_name,value)
%
% For a list of field names, type >> ms_getfields

h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
   disp(['No Control window opened, can not get parameter value']);
   return;
end

% get the value of the tag as a string
str=ms_getstring(h_cw,['ms_' input]);

% convert string into a value, else return the string as the value
value= str2double(str);
if isnan(value)
    value=str;
end
% TGP Feb 2009: above replaces the following, which causes warning if str is a function or variable
% value= str2num(str);
% if  isempty(value)
%     value = str;
% end
