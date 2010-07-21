function conf=config(varargin)
% The class supports version dependent and user-modifiable horace
% configuration
% The fields in the structure config_data (below) correspond to default 
% values set for Horace
%
%
% The class is the attempt to introduce singleton pattern behaviour into older 
% versions of Matlab. As it is not fully singleton, no instance() function
% is implemented
%
%
% $Revision$ ($Date$)
%
%
% 
global configurations;
global class_names;
%

if isempty(configurations)
    config_data = struct(...
       'config_folder_name','libisis_config',...
       'instruments_root_dir','',     ...   % the folder where instrument files reside
       'instruments_allowed','', ...    % field for instruments libisis understands;      
       'config_folder','');  % folder where user configurations should reside; it is calculated 
   % automatically by the config_folder function;
       
  % fields which are not allowed to change using set methods
    config_data.fields_sealed={'nInstances','config_folder','instrument_names_allowed'};
   
   % the instruments LIBISIS understands
    config_data.instruments_allowed={'het','let','maps','mari','merlin'};
    
    % Verify if the default instrument directory variable exisits (it would
    % if you are in Libisis) and if not  set it to the folder
    % under the directory where the Homer_ver0 has been called from (this will be
    % the stand-alone default location
    rootpath = fileparts(which('libisis_init'));
    instr_files_location = parse_path([rootpath '/../InstrumentFiles/']);
    if ~exist(instr_files_location,'dir') % stand-alone?
        instr_files_location=fullfile(pwd,'InstrumentFiles');        
    end
    config_data.instruments_root_dir=instr_files_location;
    

    
% save-restore configuration
    config_data.config_folder = config_folder(config_data.config_folder_name);
    config_file_name          = mfilename('class');
    config_data=save_restore_data(config_data,config_data.config_folder,config_file_name);
    % class is a singleton, but as it can be inherited by value from other
    % classes, the counter nInstances intended to keep this information
    config_data.nInstances=1;
% declare class    
    configurations{1} = class(config_data,'config');    
    class_names{1}    = 'config';
end
if nargin>0
    if strcmp(varargin{1},'inherited')
        configurations{1}.nInstances=configurations{1}.nInstances+1;
    end
end
conf = configurations{1};

