function conf=set(this,varargin)
%
%    var = set(config,var, 'field1', val1, 'field2, val2, ... )
%    var = set(config, struct_val )
%    var = set(config, cellarray) where the cell array has the form {'field1',val1,...,etc.} 
%
%    var = set(config,'defaults')
%
% function sets corespondent fields in proper configuration class this
% it also writes the resutling structure into configuration file for future
% usage;
% the last form sets up the configuration to its default values, e.g. the
% one, specified in the default this structure
% for homer_gui you have to set up current instrument after that 
%
% $Revision: 1682 $ ($Date: 2010-05-19 09:09:16 +0100 (Wed, 19 May 2010) $)
%
global configurations;
global class_names;
% Parse arguments;
narg = length(varargin);
if narg==1
    svar = varargin{1};
    if ischar(svar)&&strcmpi(svar,'defaults')
        class_name = class(this);
        set_defaults(config,class_name);
        return;
    end
    is_struct = isa(svar,'struct');
    is_cell   = iscell(svar);
    if ~is_struct ||(~is_cell)
        mess='set->second parameter has to be a structure or a cell array';
        error('CONFIG:set',mess);
        
    end
    if is_struct
        field_nams = fieldnames(svar);
        field_vals = zeros(1,numel(field_nams));
        for i=1:numel(field_nams)
            field_vals(i)=svar.(field_nams{i});
        end        
    end
    if is_cell
        field_nams  = svar{1:2:end};
        field_vals  = svar{2:2:end};        
    end
 
else
   if (rem(narg,2) ~= 0)
        mess='set->Incomplete set of (field,value) pairs given';
        error('CONFIG:set',mess);        
   end
   nf = narg/2;
   field_nams = cell(1,nf);
   field_vals = cell(1,nf);   
   for i=0:nf-1
       field_nams{i+1}=varargin{2*i+1};
       field_vals{i+1}=varargin{2*i+2};       
   end
   
   if ~iscell(field_vals)
       field_vals={field_vals};
   end
   if ~iscell(field_nams)
        field_nams={field_nams};
   end   
   
        
end

% check argumemts
non_char = ~cellfun(@is_data_char,field_nams);
if (any(non_char))
    mess='all field_names has to be strings';    
    error('CONFIG:set',mess);
end
% get access to the internal structure

class_name       = class(this);
config_data      = struct(this);

config_fields    = fieldnames(config_data);

if isfield(config_data,'fields_sealed')
    sealed_fields=ismember(config_data.fields_sealed,field_nams);
    if any(sealed_fields);    
        mess='some field values requested are sealed and can not be set manually';
        error('CONFIG:set',mess);
    end
end

class_place               = ismember(class_names,class_name);
% the name of this variable has to coinside with the name defined in
% constructor as both fucntions have to save the same data in the same place
member_fields    = ismember(config_fields,field_nams);
if sum(member_fields)~=nf
    non_member = ~ismember(field_nams,config_fields);
    non_m_fields=field_nams(non_member);
    
    error('CONFIG:set','configuration class: %s does not have fields you are trying to set, namely: %s %s %s %s %s %s %s %s ',...
    class_name,non_m_fields{:});
    
end

%
% if we mofifying the parent class, all childrens hav to be modified too as
% we inherit from the parent by value;
if strcmp(class_name,class_names{1}) % very ugly way of doing singleton but very complicated algorithm otherwise;
    clear global configurations;
    clear global class_names;  
    class_names{1}=class_name;
else % we should not write the parent structure into the data file
    config_data=rmfield(config_data,class_names{1});
end


% set the fields
for i=1:nf
    this.(field_nams{i})       =field_vals{i}; % in memory 
    config_data.(field_nams{i})=field_vals{i}; % and in file on HDD
end
% % % ========================================================================
% % %
% % % do the class specific stuff (homer_config)
% % %
% % instr_selected = ismember(field_nams,'instrument_name');
% % if any(instr_selected)    
% %     % check, if the instrument requested here exist
% %     instr_name = field_vals(instr_selected);
% %     instr_allowed=get(config,'instruments_allowed');
% %     if ~any(ismember(instr_allowed,instr_name))
% %         error('LIBISIS:homgui_config',' attempting to set non-exisiting instrument: %s',instr_name);
% %     end
% %     [this,config_data]=set_instrument_config_location(this,config_data);    
% % end
% % % end class specific;
% ========================================================================    
configurations{class_place}=this;
conf = configurations{class_place};

% save data into the correspondent configuration file;
config_file_path= config_folder(config);
config_file_name= class_name;
config_file = fullfile(config_file_path,config_file_name);
save(config_file,'config_data')

function rez=is_data_char(data)
rez=isa(data,'char');

