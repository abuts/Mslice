classdef file_descriptor
    % the class to describe a file, which should be copied
    % from Herbert to MSLICE
    %
    %   $Rev$ ($Date$)
    %
    
    properties(Dependent)
        % short file name
        source_name='';
        % the name of the file within mslice. Usually it is the same name
        % as source_name, unless specified otherwise.
        dest_fname;
        % name of the target file withour extension
        dest_name;
        % file checksum
        checksum=0;
        % taret file checksum. Different if the file is modified at copying
        dest_checksum;
        %
        % full path of the sourñe file within Herbert
        source_path
        % short source path within Herbert (excluding herbert location)
        short_source_path;
        %
        % full path of the taget file within Mslice
        dest_path
        % short destignation path within Mslice
        short_dest_path;
        
        % number of keywords, one needs to change in the file, for it to be
        % Mslice rather then Herbert class
        n_fields_to_modify;
        % true if the file is the classdef with its own folder named the
        % same as the file plus sign @
        is_folder_class
    end
    properties(Access=protected)
        % short source file name
        source_name_='';
        % short target file name
        dest_name_='';
        % source file checksum. Used to verify if source file have changed
        checksum_=0;
        % target file checksum. Used to verify if target file has been
        % changed and needs backing up. If no fields were provided to
        % modify, source checksum has to be equal to target checksum.
        dest_checksum_=[];
        % source path within the herbert folder
        source_path_=''
        % destination path within the mslice folder
        dest_path_=''
        % file extension
        fext_='.m'
        % fields to modify when copying from herbert to mslice
        fields_to_modify_={};
        % the text to replace with when copying from herbert to mslice.
        modify_with_ = {};
        % internal sign of folder class id
        is_folder_class_=false;
        % the field contains the paris which were successfully modified
        % during copy and modify process
        mod_success_ = struct();
    end
    properties(Constant,Access=protected)
        % the names of the fields which always written to file
        fields_to_write_={'source_name_','checksum_','source_path_','is_folder_class_',...
            'dest_path_','dest_name_','dest_checksum_','fext_'};
        % format of these fields
        fields_format_={'%s','%lu','%s','%d','%s','%s','%lu','%s'};
    end
    
    
    methods(Static)
        function path = root_source_path()
            % root path to source files (path to herbert)
            path = source_dest.instance().source_folder;
        end
        function mpath = root_dest_path()
            % root folder of destination files (mslice root)
            mpath = source_dest.instance().dest_folder;
            
        end
        function fields = get_fieldnames_to_write()
            fields  = file_descriptor.fields_to_write_;
        end
    end
    methods
        function this=file_descriptor(varargin)
            if nargin>0
                if isa(varargin{1},'file_descriptor')
                    this=varargin{1};
                else
                    this=this.build_from_file(varargin{1});
                end
            end
        end
        %
        function this=from_string(this,string)
            % method to init file descriptor from specially prepared string
            % (as it has been written to a file and recovered now)
            this=build_contents_from_string(this,string);
        end
        %
        function str=to_string(this)
            % convert file descriptor to a sting writtable to a file
            str= drop_contents_to_string(this);
        end
        %---------------------------------------------------
        function name = get.source_name(this)
            name = [this.source_name_,this.fext_];
        end
        function this = set.source_name(this,full_name)
            % set the name of the source file for copying
            % this may include full path within herbert and the file
            % extension.
            this=build_from_file(this,full_name);
        end
        %----------------------------------------------------
        function name=get.dest_fname(this)
            % the name of a file in a mslice folder (usually equal to the
            % name in a herbert folder)
            name = [this.dest_name,this.fext_];
        end
        function name=get.dest_name(this)
            % the name of a file in a mslice folder (usually equal to the
            % name in a herbert folder withour extension)
            if isempty(this.dest_name_)
                name = this.source_name_;
            else
                name = this.dest_name_;
            end
            
        end
        
        function this=set.dest_name(this,filename)
            % set a name of the file in the mslice folder different
            % from the name in a herbert folder.
            [path,name,ext]=fileparts(filename);
            if strcmp(name,this.source_name_)
                this.dest_name_ ='';
            else
                this.dest_name_ = name;
            end
            if ~isempty(ext)
                this.fext_  = ext;
            end
            if isempty(path)
                % set up short dest path to be sure it is still valid for
                % new name (which may change)
                this.short_dest_path=this.short_dest_path;
            else
                this.short_dest_path=path;
            end
        end
        %------------------------------------
        function spath = get.short_dest_path(this)
            if isempty(this.dest_path_);
                spath = this.source_path_;
            else
                if numel(this.dest_path_)==1 && this.dest_path_== '-'
                    spath ='';
                else
                    spath = this.dest_path_;
                end
            end
        end
        
        function this=set.short_dest_path(this,path)
            this = build_short_dest_path(this,path);
        end
        %------------------------------------
        function is=get.is_folder_class(this)
            is = this.is_folder_class_;
        end
        
        function nf=get.n_fields_to_modify(this)
            nf = numel(this.fields_to_modify_);
        end
        
        function cksm = get.checksum(this)
            cksm = int64(this.checksum_);
        end
        function cksm = get.dest_checksum(this)
            if isempty(this.dest_checksum_)
                cksm = int64(this.checksum_);
            else
                cksm = int64(this.dest_checksum_);
            end
        end
        function dpath = get.dest_path(this)
            mpath = this.root_dest_path();
            dpath = fullfile(mpath,this.short_dest_path);
        end
        
        function spath = get.short_source_path(this)
            spath = this.source_path_;
        end
        function spath = get.source_path(this)
            hpath = this.root_source_path();
            spath = fullfile(hpath,this.source_path_);
        end
        %----------------------------------------------------
        %----------------------------------------------------
        function this=add_modifiers(this,varargin)
            nvar = numel(varargin);
            if mod(nvar,2)~=0
                error('FILE_DESCRIPTOR:invalid_parameters','Odd number of modifiers. You should provide modifiers in the form key,value,key,value ...')
            end
            if numel(this.fields_to_modify_) == 0
                this.fields_to_modify_ = varargin(1:2:nvar-1);
                this.modify_with_ = varargin(2:2:nvar);
            else
                this.fields_to_modify_ ={this.fields_to_modify_{:}, varargin{1:2:nvar-1}};
                this.modify_with_ = {this.modify_with_{:},varargin{2:2:nvar}};
            end
            
        end
        function is_rep = fields_replaced(this)
            % method reports on how many fields copy_and_modify function
            % have modified if copying indeed happened.
            rep_fields = fields(this.mod_success_);
            if numel(rep_fields)>0
                is_rep  = true;
            else
                is_rep  = false;
            end
        end
    end
end