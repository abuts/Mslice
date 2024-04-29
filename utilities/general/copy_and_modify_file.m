function [new_checksum, modifiers_successfull]=copy_and_modify_file(source_file,dest_file,fields_to_modify,modify_with)
% function used to copy file, modify some of its contents and calculate the
% checksum if the modification was successfull.
%
%Usage:
%>>[checksum,modifiers]=copy_and_modify_file(source_file,dest_file,fields_to_modify,modify_with)
% where:
% source_file      -- the file you tryingt to modify
% dest_file        -- the file you want to get as the result
% fields_to_modify -- cellarray of words to be replaced in source file
% modify_with      -- cellarray of words, which replace the filelds above
% result:
% checksum   - if some fields in the file were modified, the checksum of
%              the new file. Empty, if no fields were modified during
%              copying
% modifiers  -- the structure in the form:
% modifiers.field_modified=modified_with
%               contatining the words, modified while copied from source to
%               destignation.
%
% $Revision: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%
%

fs=fopen(source_file,'r');
if fs<=0
    error('FUNC_COPIER:copyAndModify',' error opening source file %s',source_file);
end
cl1 = onCleanup(@()fclose(fs));
ft= fopen(dest_file,'w');
if ft<=0
    error('FUNC_COPIER:copyAndModify',' error opening target file file %s',dest_file);
end
cl2 = onCleanup(@()fclose(ft));
% clear all previous information (got may be from loading) abour successfully replaced
% modification fields.
modifiers_successfull=struct();
n_fields_to_modify = numel(fields_to_modify);

line = fgets(fs);
while(line>-1)
    
    for i=1:n_fields_to_modify
        lineO = line;
        line = strrep(line,fields_to_modify{i},modify_with{i});
        if ~strcmp(line,lineO)
            modifiers_successfull.(fields_to_modify{i})=modify_with{i};
            %fprintf('File %s : modified line %s with %s ',this.source_name,lineO,line);
        end
    end
    
    fprintf(ft,'%s',line);
    line = fgets(fs);
end


n_modified = numel(fieldnames(modifiers_successfull));
if n_modified >0
    new_checksum = calc_checksum(dest_file);
else
    new_checksum  = [];
end
