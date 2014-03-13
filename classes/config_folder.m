function folder_path=config_folder(folder_short_name)
% the function creates a filder to store user configuration files for libusus 
% and horace. The function returns full path to the configuration folder 
% actually it just tries to create the folder with the name
% 'folder_short_name' in the set of preferred locations and creates this
% folder in the first location allowed for write access. 
%
% error is thrown if the folder can not be created in any default locations
%
% >> folder_path=config_folder(folder_short_name)
%
% The folder for horace and libisis user configurations is created
% in the following order:
%
% 1) in the place where the startup.m file is located.
% 2) in Matlab preferences directory;
% 3) if there are no startup.m file or its folder is write-protected 
%    try to create this folder under the user profile folder
% 4) if this location does not exist or write protected, try userpath
% 5) if 3) fails, try working directory
%    
%  if 5) fails than something is fundamentally wrong and error is thrown. 
%
%
% $Revision: 200 $ ($Date: 2011-11-24 14:05:19 +0000 (Thu, 24 Nov 2011) $)
%
    location = which('startup.m');    
    if ~isempty(location)
            location=fileparts(location);
            [success,folder_path] = try_to_create_folder(location,folder_short_name);
            if success;   return;
            end
    end
    
    % try to use matlab preferences directory
    location = prefdir();
    if exist(location,'dir')
        % store configuration in a version-independent location;
        version_folder=regexp(version() ,'\w*','match');
        verstr=version_folder{5};
        if ispc
            verstr=['\\',verstr];
        else
            verstr=[filesep,verstr];            
        end
        location=regexprep(location, [verstr,'$'], '');
        
        [success,folder_path] = try_to_create_folder(location,folder_short_name);
        if success;   return;
        end                
    end
    
    % startup does not exist, preferences are ?unavailible? try user profile;
    if ispc
        location = getenv('USERPROFILE');
    else
        location = getenv('HOME'); 
    end

     if exist(location,'dir')
        [success,folder_path] = try_to_create_folder(location,folder_short_name);
        if success;   return;
        end
     end
     
     % something wrong with user profile, try matlab user folder
     location = userpath;
     if exist(location,'dir')
        [success,folder_path] = try_to_create_folder(location,folder_short_name);
        if success;   return;
        end
     end

     % somethins is fundamentally wrong
    location = pwd;
    if exist(location,'dir')
       [success,folder_path,message] = try_to_create_folder(location,folder_short_name);
       if ~success
            help config_folder;            
            error('CONFIG:config_folder',' can not create configuration directory %s, in any of Err: %s',folder_short_name,message);            
       end
    else
        help config_folder;
        error('CONFIG:config_folder','no one of default locations exists or availible for writing to create folder %s',folder_short_name);
    end
    
    
   
    function [success,folder_path,mess]=try_to_create_folder(location,folder_short_name)
    folder_path = [location,filesep,folder_short_name];
    
    if ~exist(folder_path,'dir')
        [success, mess] = mkdir(folder_path);        
    else
        success=true;
        mess = '';
    end
        
        