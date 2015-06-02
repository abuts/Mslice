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

[application,Matlab_code,mexMinVer,mexMaxVer,date] = mslice_version();

mc = [Matlab_code(1:48),'$)'];



disp('!==================================================================!')
disp('!                      MSLICE                                      !')
disp('!------------------------------------------------------------------!')
disp('! Radu Coldea: 1998-2001 & ISIS addons and enhancements: 2001-2014 !')
if isempty(mexMaxVer)
    disp('! Mex code:    Disabled  or not supported on this platform         !')
else
    if mexMinVer==mexMaxVer
        mess=sprintf('! Mex files  : $Revision::%4d  $ (%s $)  !',mexMaxVer,date(1:end-7));
    else
        mess=sprintf(...
            '! Mex files  : $Revisions::%4d-%3d(%s $) !',mexMinVer,mexMaxVer,date(1:end-7));
        
    end
    disp(mess)
end
disp('! Matlab code: Last ISIS substantial modifications date: 01/06/2014!')
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
