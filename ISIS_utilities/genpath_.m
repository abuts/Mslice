function p = genpath_(d)
% Generate recursive toolbox path and adds these directories to the Matlab search path.
% Differs from the standard Matlab
% function genpath as it works  excluding from the path subversion (.svn)
% folders and the folders which start with _ (underscore)
% (it seems,  this is relevant for Windows only, as unix ignores them anyway)
% and adds the allowed directories to the path
%
% Otherwise, it behaves like normal genpath,
% namely:
%
%   P = GENPATH returns a new path string by adding all the subdirectories
%   of MATLABROOT/toolbox, including empty subdirectories.
%
%   P = GENPATH(D) returns a path string starting in D, plus, recursively,
%   all the subdirectories of D, including empty subdirectories.
%
%   NOTE 1: GENPATH will not exactly recreate the original MATLAB path.
%
%   NOTE 2: GENPATH only includes subdirectories allowed on the MATLAB
%   path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Modified in ISIS
%
%   Libisis:
%   $Revision$ $Date$
%------------------------------------------------------------------------------
if nargin==0,
  p = genpath(fullfile(matlabroot,'toolbox'));
  if length(p) > 1, p(end) = []; end % Remove trailing pathsep
  return
end

% initialise variables
classsep = '@';      % qualifier for overloaded class directories
packagesep = '+';    % qualifier for overloaded package directories
CVS        = '.svn'; % qualifier for subversion folder
serviceDir    = '_';
p = '';                % path to be returned

% Generate path based on given root directory
files = dir(d);
if isempty(files)
  return
end

% Add d to the path even if it is empty.
p = [p d pathsep];

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.')           && ...
         ~strcmp( dirname,'..')          && ...
         ~strcmp( dirname,CVS)           && ...
         ~strncmp( dirname,classsep,1)   && ...
         ~strncmp( dirname,packagesep,1) && ...
         ~strncmp(dirname,serviceDir,1)  && ...
         ~strcmp( dirname,'private')
     
         p = [p genpath_(fullfile(d,dirname))]; % recursive calling of this function.
   end
end

