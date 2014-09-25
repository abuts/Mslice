function this = build_contents_from_string(this,string)
% Private class method which reads the class contents from a string of
% comma-separated values in specified sequence and format
%
%
%   $Rev: 288 $ ($Date: 2014-04-05 21:48:22 +0100 (Sat, 05 Apr 2014) $)
%

rez = regexp(string,';','split');


nrez = numel(rez);
n_identified=numel(this.fields_to_write_);
if nrez<n_identified
    error('FILE_DESCRIPTOR:from_string','invalid number of fields defined in the string');
end
%
base_fields = this.fields_to_write_;
format = this.fields_format_;
for i=1:numel(format)
    this.(base_fields{i})= sscanf(rez{i},format{i});
end
if isempty(this.fext_)
    % default file extension
    this.fext_ = '.m';
end



if numel(rez)>n_identified
    % the modifiers for the file may or may not be written at the file end
    nmodifiers = sscanf(rez{n_identified+1},'%d');
    if nrez<n_identified+1+2*nmodifiers
        error('FILE_DESCRIPTOR:from_string','invalid number of modifiers fields written to file');
    end
    
    if nmodifiers>0
        modifiers = rez(n_identified+1:n_identified+1+2*nmodifiers);
        this.fields_to_modify_=modifiers(1:2:(2*nmodifiers-1));
        this.modify_with_     =modifiers(2:2:2*nmodifiers);
    end
else
    if isempty(this.target_name_)
        this.targ_checksum_=[];
    end    
end

this.is_folder_class_= find_if_isfolder_class(this);


