function [copy_source,store_destination,mod_targ]=is_modified(this,varargin)
% method checks if the source file was modified
%
% if it was modified, the method also checks if the destination file
% was changed from original
%
% the file assumed modified when its checksum is changed
%
%
%   $Rev$ ($Date$)
%


old_dest_chksum = this.dest_checksum;
old_chksum = this.checksum;
mod_targ  = file_descriptor(this);

store_destination   = false;
check_thoroughly = true;
if nargin>1
    check_thoroughly=varargin{1};
end

if isempty(this.dest_name)
    store_destination =true;
    copy_source=true;
else
    dest_file = fullfile(this.dest_path,this.dest_fname);
    if ~exist(dest_file,'file')
        copy_source = true;
    else
        source_file = fullfile(this.source_path,this.source_name);
        if ~exist(source_file,'file')
            error('FILE_DESCRIPTOR:is_modified','Can not find source file %s',source_file);
        end
        new_chksum = calc_checksum(source_file);
        
        if old_chksum == new_chksum
            copy_source=false;
            % assume all fields needing copying were copied.
            mod_targ = set_modifiers(this,mod_targ);
        else
            copy_source=true;
            mod_targ.checksum_ = new_chksum;
        end
        % Destignation file is present
        if copy_source
            % we need to check if destignation file was also changed independingtly
            % in case of replacing it with the new file from source
            new_dest_chksum = calc_checksum(dest_file);
            if old_dest_chksum ~=new_dest_chksum
                store_destination = true;
                if new_dest_chksum ~=old_dest_chksum
                    if mod_targ.checksum_ ~=mod_targ.dest_checksum_
                        mod_targ.dest_checksum_ = new_dest_chksum;
                    else
                        mod_targ.dest_checksum_ =[];
                    end
                end
            end
        else
            if check_thoroughly
            % destignation file is present, but we still want to check if copying 
            % source to destignation would change something. This option is
            % necessary when source file modifiers were changed
                if this.n_fields_to_modify == 0
                    new_dest_chksum = calc_checksum(dest_file);
                else
                    test_file = fullfile(tempdir,this.dest_fname);
                    cl1 = onCleanup(@()delete(test_file));
                    new_dest_chksum=copy_and_modify_file(source_file,test_file,this.fields_to_modify_,this.modify_with_);
                end
                if this.dest_checksum ~= new_dest_chksum
                    mod_targ.dest_checksum_ = new_dest_chksum;
                    copy_source = true;
                    store_destination = true;
                end
            end
            
        end
    end
end

function mod_targ=set_modifiers(this,mod_targ)
if this.n_fields_to_modify>0
    sources = this.fields_to_modify_;
    modifiers = this.modify_with_;
    for i=1:this.n_fields_to_modify
        mod_targ.mod_success_.(sources{i})=modifiers{i};
    end
end
%fprintf('File %s : modified line %s with %s ',this.source_name,lineO,line);

