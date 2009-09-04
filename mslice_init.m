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

% Other directories
addpath_message (rootpath,'mslice');
addpath_message (rootpath,'mslice_extras');
addpath_message (rootpath,'mslice_more_extras');

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
