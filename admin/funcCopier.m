classdef funcCopier
    %Class to copy specified dependent functions/methods from Herbert to
    % mslice
    %
    %
    %   $Rev$ ($Date$)
    %
    properties
        % target root folder
        mslice_folder;
        % source root folder
        herbert_folder;
        % structure containing information about the dependent files to
        % copy/check
        files_2copy_list;
        % where the file with the information above is normally stored
        config_file_path;
    end
    
    methods
        function obj=funcCopier(varargin)
            if nargin==0
                obj=obj.init();
            else
                obj.files_2copy_list=struct();
                obj.config_file_path='';
            end
        end
        %------------------------------------------------------------------
        function obj= init(obj)
            obj.mslice_folder= fileparts(which('mslice_init'));
            obj.herbert_folder= fileparts(which('herbert_init'));
            if isempty(obj.mslice_folder) || isempty(obj.herbert_folder)
                error('FUNC_COPIED:constructor',...
                    'both herbert and mslice have to be on a data search path for this class to work');
            end
            obj.files_2copy_list = struct();
            obj.config_file_path=fileparts(mfilename('fullpath'));
        end
        
        %------------------------------------------------------------------
        function save_list(this,filename)
            func_names = fieldnames(this.files_2copy_list);
            
            nStrings = numel(func_names);
            if nStrings==0; return ;   end
            
            full_file = fullfile(this.config_file_path,filename);
            fh=fopen(full_file,'w+');
            if fh<0; error('FUNC_COPIER:save_list',' can not open file %s to write data',filename); end
            fprintf(fh,'func_name;checksum; herbert_path; mslice_path\n');
            for i=1:nStrings
                func = func_names{i};
                data2save = this.files_2copy_list.(func);
                if isfield(data2save,'fext')
                    fext = data2save.fext;
                else
                    fext='.m';
                end
                fprintf(fh,'%s;%s;%d;%s;%s;%s\n',func,data2save.fname,data2save.checksum,data2save.source,data2save.dest,fext);
            end
            fclose(fh);
        end
        %------------------------------------------------------------------
        function this=load_list(this,filename)
            full_file = fullfile(this.config_file_path,filename);
            fh=fopen(full_file,'r');
            if fh<0;
                warning('FUNC_COPIER:save_list',' can not open file %s to read data. Nothing loaded',filename);
                return;
            end
            
            this.files_2copy_list = struct();
            % scip header
            fgetl(fh);
            line = fgetl(fh);
            while ischar(line)
                rez = strsplit(line,';');
                rez{3} = str2double(rez{3});
                descriptor = struct('fname',rez{2},'checksum',rez{3},...
                    'source',rez{4},'dest',rez{5},'copy',false);
                if ~strcmpi(rez{6},'.m')
                    descriptor.fext = rez{6};
                end
                this.files_2copy_list.(rez{1})=descriptor;
                line=fgetl(fh);
            end
            fclose(fh);
        end
        %------------------------------------------------------------------
        function this=add_dependency(this,function_name,target_folder,source_subpath)
            % method to add new dependency to the dependencies list.
            %
            if ~exist('source_subpath','var')
                source_subpath = '';
            end
            
            full_name = fullfile(this.herbert_folder,function_name);
            if exist(full_name,'file')==2
                source = full_name;
            elseif exist(function_name,'file')==2
                source = which(function_name);                
            elseif exist(full_name,'dir')==7
                files=gen_files_list(full_name,function_name);
                [fp,fn]=fileparts(function_name);
                if fn(1) == '@'
                    source_subpath_base = fp;
                else
                    source_subpath_base = function_name;
                end
                
                for i=1:numel(files)
                    the_file=files{i};
                    [fp,fn,fext]=fileparts(the_file);
                    source_subpath = this.extract_base(source_subpath_base,fp);
                    this=this.add_dependency(the_file,target_folder,source_subpath);
                end
                return
            else
                error('FUNC_COPIER:add_dependency',' can not find function %s ',function_name);
            end
            
            checksum = calc_checksum(source);
            
            [source_path,fname,fext]=fileparts(source);
            % extract root herbert folder from the source path
            source_path = this.extract_base(this.herbert_folder,source_path);
            % 
            key_name = this.build_key_name(source_subpath,[fname,fext]);
            %
            if isfield(this.files_2copy_list,key_name)
                descriptor = this.files_2copy_list.(key_name);
                this.files_2copy_list.(key_name) = this.check_for_changes(descriptor);
            else
                targ = fullfile(target_folder,source_subpath);
                descriptor = struct('fname',fname,'checksum',checksum,'source',source_path,'dest',targ,'copy',true);
                if ~strcmpi(fext,'.m')
                    descriptor.fext=fext;
                end
                this.files_2copy_list.(key_name)=descriptor;
                
            end
        end
        %------------------------------------------------------------------
        function this=copy_dependencies(this)
            % method copies source functions into target functions if
            % such functions are marked as need copying by another methods
            names = fieldnames(this.files_2copy_list);
            for i=1:numel(names)
                descriptor = this.files_2copy_list.(names{i});
                if ~descriptor.copy
                    continue;
                end
                fsource = this.source_path(descriptor);
                fdest   = this.target_path(descriptor);
                funcCopier.check_or_make_target_folder(fdest);
                copyfile(fsource,fdest)
            end
        end
        %------------------------------------------------------------------
        function this=check_dependencies(this)
            %  method checks existing dependencies and mark them for
            %  copying if the dependency contents have changed.
            
            names = fieldnames(this.files_2copy_list);
            for i=1:numel(names)
                descriptor = this.files_2copy_list.(names{i});
                this.files_2copy_list.(names{i}) = ...
                    this.check_for_changes(descriptor);
            end
            
        end
        function newDescr= check_for_changes(this,descriptor)
            % method check if the file defimed by the descriptor have
            % changed and needs copying.
            %
            newDescr = descriptor;
            
            fsource = this.source_path(descriptor);
            fdest   = this.target_path(descriptor);
            checksum= calc_checksum(fsource);
            % target has been deleted.
            if ~exist(fdest,'file')
                newDescr.copy = true;
                newDescr.checksum=checksum;
                return;
            end
            
            trg_sum = calc_checksum(fdest);
            if trg_sum == checksum
                newDescr.copy = false;
                newDescr.checksum = checksum;
                return
            end
            
            % mslice file has been changed independently, and we need to
            % store it
            if descriptor.checksum ~=trg_sum
                newDescr.copy = true;
                newDescr.checksum = checksum;
                fbackup=this.target_path(descriptor,'_mslice_back.m');
                movefile(fdest,fbackup,'f')
            end
            
            newDescr.copy = true;
            newDescr.checksum = checksum;
            
            return;
        end
        %
        function path =target_path(this,descriptor,fname,fext)
            fbase = descriptor.dest;
            if ~exist('fext','var')
                if isfield(descriptor,'fext')
                    fext = descriptor.fext;
                else
                    fext = '.m';
                end
            end
            if ~exist('fname','var')
                fname = descriptor.fname;
            end
            path = fullfile(this.mslice_folder,fbase,[fname,fext]);
        end
        %
        function path =source_path(this,descriptor,fname,fext)
            fbase = descriptor.source;
            if ~exist('fext','var')
                if isfield(descriptor,'fext')
                    fext = descriptor.fext;
                else
                    fext = '.m';
                end
                
            end
            if ~exist('fname','var')
                fname = descriptor.fname;
            end
            
            path = fullfile(this.herbert_folder,fbase,[fname,fext]);
        end
        
    end
    methods(Static)
        function check_or_make_target_folder(file_name)
            % make target path recursively;
            fpath=fileparts(file_name);
            if exist(fpath,'dir')==7
                return;
            else
                fpath1=fileparts(fpath);
                if exist(fpath1,'dir')==7
                    mkdir(fpath);
                else
                    funcCopier.check_or_make_target_folder(fpath);
                end
            end
        end
        function func_name = build_key_name(source_path,fname)
            % function takes the path and function name provided as
            % input arguments and generates form them the string
            % which can be used as valid field name of a matlab structure.
            %
            func_name = fullfile(source_path,fname);
            if ispc
                func_name = regexprep(func_name,'[\\,@,\.]','_');
            else
                func_name = regexprep(func_name,'[/,@,\.]','_');
            end
            if func_name(1)=='_'
                func_name(1)='a';
            end
        end
        %
        function path = extract_base(herbert_folder,source_path)
            path_len = numel(herbert_folder);
            if strncmpi(herbert_folder,source_path,path_len)
                path = source_path(path_len+1:end);
            else
                error('FUNC_COPIER:extract_base',' the folder %s is not under the path %s',source_path,source_path);
            end
            
        end
        
    end
end

