function mslice_off
% Remove paths to all mslice root directory and all sub-directories.
%
% To remove mslice from the matlab path, type
%   >> mslice_off

% T.G.Perring
%
% $Revision: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%


% root directory is assumed to be that in which this function resides
rootpath = fileparts(which('mslice_off'));

% Close down mslice, if running
try
    mslice_finish   % sometimes this might not be on the path e.g. if mslice has not been initialised. Do not want mslice_off to fail.
catch
end

warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
try
    paths = genpath(rootpath);
    rmpath(paths);
    warning(warn_state);    % return warnings to initial state
catch
    warning(warn_state);    % return warnings to initial state if error encountered
    error('Problems removing "%s" and sub-directories from matlab path',rootpath)
end
