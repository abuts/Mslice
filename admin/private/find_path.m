function thePath=find_path(partPath)
% function finds the particular path to the folder containing partPath 
% at the end of one of the matlab search path-es
%
% returns either first full path leading to the string partPath 
% or '' if found nothing
%
% function returns first found path if more then one path is possible
% e.g.:
% if the folder 'Libisis' is in the Matlab search path like:
% c:\users\Libisis\utilites;c:\users\Libisis;d:\folders\Libisis 
%
% thePath=find_path('Libisis') 
% will return c:\users\Libisis;
%
% the function searches for case-insensitive string on PC or case sensitive
% path under unix/mac
%
% function has been used in folders synchronization between different packages. 
% At the moment this function is not used anywhere as the synchcronization is disconnected. 
%
%
% Libisis:
% $Revision: 200 $ ($Date: 2011-11-24 14:05:19 +0000 (Thu, 24 Nov 2011) $)
%
% build cell array of folders in the path
allPath = regexp(path,pathsep,'split'); 

if ispc
    % replace all possible occurences of \ with \\ as \ has special meaning in
    % regular expressions
    partPath    = regexprep(partPath,'\\','\\\\');
    % identify the path-es which has partPath at the end
    pathExist   = regexpi(allPath,[partPath,'$']);
else
    pathExist   = regexp(allPath,[partPath,'$']);    
end
% build boolean array identifying notempty folders among all folders
existing=~cellfun('isempty',pathExist);

if any(existing)
    existingPath=allPath(existing);
    thePath = existingPath(1);
    thePath = thePath{1}; % de-cell
else
    thePath='';
end


