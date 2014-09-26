classdef funcCopier
    %Class to copy specified dependent functions/methods from Herbert to
    % mslice
    %
    %
    %   $Rev$ ($Date$)
    %
    properties(Dependent)
        % target root folder
        mslice_folder;
        % source root folder
        herbert_folder;
    end
    properties
        % structure containing information about the dependent files to
        % copy/check
        files_2copy_list;
        % where the file with the information above is normally stored
        config_file_path;
    end
    properties(Constant,Access=private)
        % fields to modify in Herbert class to work in mslice class
        fields_to_modify_={'herbert_config','use_mex_C'};
        modify_with_={'mslice_config','use_mex'};
    end
    properties(Access=protected)
        % target root folder
        mslice_folder_;
        % source root folder
        herbert_folder_;
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
        function folder = get.mslice_folder(this)
            folder = this.mslice_folder_;
        end
        function folder = get.herbert_folder(this)
            folder = this.herbert_folder_;
        end
        function this = set.mslice_folder(this,folder)
            source_dest.instance().set_dest_folder(folder);
            this.mslice_folder_ = source_dest.instance().dest_folder ;
        end
        function this = set.herbert_folder(this,folder)
            source_dest.instance().set_source_folder(folder);
            this.herbert_folder_ = source_dest.instance().source_folder;
        end
        
        
        %------------------------------------------------------------------
        function obj= init(obj)
            obj.mslice_folder = fileparts(which('mslice_init.m'));
            obj.herbert_folder=fileparts(which('herbert_init.m'));
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
            main_fields = file_descriptor.get_fieldnames_to_write();
            fprintf(fh,'%s;',main_fields{:});
            fprintf(fh,'\n');
            for i=1:nStrings
                descr= this.files_2copy_list.(func_names{i});
                str = descr.to_string();
                fprintf(fh,'%s\n',str);
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
            fd = file_descriptor();
            % scip header
            fgetl(fh);
            line = fgetl(fh);
            while ischar(line)
                fd1=fd.from_string(line);
                key_name = get_key_name(fd1);
                this.files_2copy_list.(key_name) = fd1;
                line=fgetl(fh);
            end
            fclose(fh);
            nDependencies = numel(fieldnames(this.files_2copy_list));
            fprintf('****** loaded  %d Herbert dependencies\n',nDependencies);
            
            
        end
        %------------------------------------------------------------------
        function this=add_dependency(this,dep,varargin)
            % method to add new dependency to the dependencies list.
            %
            if nargin>2
                control = varargin{1};
            else
                control = struct();
            end
            if isa(dep,'file_descriptor')
                key_name = get_key_name(dep);
                this.files_2copy_list.(key_name)=dep;
                return
            else
                full_name = fullfile(this.herbert_folder,dep);
                
                
                if isfield(control,'dest_folder')
                    target_folder = control.dest_folder;
                else
                    target_folder = '';
                end
                
                if exist(full_name,'file')==2
                    source = full_name;
                elseif exist(dep,'file')==2
                    source = which(dep);
                elseif exist(full_name,'dir')==7
                    files=gen_files_list(full_name,dep);
                    for i=1:numel(files)
                        the_file=files{i};
                        if ~isempty(target_folder)
                            control.dest_folder=this.replace_path_cut_root(the_file,dep,target_folder);
                        end
                        
                        this=this.add_dependency(the_file,control);
                    end
                    return
                else
                    error('FUNC_COPIER:add_dependency',' can not find function %s ',dep);
                end
            end
            
            fd = file_descriptor(source);
            if ~isempty(target_folder)
                fd.short_dest_path = target_folder;
            end
            if isfield(control,'modifiers')
                mod = control.modifiers;
                fd=fd.add_modifiers(mod{:});
            end
            if isfield(control,'rename_class')
                % initially, destination name is equal to the source name
                if strcmp(control.rename_class{1},fd.dest_name)
                    fd.dest_name = control.rename_class{2};
                else
                    fd=fd.add_modifiers(control.rename_class{:});
                end
            end
            
            key_name = get_key_name(fd);
            this.files_2copy_list.(key_name)=fd;
            
        end
        %------------------------------------------------------------------
        function this=copy_dependencies(this)
            % method copies source functions into target functions if
            % such functions are marked as need copying by another methods
            names = fieldnames(this.files_2copy_list);
            nBackedUp = 0;
            nCopied =0;
            nCopiedAndModified=0;
            nDependencies = numel(names);
            for i=1:nDependencies
                descriptor = this.files_2copy_list.(names{i});
                [source_modidied,target_modified,check]= descriptor.is_modified();
                if source_modidied
                    if target_modified % make copy of the target file and tell about it
                        targ_file = fullfile(descriptor.dest_path,descriptor.dest_fname);
                        backup    = fullfile(descriptor.dest_path,[descriptor.dest_name,'.bak']);
                        fprintf('**** Backing up file: %s  at:-> %s\n',descriptor.dest_fname,descriptor.dest_path);
                        copyfile(targ_file,backup);
                        nBackedUp =nBackedUp +1;
                        
                    end
                    this.files_2copy_list.(names{i})=descriptor.copy_and_modify();
                    nCopied=nCopied+1;
                    if this.files_2copy_list.(names{i}).fields_replaced()
                        nCopiedAndModified=nCopiedAndModified+1;
                    end
                else
                    this.files_2copy_list.(names{i}) = check;
                end
                
            end
            fprintf('****** Copied    %d Herbert files out of %d dependencies\n',nCopied,nDependencies);
            fprintf('****** Modified  %d files during the copying\n ',nCopiedAndModified);
            fprintf('****** Backed up %d files changed in Mslice\n ',nBackedUp);
        end
        
        
    end
    methods(Static)
        function path = replace_path_cut_root(fname,sample,replacement)
            path = fileparts(fname);
            path = regexprep(path,'\\','/');
            sample=regexprep(sample,'\\','/');
            
            start = regexp(path,sample,'once');
            path = [replacement,path(start+numel(sample):end)];
            
        end
    end
    
end

