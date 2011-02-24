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
       'config_folder','');  % folder where user configurations should reside; it is calculated 
   % automatically by the config_folder function;
       
  % fields which are not allowed to change using set methods
    config_data.fields_sealed={'nInstances','config_folder'};
   

    
% save-restore configuration
    config_data.config_folder = config_folder(config_data.config_folder_name);
    config_data.nInstances=   0;    
    config_data.last_used_matlab_version=version();
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

