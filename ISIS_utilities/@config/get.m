function [val,varargout]= get(self,varargin)
%
%>>[val1,val2]=get(config,'field1','field2'); % returns fields
%>>val        = get(class_name)   % returns the structure with the current
%                                   configuration for the class requested
%>>val        = get(config,'all') % returns structure with all configurations currently
%                                   loaded in memeory
%
%
% $Revision$ ($Date$)
%
class_struct = struct(self);
if (nargin == 1)
    val=class_struct;
    return
end

% check argumemts
non_char = ~ischarar(varargin{:});
if (any(non_char))
    mess='all field_names has to be strings (existing configurations field names)';    
    error('CONFIG:get',mess);
end
if strcmp(varargin{1},'all')
    val=get_all(config);
    return;
end

% process usual arguments;
n_par  = min(length(varargin),nargout);

data_field=get_field_in_hirachy(class_struct,varargin{1});
if isempty(data_field)
    class_name = class(self);
    error('CONFIG:get','get->The field %s does not exist in configuration %s and its parents',varargin{1},class_name);    
end

val  = data_field.(varargin{1});
if n_par>1
    varargout=cell(1,n_par-1);
end
for i=2:n_par 
    data_field=get_field_in_hirachy(class_struct,varargin{i});
    if isempty(data_field)
        class_name = class(self);        
        error('CONFIG:get','the field %s does not exist in configuration %s and its parents',varargin{i},class_name);    
    end
    
    varargout{i-1} = data_field.(varargin{i});
end
%
function isit=ischarar(varargin)
isit=false(1,nargin);
for i=1:nargin
    isit(i)=ischar(varargin{i});
end

function data_structure=get_field_in_hirachy(structure,field_name)
% recursively seaches through the hierarchy of structures and classes looking
% for the field_name specified;
% returns after finding the first class or structure with the name
% requested or empty field after unsuccessfull seach through the whole structure;

if isfield(structure,field_name)
    data_structure=structure;
    return;
end
names = fields(structure);
for i=numel(names):-1:1
    if ~isfield(structure,names{i})
        continue;
    end
    if isstruct(structure.(names{i}))
        data_structure=get_field_in_hirachy(structure.(names{i}),field_name);
        if ~isempty(data_structure)
            return;
        end
    end
    
    if isobject(structure.(names{i}))
        structure=struct(structure.(names{i}));
        data_structure=get_field_in_hirachy(structure,field_name);
        
        if ~isempty(data_structure)
            return;
        end        
    end
end
data_structure=[];
