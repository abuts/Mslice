function files_list=copy_files_list(source_dir,targ_dir,varargin)
% copy the files under the source directory source_dir to target directory
% targ_dir omitting .svn subfolders and retaining the directory structure;
% 
% if third parameter is present, copy only the files with extentions, which 
% are in the list of varargins; if one of the extenisons has sign "-"
% before it -- do not copy files with this extension
% otherwise, copy everything. 
% 
% examples:
%   copy_files_list(source_dir,targ_dir) or  
%   copy_files_list(source_dir,targ_dir,'*')      -- copy everything from source to target dir
%
%   copy_files_list(source_dir,targ_dir,'-m') -- copy everything except  m -files
%
%   copy_files_list(source_dir,targ_dir,'m')  or
%   copy_files_list(source_dir,targ_dir,'.m')     -- copy files with extension .m
%   
% 
% 
% returns the cell array containing the full list of the files copied;
% Libisis: 
% $Revision$ ($ Date: $)
%
global source_dir_root;
global targ_dir_root;
global extention;
global include_service_difectory;

% if the list of extensions includes -, this means that everyting except
% what is marked with - is copied, so, include_all_extensions has to be
% true and the sign '*' (copy all extentions) has to be added to the list
% of extensions;
include_service_difectory=false;
if(nargin==2)
    extention={'*'}; 
else  
    % modify the input list of extensions to be of the standard kind, like
    % returned by the "fileparts" function
    [extention,include_service_difectory]=process_extentions(varargin);
end
source_dir_root = source_dir;
targ_dir_root   = targ_dir;

if(~exist(source_dir,'dir'))
     error(' Source director %s does not exist',source_dir);
end
files_list=copy_files_list_recursively(source_dir);


function [local_list,targ_dir]=copy_files_list_recursively(source_dir)

global source_dir_root;
global targ_dir_root;
global include_service_difectory;


% initialise variables
CVS         = '.svn'; % qualifier for subversion folder
serviceDir  = '_';    % qualifier for service directory which should not be copyed unless 
                      % it is special OS-version dependant directory
if(include_service_difectory)
    serviceDir=CVS;
end

% list all entries in the source directory
localFiles_list = dir(source_dir);
if isempty(localFiles_list)
  return
end


% define the target subdirectory by replacing the root path of the source
% directory with the root path of the target directory. 
if strncmp(computer,'PC',2)
    rep_expr='\\$';
else
    rep_expr='/$';    
end
source_dir_root=regexprep(source_dir_root,rep_expr,'');
targ_dir_root  =regexprep(targ_dir_root,rep_expr,'');
targ_dir= strrep(source_dir,source_dir_root,targ_dir_root);

if(~exist(targ_dir,'dir'))
    [status, message]=mkdir(targ_dir);
    if(~status)
        error(' Can not create the target directory %s, Reason: %s',targ_dir,message);
    end
end

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,localFiles_list.isdir));
isfile = ~isdir;
files     = localFiles_list(isfile);
local_list=copyFileList(source_dir,targ_dir,files);
%
% Recursively descend through directories 
%
dirs = localFiles_list(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.')           && ...
         ~strcmp( dirname,'..')          && ...
         ~strcmp( dirname,CVS)          
         if(~strncmp(dirname,serviceDir,1))
            [ll,targ0_directory]=copy_files_list_recursively(fullfile(source_dir,dirname));% recursive calling of this function.
            local_list=[local_list,ll]; 
            % remove target directory if nothing was copyied into it
            if isempty(ll)
                rmdir(targ0_directory);
            end
            
         else
             if(strncmpi(['_',computer],dirname,6)||strncmpi('_R200',dirname,5))  % this is system OS directory which is needed and has to be copyed
                [ll,targ0_directory]=copy_files_list_recursively(fullfile(source_dir,dirname)); % recursive calling of this function.
                local_list=[local_list,ll];                  
               % remove target directory if nothing was copyied into it
                if isempty(ll)
                    rmdir(targ0_directory);
                end
                
             end
         end
   end
end
function local_list=copyFileList(sourcePath,destPath,filelist)
% set logical vector for files entries in 
global extention;


isfile = ~logical(cat(1,filelist.isdir));
fileList = filelist(isfile); % select only files from the current listing
nFiles =length(fileList); 

local_list=cell(1,nFiles);

non_empty_cells = logical(zeros(1,nFiles));
for i=1:nFiles
    [path,name,ext]=fileparts(fileList(i).name);
    if should_be_ignored(ext,extention)
        non_empty_cells(i) = false;
        continue;
    end
    
    destFile  = [destPath,filesep,name,ext];
%    if(exist(destFile,'file'))
%        fileInfo=dir(destFile);
%        if(fileInfo.bytes==fileList(i).bytes) % the file we want to copy is 
%                            %probably the same as the one already there;
%            continue;       % skip copying;                
%        end
%    end
    [success,message]=copyfile([sourcePath,filesep,fileList(i).name],destFile,'f');   
    if(~success)
       warning([' Can not copy file: %s, to its working destination,\n', ... 
                ' copyfile returned message: %s \n ', ...
                ' installation may not work properly\n'],fileList(i).name,message);       
    else
        local_list{i}=destFile;
        non_empty_cells(i) = true;        
    end

end
   
local_list = local_list(non_empty_cells);   
%%
function [extention,include_service_difectory]=process_extentions(extention)
% modify the input list of extensions to be of the standard kind, like
% returned by the "fileparts" function

include_all_extensions   =false;
include_service_difectory=false;
%  
% analyse system if system folders ('started from '+_') included 
is_system_folder_present=cellfun(@is_system_folder,extention);
if any(is_system_folder_present)
    include_all_extensions   =true;
    include_service_difectory=true;
    non_system_folder=~is_system_folder_present;
    extention={extention{non_system_folder}};
end
% 
% analyse keys which begin with '-'
is_minus=cellfun(@is_first_minus,extention); %
any_minus=any(is_minus);
if any_minus
   include_all_extensions=true;                
   ext_with_minus={extention{is_minus}};
   no_dot_after_miuns = cellfun(@absent_dot_after_minus,ext_with_minus);
   ext_mindot=cellfun(@insert_dot_before_minus,{ext_with_minus{no_dot_after_miuns}},'UniformOutput',false);   
   extention=[ext_mindot,extention{~is_minus}];
   is_minus=cellfun(@is_first_minus,extention); %   
end

% analyse keys starting with '+'; remove plus sign
is_plus=cellfun(@is_first_plus,extention);
any_plus=any(is_plus);
if any_plus
    include_all_extensions=false;                   
    ext_plus_removed=cellfun(@remove_first_symb,{extention{is_plus}},'UniformOutput',false);
    extention=[ext_plus_removed,{extention{~is_plus}}];
end

if ~any_minus && (~any_plus) && nargin>1
    include_all_extensions=false;
end

% only minus and no special symbol extensions remain. 
% insert dots in no-dot extention
no_first_dot=cellfun(@is_first_dot,{extention{~is_minus}});
if any(~no_first_dot)
    half_no_min  ={extention{~is_minus}};
    half_is_min  ={extention{is_minus}};    
    half_no_min  = cellfun(@add_dot,{half_no_min{~no_first_dot}},'UniformOutput',false);
    extention    =[half_is_min,half_no_min];
end
% add * at the end of extensions if including them all
if include_all_extensions
    has_star_sighn=cellfun(@is_dotstar,extention);
    if any(has_star_sighn)
        ind = find(has_star_sighn);
        extention{ind}=extention{end};
        extention{end}='*';
    else
        extention{end+1}='*';
    end
    
end

%% start CELL Functions
function isit=is_system_folder(string)
if isempty(string)
    isit=false;
else
    isit=strncmp(string,'+_',2);
end
function isit=is_first_minus(string)
if isempty(string)
    isit=false;
else
    isit=(string(1)=='-');
end
function string=insert_dot_before_minus(string)
if ~isempty(string)
    string=['-.',string(2:end)];
end
function isit=is_first_plus(string)
if isempty(string)
    isit=false;
else
    isit=(string(1)=='+');
end
function string=remove_first_symb(string)
if ~isempty(string)
    string=string(2:end);
end
function isit=is_first_dot(string)
if isempty(string)
    isit=false;
else
    isit=(string(1)=='.');
end
function string=add_dot(string)
string=['.',string];
function isit=absent_dot_after_minus(string)
if isempty(string)
    isit=false;
else
    isit=~strncmp(string,'-.',2);    
end
function isit=is_dotstar(string)
if isempty(string)
    isit=false;
else
    isit=strncmp(string,'.*',2);
end

%% END CELL Functions
%%
function ignore=should_be_ignored(ext,varargin)
% function checks if the extension ext is in the list of the varargin list
% of the extensions that should be ignored; 
% 
% the extension ext is ignored if it is in the list with the sigh '-' or it is
% not in the list
for i=1:nargin-1
    tag = varargin{i};
    tag = tag{1};
    if tag == '*' % all extensions are allowed
        ignore= false;
    else
        if tag(1:1)== '-'
            tag     = tag(2:length(tag));            
            if strcmpi(ext,tag) 
                ignore= true;                                
            else
                ignore = false;                        
            end
        else
            if strcmpi(ext,tag)    
                ignore= false;                
            else
                ignore= true;        
            end            
        end
    end
end
