function [copy_source,store_destination,this]=is_modified(this)
% method checks if the source file was modified
%
% if it was modified, the method also checks if the desrignation file
% was changed from original
%
% the file assumed modified when its checksum is changed
%
%
%   $Rev: 288 $ ($Date: 2014-04-05 21:48:22 +0100 (Sat, 05 Apr 2014) $)
%

old_dest_chksum = this.dest_checksum;
old_chksum = this.checksum;

store_destination   = false;

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
            if this.n_fields_to_modify>0
                sources = this.fields_to_modify_;
                modifiers = this.modify_with_;
                for i=1:this.n_fields_to_modify
                    this.mod_success_.(sources{i})=modifiers{i};
                end
            end
            %fprintf('File %s : modified line %s with %s ',this.source_name,lineO,line);
        else
            copy_source=true;
            this.checksum_ = new_chksum;
        end
        if copy_source
            % we need to check if destignation file was also changed independingtly
            % in case of replacing it with the new file from source
            new_dest_chksum = calc_checksum(dest_file);
            if old_dest_chksum ~=new_dest_chksum
                store_destination = true;
                if new_dest_chksum ~=old_dest_chksum
                    this.dest_checksum_ = new_dest_chksum;
                end
            end
        end
        
    end
end


