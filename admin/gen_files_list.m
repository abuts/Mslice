function file_names = gen_files_list(folder_path,folder_name,top_files)
% Generate  list of all files  in the directory and its
% subdirectories with file path related to the root folder directory
%
%
%   $Rev: 268 $ ($Date: 2014-03-13 14:11:31 +0000 (Thu, 13 Mar 2014) $)
%

%
if ~exist('folder_name','var')
    folder_name = '';           % path to be returned
end
if ~exist('top_files','var')
    top_files = {};
end

entries = dir(folder_path);
% set logical vector for subdirectory entries in dir
isdir = logical(cat(1,entries.isdir));
files = entries(~isdir);
if isempty(files)
    if exist('top_files','var')
        file_names = top_files;
    else
        file_names ={};
    end
else
    tmp = struct2cell(files);
    %file_names = fullfile(folder_name,tmp(1,:));
    % for compartibility with matlab 2008b
    joiner = @(X) fullfile(folder_name,X);
    file_names = cellfun(joiner,tmp(1,:),'UniformOutput',false);

    file_names = [top_files(:);file_names(:)];
end


%
% Recursively descend through directories
dirs = entries(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
    dirname = dirs(i).name;
    if  ~strcmp( dirname,'.')           && ...
            ~strcmp( dirname,'..')      && ...
            ~strcmp( dirname,'.svn')    && ...
            ~strcmp( dirname,'.git')
        
        % recursive calling of this function.        
        file_names=gen_files_list(fullfile(folder_path,dirname),...
                   fullfile(folder_name,dirname),file_names); 
    end
end
