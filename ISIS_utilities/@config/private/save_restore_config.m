function config_data=save_restore_config(this,config_data,config_file_name)
% saves of restores the structure  config_data into the specific file
% config_file_name
% saves     if the file config_file_name does not exists
% restores  if the file config_file_name do exist
% 
% the folder where to read/write files is defined by the config constructor

config_data=save_restore_data(config_data,this.config_folder,config_file_name);
