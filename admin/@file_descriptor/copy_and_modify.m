function this=copy_and_modify(this)
% copy the file contents from source to destination,
% replacing specified strings by its replacements
%
%
%   $Rev: 285 $ ($Date: 2014-04-04 15:57:36 +0100 (Fri, 04 Apr 2014) $)
%


if isempty(this.source_name)
    return;
end

sources = this.fields_to_modify_;
modifiers = this.modify_with_;
n_fields_to_modify = numel(sources);
if ~strcmp(this.source_name,this.target_fname)
    sources = [sources,this.source_name_];
    modifiers = [modifiers,this.target_name_];
    n_fields_to_modify = n_fields_to_modify+1;
end

fsource = fullfile(this.source_path,this.source_name);
%
dest_name = this.dest_path;
if ~(exist(dest_name ,'dir')==7)
    mkdir(dest_name );
end
fdest   = fullfile(dest_name,this.target_fname);

fs=fopen(fsource,'r');
if fs<=0
    error('FUNC_COPIER:copyAndModify',' error opening source file %s',fsource);
end
ft= fopen(fdest,'w');
if ft<=0
    error('FUNC_COPIER:copyAndModify',' error opening target file file %s',fdest);
end

line = fgets(fs);
while(line>-1)
    
    for i=1:n_fields_to_modify
        line = strrep(line,sources{i},modifiers{i});
    end
    
    fprintf(ft,'%s',line);
    line = fgets(fs);
end
fclose(ft);
fclose(fs);
if n_fields_to_modify>0
    this.targ_checksum_ = calc_checksum(fdest);
else
    % set target checksum equal to source checksum
    this.targ_checksum_=[];
end

