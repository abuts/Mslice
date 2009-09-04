function mslice_make_distribution_kit
% Run this function to convert the contents of the mslice svn as checked out
% to convert into a distribution kit.
%
% Creates a temporary directory in which to make the distribution, and then
% creates a zip file, mslice.zip, in the mslice home directory.


% Name of zip file to hold distribution (no path must be given)
zipfile='mslice.zip';

start_dir=pwd;
try
    % Get root directory, and ensure this is the pwd
    parent_dir = fileparts(which('mslice_init'));
    cd (parent_dir)

    % Make copy in a temporary directory
    tmpdir=tempdir;   % get temporary directory
    if isempty(tmpdir)
        error('Unable to locate temporary directory name')
    end
    tmpdir = fullfile(tmpdir,'mslice_temporary_distribution_creation');
    if exist(tmpdir,'dir')
        rmdir(tmpdir,'s')
    end
    mkdir(tmpdir);

    % Copy files:
    copyfile([parent_dir,'*.*'],tmpdir,'f');

    % Remove all the .svn folders
    directoryRecurse(tmpdir,@remove_svn)

    % Create zip file
    if exist(zipfile,'file')
        delete(zipfile)     % Delete any zip file with the output name
    end
    zip(zipfile,'*',tmpdir)    % Create zip file

    % Delete the temporary folder
    rmdir(tmpdir,'s')

    % Return to starting directory
    cd(start_dir);

catch
    cd(start_dir);
    error('Problems creating mex files. Please try again.')
end


%===============================================================================
function remove_svn (directory)
% If present, removes directory .svn from absolute directory name passed as argument
contents=dir(directory);
ind_svn=find(strcmpi('.svn',{contents([contents.isdir]).name}),1);
if ~isempty(ind_svn)
    rmdir(fullfile(directory,contents(ind_svn).name),'s')
end


%===============================================================================
% directoryRecurse - Recurse through sub directories executing function pointer
%===============================================================================
% Description   : Recurses through each directory, passing the full directory
%                 path and any extraneous arguments (varargin) to the specified
%                 function pointer
%
% Parameters    : directory        - Top level directory begin recursion from
%                 function_pointer - function to execute with each directory as
%                                    its first argument
%                 varargin         - Any extra arguments that should be passed
%                                    to the function pointer.
%
% Call Sequence : directoryRecurse(directory, function_pointer, varargin)
%
%                 IE: To execute the 'rmdir' command with the 's' parameter over
%                     'c:\tmp' and all subdirectories
%
%                     directoryRecurse('c:\tmp', @rmdir, 's')
%
% Author        : Rodney Thomson
%                 http://iheartmatlab.blogspot.com
%===============================================================================
function directoryRecurse(directory, function_pointer, varargin)

contents    = dir(directory);
directories = find([contents.isdir]);

% For loop will be skipped when directory contains no sub-directories
for i_dir = directories

    sub_directory  = contents(i_dir).name;
    full_directory = fullfile(directory, sub_directory);

    % ignore '.' and '..'
    if (strcmp(sub_directory, '.') || strcmp(sub_directory, '..'))
        continue;
    end

    % Recurse down
    directoryRecurse(full_directory, function_pointer, varargin{:});
end

% execute the callback with any supplied parameters.
% Due to recursion will execute in a bottom up manner
function_pointer(directory, varargin{:});
