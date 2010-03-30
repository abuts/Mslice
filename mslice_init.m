function mslice_init
% Adds the paths needed by mslice.
%
% In your startup.m, add the mslice root path and call mslice_init, e.g.
%   addpath('c:\mprogs\mslice')
%   mslice_init
%
% Is PC and Unix compatible.

% T.G.Perring

% root directory is assumed to be that in which this function resides
rootpath = fileparts(which('mslice_init'));
addpath(rootpath)  % MUST have rootpath so that mslice_init, mslice_off included

% compartibility and interpackage dependensies directory
addpath_message (rootpath,'ISIS_utilities');
if exist('libisis_init.m','file')   % if libisis is on the path we populate ISIS_utilities with contents from Libisis
    try % this is to deal with problem of really old version of libisis initiated on the machine
    if libisis_version('number')>1620 % this is the Libisis version which supports this feature
        source_path=find_path(['Libisis',filesep,'ISIS_utilities']);
        [sucsess,message,messageID]=copyfile([source_path,'/*.m'],[rootpath,'/ISIS_utilities/'],'f');
        if ~sucsess
            warning(messageID,' Error copying libisis-dependant mslice function, Reason: ',message);
        end
    end
    catch
        warning('Mslice::OldEnvironmnet',...
                 [' You have very old Luibisis initiated on your computer;',...
                 ' It may preven this program from working properly',...
                 ' You adwised to update your Libisis version to more recent version']);
    end
end
% Other directories
addpath_message (rootpath,'mslice');
addpath_message (rootpath,'mslice_extras');
addpath_message (rootpath,'mslice_more_extras');
addpath_message (rootpath,'DLL');
disp('!==================================================================!')
disp('!              MSLICE classic (ISIS modifcations from 01/01/2010)  !')
disp('!==================================================================!')


%--------------------------------------------------------------------------
function addpath_message (varargin)
% Add a path from the component directory names, printing a message if the
% directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\mslice','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:});
if exist(string,'dir')==7
    addpath (string);
else
    warning('"%s" is not a directory - not added to path',string)
end
