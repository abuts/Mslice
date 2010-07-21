function thePath=find_path(partPath)
% function finds the particular path to the folder containing partPath 
% in the total matlab path
%
% returns either first full path leading to the string of '' if found
% nothing
% function use returns first found path if more then one possible
% e.g.:
% if the folder 'Libisis' is in the Matlab search path likeL
% c:\users\Libisis\utilites;c:\users\Libisis;d:\folders\Libisis 
%
% thePath=find_path('Libisis') 
% will return c:\users\Libisis;
%
% Libisis:
% $Revision$ ($Date$)
%
% build cell array of folders in the path
allPath = regexp(path,pathsep,'split'); 

% replace all possible occurences of \ with \\ as \ has special meaning in
% regular expressions
partPath    = regexprep(partPath,'\\','\\\\');
% identify the path-es which has partPath at the end
pathExist   = regexp(allPath,[partPath,'$']);
% build boolean array identifying notempty folders among all folders
existing=~cellfun('isempty',pathExist);

if any(existing)
    existingPath=allPath(existing);
    thePath = existingPath(1);
    thePath = thePath{1}; % de-cell
else
    thePath='';
end


