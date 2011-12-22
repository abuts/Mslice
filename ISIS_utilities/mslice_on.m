function path=mslice_on(non_default_path)
% The function intended to swich mslice on and
% return the path were mslice is resided or 
% empty string if mslice has not been found
%
%
% The function has to be present in Matlab search path 
% and modified for each machine to know default mslice location
%
%Usage:
%>>path=mslice_on(); 
%       enables mslice and initiates mslice default search path
%
%>>path=mslice_on('where'); 
%       reports current location of mslice or empty if not found
%
%>>path=mslice_on('a path'); 
%       initiates mslice on non-default search path
%
%
%
%
msl_default_path='c:/Users/wkc26243/Documents/work/svn/Mslice';
%
if exist('non_default_path','var') && strcmpi(non_default_path,'where')
    path = find_default_path(her_default_path);   
    return;
end
%
if nargin==1 
    start_app(non_default_path);    
else
    start_app(msl_default_path);    
end
path = fileparts(which('mslice_init.m'));


function start_app(path)

try
    mslice_off;
catch
end
addpath(path);
mslice_init;

function path =find_default_path(her_default_path)
path = which('mslice_init.m');
if isempty(path)
    path = her_default_path;
    if ~exist(fullfile(path,'mslice_init.m'),'file')
        path='';
    end
else
    path=fileparts(path);
end
