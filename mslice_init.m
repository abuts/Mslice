function mslice_init
% Adds the paths needed by mslice.
%
% In your startup.m, add the mslice root path and call mslice_init, e.g.
%   addpath('c:\mprogs\mslice')
%   mslice_init
%
% Is PC and Unix compatible.

% T.G.Perring
%
% $Revision$ ($Date$)
%


% root directory is assumed to be that in which this function resides
rootpath = fileparts(which('mslice_init'));
addpath(rootpath)  % MUST have rootpath so that mslice_init, mslice_off included
addpath(fullfile(rootpath,'admin'));
addpath(fullfile(rootpath,'ISIS_utilities'));
% compatibility and interpackage dependencies directory

% this option is disabled as we do not bind mslice and libisis any more

% if exist('libisis_init.m','file')   % if libisis is on the path we populate ISIS_utilities with contents from Libisis
%     try % this is to deal with problem of really old version of libisis initiated on the machine
%      libisis_ver=libisis_version('number');
%      last_copied_ver=get(mslice_config,'last_copied_libisis');
%      if libisis_ver>last_copied_ver % libisis_ver==last_copied_ver this is the Libisis version which supports this feature
%         path = fileparts(which('libisis_init.m'));
%         source_path=find_path([path,filesep,'ISIS_utilities']);
%         filelist=copy_files_list(source_path,[rootpath,'/ISIS_utilities/']);
%         sucsess=numel(filelist);
%         if ~sucsess
%             warning(messageID,' Error copying libisis-dependant mslice function, Reason: %s',message);
%         else
%             disp(' New Libisis version has been found on the machine and Libisis-defined functions from ISIS_utilites folder have been copied to Mslice');
%             set(mslice_config,'last_copied_libisis',libisis_ver);            
%         end
%      end
%     catch
%         warning('MSLICE:OldEnvironmnet',...
%                  [' You have very old Libisis initiated on your computer;',...
%                  ' It may prevent this program from working properly',...
%                  ' You adwised to update your Libisis version to more recent version']);
%     end
% end
% Other directories
addpath_message (rootpath,'mslice');
addpath_message (rootpath,'mslice_extras');
addpath_message (rootpath,'mslice_more_extras');
addpath_message (rootpath,'DLL');
% temporary option used during debugging and transition to herbert io
herbert_io('-off');
% developer machine option
if get(mslice_config,'enable_unit_tests')
    if ~exist('herbert_init.m','file')
        try
            her_path=herbert_on('where');
            % need to clear persistent variable
            addpath_message (fullfile(her_path,'_test/matlab_xunit/xunit'));
        catch
            warning('MSLICE:init','can not initate unit tests framework requested by configuration');
        end
    end
    addpath_message(rootpath,'admin','_unit_test');
end

disp('!==================================================================!')
disp('!                      MSLICE                                      !')
disp('!------------------------------------------------------------------!')
disp('!  Radu Coldea    1998-2001                                        !')
disp('!  Various ISIS modifications and enhancements added               !')
disp('!  Last ISIS substantial modifications date: 18/10/2013            !')
disp('!------------------------------------------------------------------!')


%--------------------------------------------------------------------------
function addpath_message (varargin)
% Add a path from the component directory names, printing a message if the
% directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\mslice','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:});
if exist(string,'dir')==7
    path=genpath_special(string);
    addpath (path);
else
    warning('"%s" is not a directory - not added to path',string)
end
