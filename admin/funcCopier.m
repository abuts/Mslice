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
                fprintf(fh,'%s;%s,%d;%s;%s\n',func,data2save.fname,data2save.checksum,data2save.source,data2save.dest);
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
                this.files_2copy_list.(rez{1})=struct('fname',rez{2},'checksum',rez{3},...
                    'source',rez{4},'dest',rez{5},'copy',false);
                line=fgetl(fh);
            end
            fclose(fh);
        end
        %------------------------------------------------------------------
        function this=add_dependency(this,function_name,target_folder)
            % method to add new dependency to the dependencies list.
            %
            full_name = fullfile(this.herbert_folder,function_name);
            if exist(function_name,'file')==2
                source = function_name;
            elseif exist(full_name,'file')==2
                source = full_name;
            elseif exist(full_name,'dir')==7
                files=gen_files_list(full_name,full_name);
                [fp,fn]=fileparts(function_name);
                if fn(1) == '@'
                    targ_ext =fn;
                else
                   targ_ext ='';
                end
                for i=1:numel(files)
                    the_file=files{i};
                    tf = fullfile(target_folder,targ_ext);
                    this=this.add_dependency(the_file,tf);
                end
                return
            else
                error('FUNC_COPIER:add_dependency',' can not find function %s ',function_name);
            end
           
            checksum = calc_checksum(source);
             
            [source_path,fname]=fileparts(source);
            sourcePathLength = numel(this.herbert_folder);
            if strncmp(source_path,this.herbert_folder,sourcePathLength)
                source_path=source_path(sourcePathLength+1:end);
            else
                error('FUNC_COPIER:add_dependency','Source path %s is not within source folder %s',source_path,this.herbert_folder)
            end
            func_name = this.flatten(source_path,fname);
            %
            if isfield(this.files_2copy_list,func_name)
                descriptor = this.files_2copy_list.(func_name);
                this.files_2copy_list.(func_name) = this.check_for_changes(func_name,descriptor);
            else
                this.files_2copy_list.(func_name)=struct('fname',fname,'checksum',checksum,'source',source_path,'dest',target_folder,'copy',true);
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
                fsource = fullfile(this.herbert_folder,descriptor.source,[names{i},'.m']);
                fdest = fullfile(this.mslice_folder,descriptor.dest,[names{i},'.m']);
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
            
            fsource = fullfile(this.herbert_folder,descriptor.source,[descriptor.fname,'.m']);
            fdest   = fullfile(this.mslice_folder,descriptor.dest,[descriptor.fname,'.m']);
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
                fbackup=fullfile(this.mslice_folder,descriptor.dest,[fname,'_mslice_back.m']);
                movefile(fdest,fbackup,'f')
            end
            
            newDescr.copy = true;
            newDescr.checksum = checksum;
            
            return;
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
        function func_name = flatten(source_path,fname)
            func_name = fullfile(source_path,fname);
            if ispc
                func_name = regexprep(func_name,'[\\,@]','_');
            else
                func_name = regexprep(func_name,'[/,@]','_');                
            end
            if func_name(1)=='_'
                func_name(1)='a';
            end
        end
        
    end
end

