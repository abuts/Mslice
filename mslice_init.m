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


% Other directories
addpath_message(fullfile(rootpath,'core'));
addpath_message (rootpath,'utilities');
addpath_message (rootpath,'classes');
addpath_message (rootpath,'applications');

% compatibility and interpackage dependencies directory
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
    addpath_message(rootpath,'_test');
end

disp('!==================================================================!')
disp('!                      MSLICE                                      !')
disp('!------------------------------------------------------------------!')
disp('!  Radu Coldea    1998-2001                                        !')
disp('!  Various ISIS modifications and enhancements added               !')
disp('!  Last ISIS substantial modifications date: 01/05/2014            !')
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
