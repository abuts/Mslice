function [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=mslice_version()
% the function returns the version of mslice, which should correspond to
% the distinctive tag version from the SVN server. 
%
% Usage:
% [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=mslice_version()
% [application,Matlab_SVN,mexMinVer,mexMaxVer,date]=mslice_version('brief')
% 
% where application is a structure containing the fields with program name
% (mslice)and mslice release version. 
%
% if mslice_version is called with parameter, the function
% returns revision data (Matlab_SVN) as number rather then string
% (convenient for versions comparison)
%
%
% An pre-commit hook script provided as part of the package 
% has to be enabled on svn and svn file properies 
% (Keywords) Date and Revision should be set on this file 
% to support valid Matlab versioning.
%
% The script will modify the data of this file before committing. 
% The variable below introduced to allow the commit hook touching this file and 
% make this touches available to the svn (may be it is a cumbersome solution, but is 
% the best and most portable for any OS I can think of). 
%
%
% $COMMIT_COUNTER:: 1 $
%
% No variable below this one should resemble COMMIT_COUNTER, as their values will 
% be modified and probably corrupted at commit
% after the counter changed, the svn version row below will be updated 
% to the latest svn version at commit.

application.name='mslice';


application.version=2;

Matlab_SVN='$Revision:: 839  $ ($Date:: 2014-03-25 11:39:36 +0000 (Tue, 25 Mar 2014) $)';

% Information about name and version of application
mexMinVer     = [];
mexMaxVer     = [];
date          = [];
mcf = mslice_config;
if mcf.use_mex
    [mex_messages,n_errors,mexMinVer,mexMaxVer,date]=check_mex_version();
    if n_errors~= 0
        mcf.use_mex=0;
    end
end
hd     =str2double(Matlab_SVN(12:17));

application.svn_version=hd;
application.mex_min_version = mexMinVer;
application.mex_max_version = mexMaxVer;
application.mex_last_compilation_date=date;
if nargin>0    
    Matlab_SVN =application.svn_version;
end
