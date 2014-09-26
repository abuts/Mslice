function this=copy_and_modify(this)
% copy the file contents from source to destination,
% replacing specified strings by its replacements
%
%
%   $Rev$ ($Date$)
%


if isempty(this.source_name)
    return;
end

sources = this.fields_to_modify_;
modifiers = this.modify_with_;
n_fields_to_modify = numel(sources);
if ~strcmp(this.source_name,this.dest_fname)
    sources = [sources,this.source_name_];
    modifiers = [modifiers,this.dest_name_];
    n_fields_to_modify = n_fields_to_modify+1;
end

fsource = fullfile(this.source_path,this.source_name);
%
dest_name = this.dest_path;
if ~(exist(dest_name ,'dir')==7)
    mkdir(dest_name );
end
fdest   = fullfile(dest_name,this.dest_fname);

fs=fopen(fsource,'r');
if fs<=0
    error('FUNC_COPIER:copyAndModify',' error opening source file %s',fsource);
end
ft= fopen(fdest,'w');
if ft<=0
    error('FUNC_COPIER:copyAndModify',' error opening target file file %s',fdest);
end
% clear all previous information (got may be from loading) abour successfully replaced
% modification fields.
this.mod_success_=struct();

line = fgets(fs);
while(line>-1)
    
    for i=1:n_fields_to_modify
        lineO = line;
        line = strrep(line,sources{i},modifiers{i});
        if ~strcmp(line,lineO)
            this.mod_success_.(sources{i})=modifiers{i};
            %fprintf('File %s : modified line %s with %s ',this.source_name,lineO,line);
        end
    end
    
    fprintf(ft,'%s',line);
    line = fgets(fs);
end
fclose(ft);
fclose(fs);
if n_fields_to_modify>0
    this.dest_checksum_ = calc_checksum(fdest);
else
    % set target checksum equal to source checksum
    this.dest_checksum_=[];
end

