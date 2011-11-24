function varargout= get(this,varargin)
% Get values of one or more fields from a cponfiguration class
%
%   >> val= get(config_name)       % returns the structure with the current
%                                    configuration for the requested configuration name
%
%   >> [val1,val2,...] = get(config_name,'field1','field2',...); % returns named fields
%
% Recursively searches the sub-structures and classes of the configuration class
% until field(s) with the given name(s) is/are found.
%
% $Revision$ ($Date$)
%


% Fetch the current configuration
config_name = class(this);
fetch_default=false;
config_data = config_store(config_name,fetch_default);

% Return if full structure is required
if nargin == 1
    varargout{1}=config_data;
    return
end
if nargin == 2 && strcmpi(varargin{1},'all')
    varargout{1} = config_store(config_name,'getall');
    return;
end

% Check arguments are character strings
if ~all_strings(varargin)
    error('All field names have to be strings'); 
end

% Get values
varargout=cell(1,min(max(1,nargout),numel(varargin)));  % return at least one value
for i=1:numel(varargout)
    [data_field,found]=get_field_in_hierachy(config_data,varargin{i});
    if found
        varargout{i}=data_field;
    else
        error('The field %s does not exist in configuration %s and its parents',varargin{i},config_name);    
    end    
end

%--------------------------------------------------------------------------------------------------
function ok=all_strings(c)
% Check elements of a cell array are 1xn non-empty character strings
ok=true;
for i=1:numel(c)
    ok=ischar(c{i}) && ~isempty(c{i}) && size(c{i},1)==1;
end

%--------------------------------------------------------------------------------------------------
function [val,found]=get_field_in_hierachy(structure,field_name)
% Recursively searches through the hierarchy of structures and classes looking
% for the field name specified.
% Returns after finding the first field that is not a class or structure with the name
% requested, or empty field after unsuccessful search through the whole structure;

found = false;
if isfield(structure,field_name)
    % If field name, get data and return
    val   =structure.(field_name);
    found = true;
else
    % Search for the field in classes or structures (if n array of structures or objects, use first element)
    names = fields(structure);
    val=[];
    for i=1:numel(names)
        if isstruct(structure.(names{i}))
            val=get_field_in_hierachy(structure.(names{i})(1),field_name);
        elseif isobject(structure.(names{i}))
            val=get_field_in_hierachy(struct(structure.(names{i})(1)),field_name);
        end
        if ~isempty(val)
            return;
        end
    end
end
