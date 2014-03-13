function config_data=save_restore_data(config_data,config_folder,config_file_name)
% save or restore data depending on the existence of the file with
% configuration data
%
% >> config_data=save_restore_config(config_data,config_folder,config_file_name)
% 
%  config_data -- the structure with the data to save/restore
%  config_folder     | the parts of the full path to the configuration data
%  config_file_name  |
%
% $Revision$ ($Date$)
%
config_file = fullfile(config_folder,[config_file_name,'.mat']);
if exist(config_file,'file')
     n_config_fields=numel(fieldnames(config_data));
     S=load(config_file,'-mat');          
     n_old_fields = numel(fieldnames(S.config_data));
     if n_config_fields ~= n_old_fields
         warning('CONFIG:save_restore_data',...
         ['Your  %s configuration is outdated and has been deleted.',...
          ' The settings in %s has been reverted to the defaults'],...   
         config_file_name,config_file_name)
         delete(config_file);
         save(config_file,'config_data')        
     else
         config_data=S.config_data;         
     end
     
else
     save(config_file,'config_data')
end
