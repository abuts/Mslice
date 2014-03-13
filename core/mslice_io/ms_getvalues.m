function values=ms_getvalues(input,varargin)
% Get values for a set of fieldnames from the Mslice ControlWindow to the command line
%
%   fieldnames      Cell array of names of character array of names
%   values          Cell array of values
%
% Get string value:
%   >> values=ms_getvalues(field_names)       
%   
% Get raw value:
%   >> values=ms_getvalue(field_names,'raw')      
%           if check box:     raw_value = 0 or 1 for 'off' or 'on'
%           if pulldown menu: raw_value = index of string (1,2,3...) in pull down list
%           Edit or text box: raw_value = character string contents
%
% The assumption is that edit or text boxes will generally contain text that is to be
% interpreted as numeric, and so the function attempts to convert to numeric data.
% If it is desired not to do this (e.g. title label), then force no evaluation:
%
%   >> values=ms_getvalue(field_names,'noeval') 
%
%
% For a full list of field names, type >> ms_getfields

% T.G.Perring Nov 2009


values=cell(1,numel(input));

% Check input
if ~isempty(input) && ischar(input) && length(input)==2
    input=cellstr(input);
elseif ~iscellstr(input)
    disp('Input must be cell array or character array of fieldnames')
    for i=1:numel(input)
        values{i}=[];
    end
    return
end

% Get values
for i=1:numel(input)
    values{i}=ms_getvalue(input{i},varargin{:});
end
