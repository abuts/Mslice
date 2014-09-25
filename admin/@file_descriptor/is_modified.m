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

old_targ_chksum = this.targ_checksum;
old_chksum = this.checksum;

store_destination   = false;

if isempty(this.target_name)
    store_destination =true;
    copy_source=true;
else
    mslice_file = fullfile(this.dest_path,this.target_fname);
    if ~exist(mslice_file,'file')
        copy_source = true;
    else
        source_file = fullfile(this.source_path,this.source_name);
        if ~exist(source_file,'file')
            error('FILE_DESCRIPTOR:is_modified','Can not find source file %s',source_file);
        end
        new_chksum = calc_checksum(source_file);
        
        if old_chksum == new_chksum
            copy_source=false;
        else
            copy_source=true;
            this.checksum_ = new_chksum;
        end
        if copy_source
            % we need to check if destignation file was also changed independingtly
            % in case of replacing it with the new file from source
            new_targ_chksum = calc_checksum(mslice_file);
            if old_targ_chksum ~=new_targ_chksum
                store_destination = true;
                if new_targ_chksum ~=old_targ_chksum
                    this.targ_checksum_ = new_targ_chksum;
                end
            end
        end
        
    end
end


