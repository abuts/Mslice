function str = drop_contents_to_string(this)
% store contents of file descriptor in a comma separated string of special
% values
%
%   $Rev: 285 $ ($Date: 2014-04-04 15:57:36 +0100 (Fri, 04 Apr 2014) $)
%

n_fields=numel(this.fields_to_write_);

fields = this.fields_to_write_;
form = this.fields_format_;
str=sprintf(form{1},this.(fields{1}));
for i=2:n_fields
    str = [str,';',sprintf(form{i},this.(fields{i}))];
end


nmod = this.n_fields_to_modify;
if nmod >0
    if this.checksum == this.dest_checksum
        return;   
    end
    fields = fieldnames(this.mod_success_);
    nmod = numel(fields);
    if nmod==0
        return;
    end
    modifiers = sprintf(';%d;%s;%s',nmod,fields{1},this.mod_success_.(fields{1}));
    for i=2:nmod
        modifiers = [modifiers,sprintf(';%s;%s',fields{i},this.mod_success_.(fields{i}))];
    end
    str=[str,modifiers];
end
