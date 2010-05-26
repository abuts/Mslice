function config=set_defaults(config,class_name)
% function returns the configuration settings to its default values
% specified in class constructor;
global configurations;
global class_names;

if ~isempty(configurations)
    this_class_name  = class(config);    
    if nargin==1
        class_name=this_class_name;
    end
    config_file_path = config_folder(config);

    if strcmp(this_class_name,class_name) % clearing the whole configuration
        delete([config_file_path,filesep,'*.*']);
    else                                  % clearing particular class configuration only
        config_file = fullfile(config_file_path,[class_name,'.mat']);
        delete(config_file);
    end
    % remove everything from memory;
    clear global configurations;
    clear global class_names;
end

