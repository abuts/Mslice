function [config_data,ok,mess] = load_config (file_name)
% Load configuration from file, if it exists. Otherwise, return empty structure.
%
%   >> [config_data,ok,mess] = load_config (file_name)
%
% Input:
% ------
%   file_name       Name of file that contains configuration. Assumed to be a
%                  .mat file with the configuration saved as a variable
%                  called config_data.
%   
% Output:
% -------
%   config_data     Structure containing configuration data. Empty if problem or file does not exist
%   ok              File succesfully read, or file does not exist
%   mess            Message. Empty if ok==true

% $Revision: 122 $ ($Date: 2011-12-23 16:33:53 +0000 (Fri, 23 Dec 2011) $)

if exist(file_name,'file')
    try
        S=load(file_name,'-mat');
    catch
        config_data=struct([]);
        ok=false;
        mess=['Problem reading configuration file ',file_name];
        return
    end
    if isfield(S,'config_data') && isstruct(S.config_data)
        config_data=S.config_data;
    else
        config_data=struct([]);
        ok=false;
        mess=['Contents of file ',file_name,' are not configuration data'];
        return
    end
else
    config_data=struct([]);
end

ok=true;
mess='';
