function this=copy_and_modify(this)
% copy the file contents from source to destination,
% replacing specified strings by its replacements
%
%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%


if isempty(this.source_name)
    return;
end

sources = this.fields_to_modify_;
modifiers = this.modify_with_;
if ~strcmp(this.source_name,this.dest_fname)
    sources = [sources,this.source_name_];
    modifiers = [modifiers,this.dest_name_];
end

fsource = fullfile(this.source_path,this.source_name);
%
dest_name = this.dest_path;
if ~(exist(dest_name ,'dir')==7)
    mkdir(dest_name );
end
fdest   = fullfile(dest_name,this.dest_fname);

[this.dest_checksum_,this.mod_success_]=copy_and_modify_file(fsource,fdest,sources,modifiers);


