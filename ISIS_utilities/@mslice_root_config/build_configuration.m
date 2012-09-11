function build_configuration(this, default_config_fun, config_name)
% Construct a configuration structure, save in memory and to file.
%
%   >> build_configuration (config, default_config_fun, config_name)
%
% Input:
% ------
%   config              Instance of the root configuration class
%   default_config_fun  Function that returns default structure for the configuration class
%   config_name         Name of the configuration class
%
%
% In detail:
% ----------
% Set a configuration in memory from previously saved configuration structure stored
% in a .mat file associated with the particular configuration class name. 
%
% If the file does not exist (e.g. not been created before or has been deleted), or the
% contents of the file are out of date (as determined from the default structure
% constructor), then the default structure is saved to file.
%
% In either case, the current configuration and default configuration are saved in
% memory.

% NOTE: This method has to be public because it is used by the constructor of all
%       configuration objects. It should not be used in any other context.
%
% $Revision: 128 $ ($Date: 2012-01-23 08:30:12 +0000 (Mon, 23 Jan 2012) $)


% Determine if the class has already been constructed - if so, then nothing to do
if config_store(config_name)
    return
end

% Build configuration
root_config_name=mfilename('class');

% Get default configuration
default_config_data=default_config_fun();     % () is required to indicate that this is a function, even though it takes no arguments
[valid,mess]=check_fields_valid(default_config_data,root_config_name);  % To check no developer errors
if ~valid, error('Fields not all valid in default configuration: %s',mess), end

% Get stored configuration, if any
file_name = config_file_name (config_name);
[saved_config_data,ok,mess] = load_config (file_name);

% Build configuration from file, if can. Note that load_config will return
% ok==true if the config file does not exist but with config_data_saved empty.
% We check the validity of the fields in the config file because it may have
% been constructed via a route other than the constructor for this configuration.

if ~isempty(saved_config_data)   % configuration data read from file
    % Check fields in saved configuration match those in child default
    if isequal(fieldnames(saved_config_data),fieldnames(default_config_data))
        [valid,mess]=check_fields_valid(saved_config_data,root_config_name);
        if valid
            config_store(config_name,saved_config_data,default_config_data,this)
            return
        else
            warning(['Fields not all valid in saved configuration for %s: %s.',...
                '\nIt will be updated with default values.'],config_name,mess)
        end
    else
        warning('CONFIG:build_configuration','Out of date configuration format for %s.\nIt will be updated with default values.',config_name)
    end
elseif ~ok
    warning('CONFIG:build_configuration','%s \n Building configuration for %s with default values',mess,config_name)
end

% Save configuration from defaults.
[ok,mess]=save_config(file_name,default_config_data);
if ~ok, error(mess), end
config_store(config_name,default_config_data,default_config_data,this);