classdef funcCopier
    %Class to copy specified dependent functions/methods from Herbert to
    % mslice
    %
    %
    %   $Rev: 268 $ ($Date: 2014-03-13 14:11:31 +0000 (Thu, 13 Mar 2014) $)
    %
    properties
        mslice_folder;
        herbert_folder;
        files_2copy_list;
    end
    
    methods
        function obj=funcCopier(varargin)
            if nargin==0
                obj.init();
            end
        end
        %------------------------------------------------------------------
        function this= init(this)
            obj.mslice_folder= fileparts(which('mslice_init'));
            obj.herbert_folder= fileparts(which('herbert_init'));
            if isempty(obj.mslice_folder) || isempty(obj.herbert_folder)
                error('FUNC_COPIED:constructor',...
                    'both herbert and mslice have to be on a data search path for this class to work');
            end
            obj.files_2copy_list = struct();
        end
        %------------------------------------------------------------------
        function save_list(this,filename)
            func_names = fieldnames(this.files_2copy_list);
            
            nStrings = numel(func_names);
            if nStrings==0; return ;   end
            
            fh=fopen(filename,'w+');
            if fh<0; error('FUNC_COPIER:save_list',' can not open file %s to write data',filename); end
            fprintf(fh,'func_name;checksum; herbert_path; mslice_path\n');
            for i=1:nStrings
                func = func_names{i};
                data2save = this.files_2copy_list.(func);
                fprintf(fh,'%s;%d;%s;%s\n',func,data2save.checksum,data2save.source,data2save.dest);
            end
            fclose(fh);
        end
        %------------------------------------------------------------------
        function this=load_list(this,filename)
            fh=fopen(filename,'r');
            if fh<0; error('FUNC_COPIER:save_list',' can not open file %s to read data',filename); end
            
            this.files_2copy_list = struct();
            % scip header
            fgetl(fh);
            line = fgetl(fh);
            while ischar(line)
                rez = strsplit(line,';');
                rez{2} = str2double(rez{2});
                this.files_2copy_list.(rez{1})=struct('checksum',rez{2},'source',rez{3},'dest',rez{4},'copy',false);
                line=fgetl(fh);
            end
            fclose(fh);
        end
        %------------------------------------------------------------------
        function this=add_dependency(this,function_name,target_folder)
            source = which(function_name);
            if isempty(source)
                folder=fullfile(this.herbert_folder,function_name);
                if exist(folder,'dir')
                else
                    error('FUNC_COPIER:add_dependency',' can not find function %s on Matlab search path',function_name);
                end
            end
            
            if ~isempty(target_folder)
                target_path = fullfile(this.mslice_folder,target_folder);
            else
                target_path = this.mslice_folder;
            end
            if ~exist(target_path,'dir')
                error('FUNC_COPIER:add_dependency',' target path %s do not exist ',target_path);
            end
            
            if exist(source,'file')
                checksum = calc_checksum(source);
            else
                error('FUNC_COPIER:add_dependency',' can not find source file %s ',source);
            end
            [source_path,fname]=fileparts(source);
            sourcePathLength = numel(this.herbert_folder);
            if strncmp(source_path,this.herbert_folder,sourcePathLength)
                source_path=source_path(sourcePathLength+1:end);
            else
                error('FUNC_COPIER:add_dependency','Source path %s is not within source folder %s',source_path,this.herbert_folder)
            end
            if isfield(this.files_2copy_list,fname)
                descriptor = this.files_2copy_list.(fname);
                
                if descriptor.checksum==checksum
                    old_sum = descriptor.checksum;
                    fdest = fullfile(this.mslice_folder,descriptor.dest,[fname,'.m']);
                    if exist(fdest,'file')
                        msl_sum = calc_checksum(fdest);
                        if msl_sum ~= old_sum
                            fbackup=fullfile(this.mslice_folder,descriptor.dest,[fname,'_mslice_back.m']);
                            movefile(fdest,fbackup,'f')
                        end
                    end
                    descriptor.checksum = checksum;
                    descriptor.copy = true;
                    
                    this.files_2copy_list.(fname)=descriptor;
                else
                    this.files_2copy_list.(fname).copy = false;
                    
                end
            else
                this.files_2copy_list.(fname)=struct('checksum',checksum,'source',source_path,'dest',target_folder,'copy',true);
            end
        end
        %------------------------------------------------------------------
        function this=copy_dependencies(this)
            names = fieldnames(this.files_2copy_list);
            for i=1:numel(names)
                descriptor = this.files_2copy_list.(names{i});
                if ~descriptor.copy
                    continue;
                end
                fsource = fullfile(this.herbert_folder,descriptor.source,[names{i},'.m']);
                fdest = fullfile(this.mslice_folder,descriptor.dest,[names{i},'.m']);
                copyfile(fsource,fdest)
            end
            
        end
    end
    methods(Static)
        function files = gen_files_list(folder,rootFolder)
            % Generate  list of all files in  in the  directory
            files = dir(folder);
            if isempty(files)
                return
            end
            % initialise variables
            classsep = '@';  % qualifier for overloaded class directories
            packagesep = '+';  % qualifier for overloaded package directories
            svn        = '.svn'; % subversion folder
            p = '';           % path to be returned
            
            %             % Add d to the path even if it is empty.
            %             p = [p folder pathsep];
            %
            % set logical vector for subdirectory entries in d
            isdir = logical(cat(1,files.isdir));
            %
            % Recursively descend through directories which are neither
            % private nor "class" directories.
            %
            dirs = files(isdir); % select only directory entries from the current listing
            
            for i=1:length(dirs)
                dirname = dirs(i).name;
                if      ~strcmp( dirname,'.')           && ...
                        ~strcmp( dirname,'..')          && ...
                        ~strncmp( dirname,classsep,1)   && ...
                        ~strncmp( dirname,packagesep,1) && ...
                        ~strcmp( dirname,'private')     && ...
                        ~strcmp( dirname,svn)
                    if ~strncmp( dirname,service_dir,1)
                        p = [p genpath_special(fullfile(d,dirname))]; % recursive calling of this function.
                    else
                    end
                end
            end
        end
        
